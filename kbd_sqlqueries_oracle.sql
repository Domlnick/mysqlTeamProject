-- oracle 사용
-- sqlplus system/manager에서 실행

SELECT * FROM grade;
SELECT * FROM users;
SELECT * FROM boards;

-- 1. son이 이용한 킥보드의 차번호, 등급, 할인율을 검색하기.
-- keyword: subquery
select b.boardNo, g.grade, g.discount as 할인율
from grade g, boards b 
where g.gradeNo = (
            select gradeNo
            from boards
            where boardNo = (
                        select boardNo 
                        from users
                        where user_name = 'son'
        )
)and b.gradeNo = g.gradeNo;

-- 2. 요금이 1만원 이상 나온 사람들의 모든 차량정보를 차량번호 오름차순으로 정렬하기.
-- keyword : subquery, order by
select b.*, u.charged 
from boards b, users u
where b.boardNo in (
        select boardNo
        from users
        where charged >= 10000
	)
and u.boardNo = b.boardNo 
order by b.boardNo asc;

-- 3. 할인율이 가장 높은 차량을 탄 사람 이름을 검색하기.
-- keyword : subquery, max()
select user_name
from users
where boardNo = (
        select boardNo 
        from boards
        where gradeNo = (
                select gradeNo
                from grade
                where discount = (
                        select max(discount) 
                        from grade
                )
        )
);

-- 4. kane이 지금 탑승종료했을때 나오는 요금을 구하기.
-- trunc(), to_date, subquery, operator
select 
(TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60
	* g.charge
	* (1 - g.discount) as "현재 요금 (원)"
from grade g, boards b
where g.gradeNo = (
        select gradeNo 
        from boards
        where boardNo = (
                select boardNo
                from users
                where user_name = 'kane'
        )
)and g.gradeNo = b.gradeNo;

-- 5. 오전/오후 중 탑승인원이 가장 많은 시간대를 구하기. (시간, 탑승인원 컬럼 출력)
-- keyword : case, group by, order by, substr
-- sqlplus에서는 boards table에 저장된 time_on 컬럼의 데이터 양식이 연-월-일 까지만 저장되어 정상 실행 x
-- 이 문제만 dbeaver에서 kbd table 파일에서 실행
SELECT * FROM boards;

select
    case
        when substr(time_on, 12, 2) < 12 then '오전'
		ELSE '오후'
        END AS 시간대, count(*) AS 탑승인원
from boards b
GROUP BY 
	CASE  
		when substr(time_on, 12, 2) < 12 then '오전'
		ELSE '오후'
        END
ORDER BY 1;


-- 6. 현재 시간을 기준으로 모든 사용자가 하차시, 요금이 많은 사용자 3명을 오름차순으로 출력하기. (사용자, 요금 컬럼 출력)
-- keyword : trunc, to_date, order by, rownum(mysql에선 limit)
       
select
	u.user_name as "사용자",
	trunc(((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60
	* g.charge  * (1 - g.discount)), 0) as "요금"
from users u , boards b , grade g
where u.boardNo = b.boardNo and b.gradeNo = g.gradeNo
AND rownum <= 3
order by "요금" desc
;

-- 7. 새로운 유저 (7, 'bacon', 0, 0)가 회원가입 후, '4444' 보드에 탑승하는 쿼리를 작성해주세요.
-- insert, delete, update
insert into users values (7, 'bacon', 0, null);

UPDATE users
SET boardNo = '4444'
WHERE userNo = 7;

UPDATE boards
SET time_on = to_date(SYSDATE, 'YYYYMMDDHH24MISS')
WHERE BOARDNO = (SELECT BOARDNO FROM users WHERE userNo = 7);

SELECT * FROM users;
DELETE FROM users WHERE userNo = 7;
        
-- 8. VVIP 등급의 보드를 타고 있는 유저의 정보를 모두 검색하시오.
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
-- 9. 등급이 4인 새로운 보드가 추가 되었을때, boardNo, maker, 보드를 대여하고 있는 user_name과 총 대여시간을 출력하시오.
-- 현재 시간은 2022년 6월 8일 12시 정각이라고 가정
-- keyword : insert, delete, timdiff, join, group by
INSERT INTO boards values('7777', 'SAMSUNG', 0, 4, null);

SELECT b.boardNo, maker, u.user_name, 
	(TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60
FROM boards b LEFT join users u
on u.boardNo = b.boardNo
ORDER BY boardNo asc;

DELETE FROM boards WHERE boardNo =7777; 
    
-- 10. 보드의 누적 주행거리가 1000 km가 되면 한등급씩 하락한다고 가정하고 업데이트 된 보드 정보를 모두 출력하시오.
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

-- 11. smith 사용자가 10km 주행 후, 보드에서 내리는 쿼리를 작성하시오
-- (1) user와 board의 연결이 끊어져야 함.
-- (2) users의 charged에 현재 요금이 누적되어야 함.
-- (3) boards의 kms에 주행 km가 누적되어야 함.
-- keyword: update, subquery, operator, truncate, timestampdiff
UPDATE boards
SET kms = kms + 10
WHERE boardNo = (SELECT boardNo FROM users WHERE user_name = 'smith');

UPDATE users
SET users.boardNo = NULL, 
	users.CHARGED = (
						(SELECT CHARGED FROM users WHERE USER_NAME = 'smith') + (
						 select trunc(((TO_DATE('2022-06-08 12:00:00', 'yyyy-mm-dd hh24:mi:ss') - time_on)*24*60 
						 * grade.charge * (1 - grade.discount)), 0) as charge
						 from users, boards, grade
						 where user_name = 'smith'
						 and users.boardNo = boards.boardNo
						 and boards.gradeNo = grade.gradeNo))
WHERE user_name ='smith';

UPDATE users
SET users.boardNo = '4444',
users.charged = 9000
WHERE user_name = 'smith';

UPDATE boards
SET boards.kms = 800
WHERE BOARDNO = '4444';





SELECT * FROM users;
SELECT * FROM boards;
