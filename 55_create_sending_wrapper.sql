/*************************************************************************
 - Here we create a wrapper to have an easier time sending messages
**************************************************************************/
use ServiceBrokerBeginner
go

/* best practice: use a wrapper procedure for sending messages */
create procedure dbo.SendBrokerMessage 
	@fromservice sysname,
	@Toservice   sysname,
	@contract    sysname,
	@MessageType sysname,
	@message_body xml
as
begin
	set nocount on;
	/* create a unique id for the conversation = conversation handle */
 	declare @handle uniqueidentifier;
 	begin transaction;

		/* begin conversation */
		begin dialog conversation @handle
			from service @fromservice
			to service   @Toservice
			on contract  @contract
			with encryption = off;
		/* send message text (body) with the corresponding message type */
		send on conversation @handle message type @MessageType(@message_body);

	commit transaction;
end
go
