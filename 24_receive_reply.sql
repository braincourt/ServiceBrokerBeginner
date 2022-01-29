/****************************************************************************
 - Receive the reply, end conversation from this side too
****************************************************************************/
use ServiceBrokerBeginner
go

declare @handle uniqueidentifier
declare @message_body nvarchar(1000)
declare @message_type_name sysname 

begin transaction;

	/* receive reply from request queue */
	receive top(1)
		 @handle = conversation_Handle
		,@message_body = cast(message_body as nvarchar(max))
		,@message_type_name = message_type_name
	from [dbo].[InitiatorQueue]; 

	/* check if we received the expected message type */
	if @message_type_name = N'ReplyMessage'
		end conversation @handle;

	/* show received message in result window */
	select @message_body as MessageReceived; 

commit transaction;
go

/*
	check queues again: everything should be in the clear now
	as far as endpointsgo there might be an endpoint left with security timestamp 
	half an hour in the future (UTC), which is ok
*/

