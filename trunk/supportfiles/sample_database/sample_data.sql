drop table if exists GTT_PERSON;
drop table if exists GTT_CITY;
drop table if exists GTT_COUNTRY;
drop table if exists GTT_LOG;
drop table if exists GTT_MUSIC;

create table GTT_PERSON 
(
	id integer primary key,
	first_name varchar(50),
	last_name varchar(50),
	id_village integer,
	id_music integer,
	picture blob
);

create table GTT_MUSIC 
(
	id integer primary key,
	name varchar(255)
);

create table GTT_CITY
(
	id integer primary key,
	name varchar(50),
	id_country integer
);


create table GTT_COUNTRY 
(
	id integer primary key,
	name varchar(100),
	total_area_km integer,
	short_name varchar(4)
);


create table GTT_LOG
(
	Msg varchar(4000)
);

insert into GTT_MUSIC values (1, 'Rock');
insert into GTT_MUSIC values (2, 'Pop');
insert into GTT_MUSIC values (3, 'Classic');

insert into GTT_COUNTRY values (1, 'United States of America', 9826630, 'USA');
insert into GTT_COUNTRY values (2, 'Bundesrepublik Deutschland', 357114, 'DE');
insert into GTT_COUNTRY values (3, 'United Kingdom of Great Britain and Northern Ireland', 244820, 'GB');

insert into GTT_CITY values (1, 'New York', 1);
insert into GTT_CITY values (2, 'Berlin', 2);
insert into GTT_CITY values (3, 'London', 3);
insert into GTT_CITY values (4, 'Belfast', 3);

insert into GTT_PERSON values (1, 'John','Baker', 1,1, null);
insert into GTT_PERSON values (2, 'Darius','Miller', 1,1, null);
insert into GTT_PERSON values (3, 'Jim','West', 2,3, null);
insert into GTT_PERSON values (4, 'Ken','Y', 3,2, null);

