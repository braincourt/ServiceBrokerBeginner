/****************************************************************************
 - Create a contract for our conversation
 - Contracts define roles and message types of a conversation
*****************************************************************************/
use ServiceBrokerBeginner
go

/*
if  exists (select * from sys.service_contracts where name = N'MessageContract')
	drop contract [MessageContract]
*/

create contract MessageContract 
(
	 RequestMessage	sent by initiator
	,ReplyMessage	sent by target
)