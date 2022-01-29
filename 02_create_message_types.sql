/****************************************************************************
 - Create message types
*****************************************************************************/
use ServiceBrokerBeginner
go

/*
if  exists (select * from sys.service_message_types where name = N'RequestMessage')
	drop message type RequestMessage
if  exists (select * from sys.service_message_types where name = N'ReplyMessage')
	drop message type ReplyMessage
*/

/* create message type for request (message must be a well formed xml) */
create message type RequestMessage validation = well_formed_xml

/* create message type for reply (no validation) */
create message type ReplyMessage