/******************************************************************************
 - this procedure will be attached to the target queue and will be called
 - every time this queue is activated (receives a message). 
******************************************************************************/
use ServiceBrokerBeginner
go
create or alter procedure dbo.TargetQueueActivation
as
begin
	set nocount on;
	
	declare @handle uniqueidentifier 
	declare @message_type_name sysname
	declare @message_body varbinary(max)
	declare @reply_message_body nvarchar(1000)
	   
	while (1=1)
	begin
		begin transaction;
	
			waitfor(
				receive top (1)									-- just handle one message at a time
					 @handle			= conversation_handle	-- the identifier of the dialog this message was received on
					,@message_type_name	= message_type_name		-- the type of message received
					,@message_body		= message_body			-- the message contents
					from dbo.TargetQueue
			), timeout 1000			
	
			/* receive the next available message from the queue */
			if (@@rowcount = 0)
				begin
					commit;
					break;
				end
	
			/* check if we received an expected messsage type */
			if @message_type_name = N'RequestMessage'
				begin
					/************************************************************************************
						this the place where we could call any other procedure / initiate any other action
						for now we will just send a reply message
						should use try/catch in that case, or else the conversation will be broken in case of an error
					*************************************************************************************/
					set @reply_message_body = N'Yes sir, will do!';
					send on conversation @handle message type ReplyMessage (@reply_message_body)
					/* end the conversation */
					end conversation @handle
				end
			/* if "endDialog" is received, end the conversation from our side */
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

-- *****************************************************************************
-- attach procedure to processing queue
-- this means the procedure will be called everytime the queue is activated
-- *****************************************************************************
alter queue dbo.TargetQueue
	with activation (
		 status = on
		,procedure_name = dbo.TargetQueueActivation
		,max_queue_readers = 5		-- this defines how many conversations your queue is allowed to process at the same time (parallel processing)
		,execute as self			-- defines the user context in which the procedure is run. other options SELF, OWNER
	)
go