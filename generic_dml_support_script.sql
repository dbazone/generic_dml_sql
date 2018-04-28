drop table source_table 
drop table destination_table 


create table source_table (
	id_other int primary key identity (1,1)

	,name varchaR(50)
	,emp_id int
	,city_nm char(50)
	,state_nm char(50)
	, country char(50)

	, unique (name, emp_id)
)



create table destination_table (
	id_other int primary key identity (1,1)

	,name varchaR(50)
	,emp_id int
	,city_nm char(50)
	,state_nm char(50)
	, country char(50)
	, unique (name, emp_id)

)

/*
test case 1

insert into source_table (name, emp_id, city_nm, state_nm )
values ('Vijay',0101, 'HYD',NULL)

*/


/*
test case 2

insert into source_table (name, emp_id, city_nm, state_nm )
values ('Vijay',0101, 'HYD','TS')

insert into destination_table (name, emp_id, city_nm, state_nm )
values ('Vijay',0101, 'HYD',NULL)

*/





/*
test case 3

insert into source_table (name, emp_id, city_nm, state_nm )
values ('Vijay',0101, 'HYD','TS')

insert into destination_table (name, emp_id, city_nm, state_nm )
values ('Vijay',0101, 'HYD',NULL)


insert into destination_table (name, emp_id, city_nm, state_nm )
values ('kadiri',0101, 'HYD',NULL)


*/