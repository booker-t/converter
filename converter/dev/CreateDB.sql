create table files (
	sid varchar(32) not null,
	name varchar(255) not null,
	uploaded datetime not null,
	unique key(sid, name)
) engine=innodb default_charset=utf8;

alter table files add email varchar(64) not null default 'admin@tota.systems';

alter table files add is_new tinyint unsigned not null default 0;

alter table files drop key sid;