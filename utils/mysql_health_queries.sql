select now();

show global status like 'aborted_connects';
select version();
show global variables like 'max_connections';
show global status like 'max_used_connections';

-- rds describe-db-instances
-- rds describe db log files

select 
	table_schema as 'Database Name',
	sum(data_length + index_length) / 1024 / 1024 as 'Used Space in MB',
	sum(data_free) / 1024 / 1024 as 'Free Space in MB',
	sum(data_length + index_length + data_free) / 1024 / 1024 as 'Total Space in MB'
from information_schema.tables
where table_schema not in ('information_schema', 'mysql', 'performance_schema', 'sys')
group by table_schema
order by sum(data_length + index_length + data_free) desc;

show global variables where variable_name in ('autocommit', 'max_allowed_packet', 'max_connections', 'group_concat_max_len', 'innodb_ft_result_cache_limit');

select table_name as 'Table', round(((data_length + index_length) / 1024 / 1024), 2) as 'Size in MB'
from information_schema.tables
where table_schema = 'mysql' and table_name = 'slow_log';

select table_name as 'Table', round(((data_length + index_length) / 1024 / 1024), 2) as 'Size in MB'
from information_schema.tables
where table_schema = 'mysql' and table_name = 'slow_log_backup';

select table_name as 'Table', round(((data_length + index_length) / 1024 / 1024), 2) as 'Size in MB'
from information_schema.tables
where table_schema = 'mysql' and table_name = 'general_log';

select table_name as 'Table', round(((data_length + index_length) / 1024 / 1024), 2) as 'Size in MB'
from information_schema.tables
where table_schema = 'mysql' and table_name = 'general_log_backup';

show variables like '%binlog%';

GRANT EXECUTE ON mysql.rds_show_configuration TO 'mysqluser'@'%';
GRANT PROCESS ON *.* TO 'your_username'@'your_host';
call mysql.rds_show_configuration;

select 
	file_name, 
	tablespace_name,
	table_name,
	engine,
	index_length,
	total_extents,
	total_extents*extent_size as size_of_db
from information_schema.files
where file_name like '%ibtmp%';

select *
from mysql.innodb_index_stats where database_name = '*' and table_name = 'collations';


show global status like '%open%';

select * from sys.schema_unused_indexes where index_name not like 'fk_*' and object_schema not in ('performance_schema', 'mysql', 'information_schema');

select 
	event_name as wait_event,
	count_star as oll_occurrences,
	concat(round(sum_timer_wait / 1000000000000, 2), ' s') as total_wait_time,
	concat(round(avg_timer_wait / 1000000000000, 2), ' ms') as avg_wait_time
from performance_schema.events_waits_summary_global_by_event_name
where count_star > 0 and event_name <> 'idle'
order by sum_timer_wait DESC 
limit 10;

select 
	object_schema as table_schema,
	object_name as table_name,
	index_name,
	count_star as all_accessesss,
	count_read,
	count_write,
	concat(truncate(count_read/count_star*100, 0), ':',
	truncate(count_write/count_star*100,0)) as read_write_ratio,
	count_fetch as rows_selected,
	count_insert as rows_inserted,
	count_update as rows_updated,
	count_delete as rows_deleted,
	concat(round(sum_timer_wait / 1000000000000, 2), ' s') as total_latency,
	concat(round(sum_timer_fetch / 1000000000000, 2), ' s') as select_latency,
	concat(round(sum_timer_insert / 1000000000000, 2), ' s') as insert_latency,
	concat(round(sum_timer_update / 1000000000000, 2), ' s') as update_latency,
	concat(round(sum_timer_delete / 1000000000000, 2), ' s') as delete_latency
from performance_schema.table_io_waits_summary_by_index_usage
where index_name is not null and count_star > 0
order by sum_timer_wait desc;
