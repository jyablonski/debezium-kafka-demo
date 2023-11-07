CREATE USER 'jacob'@'%' IDENTIFIED BY 'password';

grant select on demo.* to 'jacob'@'%';

GRANT SELECT ON mysql.innodb_index_stats TO 'jacob'@'%';
GRANT SELECT ON sys.schema_unused_indexes TO 'jacob'@'%';
GRANT SELECT ON performance_schema.events_waits_summary_global_by_event_name TO 'jacob'@'%';
GRANT SELECT ON performance_schema.table_io_waits_summary_by_index_usage TO 'jacob'@'%';

GRANT EXECUTE ON PROCEDURE mysql.rds_show_configuration TO 'jacob'@'%';
GRANT PROCESS ON *.* TO 'jacob'@'%';
