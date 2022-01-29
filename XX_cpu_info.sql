/*
	get info on your logical cpu's for setting MAXDOP and max_readers
	https://docs.microsoft.com/en-US/sql/database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option?view=sql-server-ver15
*/

select
	LogicalCPUs			= cpu_count
	,PhysicalCPUs		= cpu_count / hyperthread_ratio
	,HTEnable			= case when cpu_count > hyperthread_ratio then 1 else 0 end
	,NumberOfNUMA		= (select count(distinct parent_node_id)from sys.dm_os_schedulers where status = 'VISIBLE ONLINE' and parent_node_id < 64)
	,LogicalCPUsPerNUMA =
	 (
		 select count(parent_node_id)
		 from sys.dm_os_schedulers
		 where status		  = 'VISIBLE ONLINE'
		   and parent_node_id < 64
		 group by parent_node_id
	 )
from sys.dm_os_sys_info