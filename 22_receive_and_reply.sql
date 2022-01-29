/****************************************************************************
 - After sending the first message it is waiting in the receiver-queue to be processed
 - For now we do this manually, later we will define a procedure that does this automatically for us
****************************************************************************/
use ServiceBrokerBeginner
go

declare @handle uniqueidentifier
declare @message_body nvarchar(1000)
declare @message_type_name sysname 
declare @reply_message_body nvarchar(1000)

begin transaction;

	/* receive message from initiator */
	receive top(1)
		 @handle			= conversation_handle
		,@message_body		= cast(message_body as nvarchar(max))
		,@message_type_name = message_type_name
	from dbo.TargetQueue

	/* check if we received the expected messagetype */
	if @message_type_name = N'RequestMessage'
	begin
		/* create friendly reply and send it */
		set @reply_message_body = N'Chill out, dude!'; -- no xml this time (as defined in message type)
		send on conversation @handle message type ReplyMessage (@reply_message_body);
		/* now we have to end the conversation */
		end conversation @handle
	end
	/* show received and sent message in result window */
	select cast(@message_body as xml) as MessageReceived, @reply_message_body as MessageSent
	
commit transaction
go

/*
	check your queue status before procedding to the next sql script
	target queue schould be empty, while the initiator queue should have two messages:
		- our reply 
		- and 'EndDialog' (from system), which was triggered by ending the conversation on this side
*/