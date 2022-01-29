/***************************************************************************
 - This view can be used to look into both queues at the same time
 - Message body can be converted to the corresponding data type
****************************************************************************/
use ServiceBrokerBeginner
go

create or alter view dbo.vwListqueues
as
select
 x.message_enqueue_time
,x.service_id
,x.service_name
,x.status
,x.priority
,x.queuing_order
,case x.message_type_name 
	when 'X' then cast(x.message_body as xml)	-- X means it is a validated xml
	else cast(x.message_body as nvarchar(4000))	-- otherwise we convert to nvarchar (in case of binary that won't help though 
 end as message_body
,x.conversation_group_id
,x.conversation_handle
,x.message_sequence_number
,x.service_contract_id
,x.message_type_id
,x.message_type_name
,service_contract_name
,x.validation
from 
(
	select   message_enqueue_time, status, priority, queuing_order, message_body, conversation_group_id, conversation_handle, message_sequence_number
			,service_id, service_name, service_contract_id, message_type_id, message_type_name, service_contract_name, validation
	from dbo.InitiatorQueue with(nolock)

	union all

	select   message_enqueue_time, status, priority, queuing_order, message_body, conversation_group_id, conversation_handle, message_sequence_number
			,service_id, service_name, service_contract_id, message_type_id, message_type_name, service_contract_name, validation
	from dbo.TargetQueue with(nolock)
) x
