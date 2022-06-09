-- oracle 사용
-- sqlplus system/manager에서 실행

SELECT * FROM grade;
SELECT * FROM users;
SELECT * FROM boards;

-- 1. son이 이용한 킥보드의 차번호, 등급, 할인율을 검색하세요.
-- keyword: subquery
SELECT b.boardNo, g.grade, g.discount AS 할인율
FROM grade g, boards b 
WHERE g.gradeNo = (
            SELECT gradeNo
            FROM boards
            WHERE boardNo = (
                        SELECT boardNo 
                        FROM users
                        WHERE user_name = 'son'
        )
) AND b.gradeNo = g.gradeNo;


-- 2. 요금이 1만원 이상 나온 사람들의 모든 차량정보를 차량번호 오름차순으로 정렬하세요.
-- keyword : subquery, order by
SELECT b.*, u.charged 
FROM boards b, users u
WHERE b.boardNo IN (
        SELECT boardNo
        FROM users
        WHERE charged >= 10000
	)
AND u.boardNo = b.boardNo 
ORDER BY b.boardNo ASC;


-- 3. 할인율이 가장 높은 차량을 탄 사람 이름을 검색하세요.
-- keyword : subquery, max()
SELECT user_name
FROM users
WHERE boardNo = (
        SELECT boardNo 
        FROM boards
        WHERE gradeNo = (
                SELECT gradeNo
                FROM grade
                WHERE discount = (
                        SELECT max(discount) 
                        FROM grade
                )
        )
);


-- 4. kane이 지금 탑승종료했을때 나오는 요금을 구하세요.
-- trunc() to_date, subquery, operator
SELECT 
trunc((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60
	* g.charge
	* (1 - g.discount), -1) AS "현재 요금 (원)"
FROM grade g, boards b
WHERE g.gradeNo = (
        SELECT gradeNo 
        FROM boards
        WHERE boardNo = (
                SELECT boardNo
                FROM users
                WHERE user_name = 'kane'
        )
)AND g.gradeNo = b.gradeNo;


-- 5. 오전/오후로 탑승인원을 구분하세요. (시간, 탑승인원 컬럼 출력)
-- keyword : case, group by, order by, substr
-- sqlplus에서는 boards table에 저장된 time_on 컬럼의 데이터 양식이 연-월-일 까지만 저장되어 정상 실행 x
-- dbeaver에서 따로 ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';로 데이터 양식 설정
SELECT * FROM boards;

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT
    CASE
        WHEN substr(time_on, 12, 2) < 12 THEN '오전'
		ELSE '오후'
        END AS 시간대, count(*) AS 탑승인원
FROM boards b
GROUP BY 
	CASE  
		WHEN substr(time_on, 12, 2) < 12 THEN '오전'
		ELSE '오후'
        END
ORDER BY 1;


-- 6. 현재 시간을 기준으로 모든 사용자가 하차시, 요금이 많은 사용자 3명을 오름차순으로 출력하세요. (사용자, 요금 컬럼 출력)
-- keyword : trunc, to_date, order by, rownum(mysql에선 limit)
SELECT
	u.user_name AS "사용자",
	trunc(((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60
	* g.charge  * (1 - g.discount)), 0) AS "요금"
FROM users u , boards b , grade g
WHERE u.boardNo = b.boardNo AND b.gradeNo = g.gradeNo
AND rownum <= 3
ORDER BY "요금" DESC;


-- 7. 새로운 유저 (7, 'bacon', 0, 0)가 회원가입 후, '4444' 보드에 탑승하는 쿼리를 작성하세요.
-- insert, delete, update
INSERT INTO users VALUES (7, 'bacon', 0, null);

UPDATE boards
SET time_on = to_date(SYSDATE, 'YYYYMMDDHH24MISS')
WHERE BOARDNO = (SELECT BOARDNO FROM users WHERE userNo = 7);

SELECT * FROM users;
SELECT * FROM boards;

-- 초기화용
UPDATE users
SET boardNo = '4444'
WHERE userNo = 7;

UPDATE BOARDS
SET time_on = '2022-06-08 06:20:40'
WHERE boardNo = '4444';

DELETE FROM users WHERE userNo = 7;
        
-- 8. VVIP 등급의 보드를 타고 있는 유저의 정보를 모두 검색하세요.
-- keyword : subquery
SELECT gradeNo FROM grade WHERE grade ='VVIP';

SELECT * 
FROM users 
WHERE boardNo = (
	SELECT boardNo FROM boards WHERE gradeNo = (
		SELECT gradeNo FROM grade WHERE grade = 'VVIP'
		)
);

SELECT * FROM users WHERE user_name ='tom';


-- 9. 등급이 4인 새로운 보드가 추가 되었을때, boardNo, maker, 보드를 대여하고 있는 user_name과 총 대여시간(분)을 출력하세요.
-- 현재 시간은 2022년 6월 8일 12시 정각이라고 가정
-- keyword : trunc(), insert, delete, timdiff, join, group by
INSERT INTO boards VALUES('7777', 'SAMSUNG', 0, 4, NULL);

SELECT b.boardNo, maker, u.user_name, 
	trunc((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60, 0)
FROM boards b LEFT JOIN users u
ON u.boardNo = b.boardNo
ORDER BY boardNo ASC;

DELETE FROM boards WHERE boardNo =7777; 
DELETE FROM users WHERE USERNO = 7;
SELECT * FROM boards;
SELECT * FROM USERS;
    
-- 10. 보드의 누적 주행거리가 1000 km가 되면 한등급씩 하락한다고 가정하고 업데이트 된 보드 정보를 모두 출력하세요.
-- 단, 최하등급은 1단계로 가정.
-- keyword : case
SELECT * FROM boards;

SELECT boardNo, maker, kms,
    CASE
        WHEN gradeNo = 1 THEN gradeNo
        WHEN kms >= 1000 THEN gradeNo-1
        ELSE gradeNo
    END AS 수정된등급, time_on
FROM boards
ORDER BY 수정된등급 asc;

-- 11. smith 사용자가 10km 주행 후, 보드에서 내리는 쿼리를 작성하세요.
-- (1) user와 board의 연결이 끊어져야 함.
-- (2) users의 charged에 현재 요금이 누적되어야 함.
-- (3) boards의 kms에 주행 km가 누적되어야 함.
-- keyword: update, subquery, operator, trunc(), to_date()
UPDATE boards
SET kms = kms + 10
WHERE boardNo = (SELECT boardNo FROM users WHERE user_name = 'smith');

UPDATE users
SET users.boardNo = NULL, 
	users.CHARGED = (
		(SELECT CHARGED FROM users WHERE USER_NAME = 'smith') + (
		 SELECT trunc(((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60 
		 * grade.charge * (1 - grade.discount)), 0) AS charge
		 FROM users, boards, grade
		 WHERE user_name = 'smith'
		 AND users.boardNo = boards.boardNo
		 AND boards.gradeNo = grade.gradeNo))
WHERE user_name ='smith';

SELECT * FROM users;
SELECT * FROM boards;

UPDATE users
SET users.boardNo = '4444',
users.charged = 9000
WHERE user_name = 'smith';

UPDATE boards
SET boards.kms = 800
WHERE BOARDNO = '4444';


SELECT * FROM users;
SELECT * FROM boards;
