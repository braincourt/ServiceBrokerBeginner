/****************************************************************************
 - Create services for both sides
 - The basic Service Broker infrastructure is finished after this step
****************************************************************************/
use ServiceBrokerBeginner
go

/*
if  exists (select * from sys.services where name = N'InitiatorService')
	drop service InitiatorService
if  exists (select * from sys.services where name = N'TargetService')
	drop service TargetService
*/

/* create services */
create service InitiatorService 
	on queue dbo.InitiatorQueue					-- no contract = one way communication
create service TargetService	
	on queue dbo.TargetQueue (MessageContract)	-- setup for request/reply
