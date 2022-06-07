--  CREATE DATABASE kbd;

-- use kbd;
drop table IF EXISTs users;
drop table IF EXISTs boards;
drop table IF EXISTs grade;

create table users(
	userNo int  NOT NULL  AUTO_INCREMENT,
	user_name varchar(12) not null,
	charged int default 0,
	boardNo int,
	CONSTRAINT pk_users PRIMARY KEY (userNo)
);

create table boards(
	boardNo int  NOT null,
	maker varchar(12) not null,
	kms int default 0,
	gradeNo int,
	time_on datetime,
	CONSTRAINT pk_boards PRIMARY KEY (boardNo)
);

create table grade(
	gradeNo int  NOT NULL  AUTO_INCREMENT,
	grade varchar(12) not null,
	charge int(3),
	discount double,
	CONSTRAINT pk_grade PRIMARY KEY (gradeNo)
);

ALTER TABLE users ADD CONSTRAINT fk_users_boards FOREIGN KEY (boardNo) REFERENCES boards(boardNo) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE boards ADD CONSTRAINT fk_boards_grade FOREIGN KEY (gradeNo) REFERENCES grade(gradeNo) ON DELETE NO ACTION ON UPDATE NO ACTION;

alter table users change user_name user_name varchar(20) binary;

-- 값 대입
insert into grade values (1, 'NONE', 100, 0);
insert into grade values (2, 'NORMAL', 100, 0);
insert into grade values (3, 'SILVER', 80, 0.01);
insert into grade values (4, 'GOLD', 80, 0.02);
insert into grade values (5, 'VIP', 70, 0.03);
insert into grade values	 (6, 'VVIP', 60, 0.04);
select * from grade;

insert into boards values (6666, 'XIAOMI', 1000, 1, '2022-06-02 22:00:50');
insert into boards values (5555, 'TESLA', 1400, 2, '2022-06-02 19:25:40');
insert into boards values (4444, 'BMW', 800, 3, '2022-06-02 06:20:40');
insert into boards values (3333, 'PORCHE', 500, 4, '2022-06-02 08:15:45');
insert into boards values (2222, 'HYUNDAI', 75, 5, '2022-06-02 13:30:00');
insert into boards values (1111, 'KIA', 150, 6, '2022-06-02 12:15:30');
select * from boards;

insert into users values (1, 'tom', 15000, 1111);
insert into users values (2, 'smith', 9000, 4444);
insert into users values (3, 'john', 23000, 6666);
insert into users values (4, 'ford', 7000, 5555);
insert into users values (5, 'son', 20000, 2222);
insert into users values (6, 'kane', 19000, 3333);
select * from users;



