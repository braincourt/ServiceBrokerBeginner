/*******************************************************************************
 - This procedure will be attached to the initiator queue and will be called
 - Every time this queue is activated (receives a message). 
*******************************************************************************/
use ServiceBrokerBeginner
go

create or alter procedure dbo.InitiatorQueueActivation
as
begin
	set nocount on;
	
	declare @handle				uniqueidentifier 
	declare @message_type_name	sysname
	declare @message_body		varbinary(max)
	   
	while (1=1)
	begin
		begin transaction;

			waitfor
			(
				receive top (1)									-- just handle one message at a time
					@handle				= conversation_handle,	-- the identifier of the dialog this message was received on
					@message_type_name	= message_type_name,	-- the type of message received
					@message_body		= message_body			-- the message contents
				from dbo.InitiatorQueue
			), timeout 1000										
	
			/* receive the next available message from the queue */
			if (@@rowcount = 0)
				begin
					commit;
					break;
				end
	
			/* check if we received a request */
			if @message_type_name = N'ReplyMessage'
				begin
					/* ******************************************************************************
						this the place where you can process that reply if needed
						for example insert the reply into your log table
						for now we will just end the conversation
					********************************************************************************/
					end conversation @handle
				end
			/* if "endDialog" is received, end the conversation from our side too */
			else if  @message_type_name = N'http://schemas.microsoft.com/SQL/serviceBroker/EndDialog'
				end conversation @handle
			/* in case of an error event, handle error, write something into your audit/logging table and end conversation */
			else if @message_type_name = N'http://schemas.microsoft.com/SQL/serviceBroker/Error'
				begin
					/* Log the received error into ERRORLOG and system Event Log (eventvwr.exe) */
					declare @handle_string nvarchar(100)
					declare @error_message nvarchar(4000)
					select @handle_string = cast(@handle as nvarchar(100)), @error_message = cast(@message_body as nvarchar(4000))
					raiserror (N'conversation %s was ended with error %s', 10, 1, @handle_string, @error_message) with log
					end conversation @handle
				end

		commit transaction;
	end
end
go
 
/* attach procedure to initiator queue */
alter queue InitiatorQueue
    with activation 
	(
		 status				= on
		,procedure_name		= dbo.InitiatorQueueActivation
		,max_queue_readers	= 5	-- this defines how many conversations (or asynchronous tasks) your queue is allowed to process at the same time (bigger is not necessarily better in this case).
		,execute as self
    )
go