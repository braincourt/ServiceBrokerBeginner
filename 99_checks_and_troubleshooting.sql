/****************************************************************************
 - Monitoring and troubleshooting of the Service Broker workflow
 - Messages go this route: sender-queue -> transmission-queue (system) -> receiver-queue
 - Messages need to be received/processed manually or by an activation procedure
****************************************************************************/
use ServiceBrokerBeginner
go

/*  
	first check should always look at the queue in which the message is supposed to be
	in our example that would be the target queue
	if the message is there, everything worked out and the message needs to be processed (goto '22_receive_and_reply.sql')
*/
select * from dbo.TargetQueue


/*
	if it's not in the target queue it might still be waiting in the initiator queue
	this usually happens if your message didn't pass validation (not a valid xml, not the correct message type)
*/
select * from dbo.InitiatorQueue
 

/*	if you want to see both queues at once you can create a view like '80_create_vw_list_queues.sql'	*/
select * from  dbo.vwListqueues


/*
	if the message can be found in neither of these queues, it is most likely stuck in the transmission queue.
	this the system transport queue from sql server. if it is stuck there, you will most likely get a useful error message.
	for example: wrong receiver service specified or authorization issues
	to get rid of these messages end the conversation (as described below)
*/
select * from sys.transmission_queue


/* Get the transmission status of a conversation (empty if transmitted already) */
select 'Status' = get_transmission_status('7B62823B-7636-EC11-99B8-401C83FC5BA6') -- the parameter is your conversation uid


/*
	each side of a conversation is represented by a conversation endpoint.
	this catalog view contains a row per conversation endpoint in the database.
	after a succesfull conversation all queues and endpoints for this handle should be empty, or
		show only entries with state = 'CD' (closed) and security_timestamp within 30 minutes (UTC time)
*/
select * from sys.conversation_endpoints
where not (state= 'CD' and security_timestamp <= dateadd(minute, 31, getutcdate()))	


/*
	check for disabled queues
	after five failed concurrent transactions you will get what is known as 'Message Poisoning',
		after which your queue will get disabled and a Broker:Queue Disabled event fires
*/
select * from sys.service_queues where (is_enqueue_enabled = 0 or is_receive_enabled = 0)
/*
alter queue TargetQueue with status = on  -- if disabled enable it again
*/


/*************************************************************
 - Check SQL Server log file!
 - Good resource on troubleshooting as well: https://www.sqlteam.com/articles/how-to-troubleshoot-service-broker-problems
**************************************************************/


/* 
	ending a conversation manually
	for a lot of reasons you will need to do this sometimes
	before ending a conversation, you should find the reason for the situation though
	needs conversation handle as parameter
*/
/*
end conversation '701A5DE9-ACD6-EB11-9978-401C83FC5BA6' with CLEANUP;
*/


/* 
	the last resort: full service Broker reset (only for emergencies or testing)
	your objects stay intact but any ongoing outstanding conversations will be gone
	should be avoided in production environment at all costs
*/
/*
use master
go
alter database ServiceBrokerBeginner set  new_broker with rollback immediate
*/

/* 
list system objects that can provide information or help with debugging
select * from sys.conversation_endpoints			-- described above
select * from sys.conversation_groups
select * from sys.conversation_priorities
select * from sys.message_type_xml_schema_collection_usages
select * from sys.remote_service_bindings
select * from sys.routes
select * from sys.service_contract_message_usages
select * from sys.service_contract_usages
select * from sys.service_contracts
select * from sys.service_message_types
select * from sys.service_queue_usages
select * from sys.service_queues
select * from sys.services
select * from sys.transmission_queue
select * from sys.dm_broker_activated_tasks			-- see what your activation procedures are doing
select * from sys.dm_broker_connections
select * from sys.dm_broker_forwarded_messages
select * from sys.dm_broker_queue_monitors			-- check the status of all your queues at once
*/

/*
	useful query to get more info on endpoint states
	possible replacement for "select * from sys.conversation_endpoints" from above
*/
select 
	 security_timestamp
	,conversation_handle
	,is_initiator
	,s.name as 'local_service'
	,far_service
	,sc.name as 'contract'
	,state_desc
	,is_system
	,get_transmission_status (conversation_handle) as transmission__status
from sys.conversation_endpoints ce
left join sys.services s
	on ce.service_id = s.service_id
left join sys.service_contracts sc
	on ce.service_contract_id = sc.service_contract_id

/* the following query returns information on all tasks currently activated by Service Broker */
select
	 at.spid
	,db_name(at.database_id) as dbName
	,at.queue_id
	,at.procedure_name
	,s.login_time
	,s.status
from sys.dm_broker_activated_tasks at
inner join sys.dm_exec_sessions s
	on at.spid = s.session_id


/* 
	rebuild queue index
	for MAXDOP value see "xx_cpu_info.sql"
*/
/*
alter queue TargetQueue rebuild with (maxdop = 7)  
*/