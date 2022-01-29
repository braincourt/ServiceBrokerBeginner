/****************************************************************************
 - Create queues for sender (initiator) and receiver (target)
*****************************************************************************/
use ServiceBrokerBeginner
go

/*
if  exists (select * from sys.service_queues where name = N'InitiatorQueue')
	drop queue dbo.InitiatorQueue
if  exists (select * from sys.service_queues where name = N'TargetQueue')
	drop queue dbo.TargetQueue
*/

/* create queues */
create queue dbo.TargetQueue
create queue dbo.InitiatorQueue
