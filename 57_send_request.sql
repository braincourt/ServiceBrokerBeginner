/*************************************************************************
 - Sending a message through our wrapper
**************************************************************************/
use ServiceBrokerBeginner
go

/* prepare xml message for the request */
declare @message_body xml =
(
	select
		 [RequestMessage/@DebugLevel]	= 1
		,[RequestMessage/@TestMode]		= 0
		,[RequestMessage/senderId]		= 'brain246'
		,[RequestMessage/senderName]	= 'Thomas Totter'
		,[RequestMessage/MessageText]	= 'Help me, please!'
		,[RequestMessage/Comment]		= 'This is very urgent'
	for xml path('msg'), type
)

/* send a message/request */
execute dbo.SendBrokerMessage
	 @fromservice	= N'InitiatorService'
	,@Toservice		= N'TargetService'
	,@contract		= N'MessageContract'
	,@MessageType	= N'RequestMessage'
	,@message_body	= @message_body;

/*
	since we already specified automated processing on both sides,
	the rest of the workflow should be completed without our doing
	check the queues and endpoints
*/