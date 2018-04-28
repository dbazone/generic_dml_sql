
SET NOCOUNt ON 

DECLARE @source_tab varchar(50) = 'source_table'
DECLARE @destination_tab varchar(50) = 'destination_table'
declare @sql_common_where_clause as varchar(4000) = ''

declare @sql_insert_main   as varchar(4000) = ''
declare @sql_insert_col_list as varchar(4000) = ''


declare @sql_update_main   as varchar(4000) = ''
declare @sql_update_cols varchar(4000) = ''
declare @sql_join_clause varchar(4000) = ''

declare @sql_delete_main varchar(4000) = ''

declare @tbl_unique_pk table (column_nm varchar(500), is_source_tab  bit default(0), is_pk bit default(0) , is_uq bit default(0), primary key (column_nm , is_source_tab  ))


--common operations

insert into @tbl_unique_pk (column_nm , is_source_tab, is_pk, is_uq )
select column_name , case when table_name = @source_tab then 1 else 0 end , 
objectproperty(object_id(constraint_schema + '.' + quotename(constraint_name)), 'isprimarykey') , objectproperty(object_id(constraint_schema + '.' + quotename(constraint_name)), 'isuniquecnst') 
from information_schema.key_column_usage
where table_name in (@source_tab, @destination_tab )
AND (objectproperty(object_id(constraint_schema + '.' + quotename(constraint_name)), 'isprimarykey') = 1
or objectproperty(object_id(constraint_schema + '.' + quotename(constraint_name)), 'isuniquecnst') = 1)


select @sql_common_where_clause = + ' WHERE XXXX.[' + column_nm  + '] IS NULL'
from @tbl_unique_pk
WHERE is_source_tab = 0
AND is_pk = 1

--start building update stms

set @sql_update_main  = 'update  d set '  +  char(13)
select  @sql_update_cols = @sql_update_cols + ' [' + src.name + '] = s.[' + src.name + '], ' +  char(13)
from syscolumns src 
inner join syscolumns dst
	on src.name = dst.name
left join @tbl_unique_pk src_cnt
	on src_cnt.column_nm = src.name
left join @tbl_unique_pk dst_cnt
	on dst_cnt.column_nm = dst.name
where object_name (src.id) = @source_tab
and object_name (dst.id) = @destination_tab
AND src_cnt.column_nm is null
and dst_cnt.column_nm  is null

set @sql_update_cols = LEFT(@sql_update_cols, LEN(@sql_update_cols) -3)


select @sql_join_clause = @sql_join_clause  + '   AND IsNULL(s.[' +  column_nm  + '] , '''') =' + ' IsNULL(d.[' +  column_nm  + '],'''')' + char(10)
from @tbl_unique_pk
WHERE is_source_tab = 1

SET @sql_join_clause = + char(10)+  '   ON ' +  RIGHT (@sql_join_clause, LEN(@sql_join_clause) - 7)



SET @sql_join_clause = char(10) +  ' FROM ' + @source_tab   + ' s ' +  char(10) + ' INNER JOIN  ' +  @destination_tab + ' d  '
+ @sql_join_clause


SET @sql_update_main = @sql_update_main + @sql_update_cols + @sql_join_clause

--end building update stms

--start building insert stms
SET @sql_insert_main   = 'INSERT INTO ' + @destination_tab + '( '
select  @sql_insert_col_list = @sql_insert_col_list  + 'XXXX.[' + src.name + '], ' +  char(13)
from syscolumns src 
inner join syscolumns dst
	on src.name = dst.name
left join @tbl_unique_pk src_cnt
	on src_cnt.column_nm = src.name
	AND src_cnt.is_pk = 1
left join @tbl_unique_pk dst_cnt
	on dst_cnt.column_nm = dst.name
	AND dst_cnt.is_pk = 1
where object_name (src.id) = @source_tab
and object_name (dst.id) = @destination_tab
AND src_cnt.column_nm is null
and dst_cnt.column_nm  is null

SET @sql_insert_col_list  = LEFT(@sql_insert_col_list  ,len(@sql_insert_col_list  )- 3)
 



SET @sql_insert_main = @sql_insert_main 
+ REPLACE( @sql_insert_col_list , 'XXXX.', '' ) + ')' + char(10) + 
' SELECT ' + REPLACE( @sql_insert_col_list , 'XXXX.', 'S.' )
+ REPLACE(@sql_join_clause ,' INNER ', ' LEFT OUTER ') + REPLACE(@sql_common_where_clause  , 'XXXX.', 'd.' )
--end building insert stms


SET @sql_delete_main = 'DELETE d  ' + + REPLACE(@sql_join_clause ,' INNER ', ' RIGHT OUTER ') + + REPLACE(@sql_common_where_clause  , 'XXXX.', 's.' )
--print @sql_join_clause


--print @sql_update_main
--print @sql_insert_main
--print @sql_delete_main 

SET NOCOUNT OFF

print 'executing update statement..'
exec (@sql_update_main)

print 'executing print statement..'
exec(@sql_insert_main)

print 'executing delete statement..'
exec(@sql_delete_main)
