/****************************************************************************
 - Sending the first message/request
****************************************************************************/
use ServiceBrokerBeginner
go

/* 
   prepare the message as well formed xml
   since we didn't create an xml schema for validation, the xml can have any (well formed) structure
*/
declare @message_body xml =
(
	select
		 [RequestMessage/@DebugLevel]	= 1
		,[RequestMessage/@TestMode]		= 0
		,[RequestMessage/senderId]		= 'brain246'
		,[RequestMessage/senderName]	= 'Thomas Totter'
		,[RequestMessage/MessageText]	= 'Refresh my data'
		,[RequestMessage/Comment]		= 'urgent'
	for xml path('msg'), type
)

/* create a unique id for the dialog (aka conversation handle) */
declare @handle uniqueidentifier

begin transaction -- good practice, even if not needed in this example

	/* 
		begin of the conversation/dialog
		you have to provide from/to service and a unique id as the absolute minimum
		we additionally provide the contract (which will be validated)
	*/
	begin dialog conversation @handle
		from service InitiatorService
		to service N'TargetService' -- target serice has to be provided as string
		on contract MessageContract
		with encryption = off;

	/*  send message text (body) with the it's message type  */
	send on conversation @handle
		message type RequestMessage (@message_body)

	/*  show the message we just sent in result window  */
	select MessageSent = @message_body

commit transaction

/*
	next step: check what happenend with our message
	- if everything worked the message should be in the target queue, waiting to be processed
	- in case of any errors there are a lot of diffnerent possibilities

	for these (repeating steps) go to: 99_checks_and_troubleshooting.sql
 */