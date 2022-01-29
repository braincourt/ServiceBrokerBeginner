/****************************************************************************
 - Create database "ServiceBrokerBeginner" if it doesn't exist (yet)
 - Activate Service Broker
*****************************************************************************/
use master
go

/* set this to 1 if you want to recreate your database */
declare @recreate_db bit = 0
/* check if database exists already */
declare @db_exists bit = ISNULL((select 1 from sys.databases where [name] = 'ServiceBrokerBeginner'), 0)
/* check if Service Broker is enabled */
declare @is_broker_enabled bit = ISNULL((select is_broker_enabled from sys.databases where [name] = 'ServiceBrokerBeginner'), 0)


if @recreate_db = 1 and @db_exists = 1
begin
	/* prevent getting blocked by other processes */
	alter database ServiceBrokerBeginner set single_user with rollback immediate
	/* drop databse */
	drop database ServiceBrokerBeginner
end

/* conditional create */
if @db_exists = 0 or @recreate_db = 1
	create database ServiceBrokerBeginner 
	
/* Service Broker activation */
if @is_broker_enabled = 0
begin
	/* prevent getting blocked by other processes */
	alter database ServiceBrokerBeginner set single_user with rollback immediate
	/* activate Service Broker */
	alter database ServiceBrokerBeginner set enable_broker 
	/* back to multi user */
	alter database ServiceBrokerBeginner set multi_user with rollback immediate
end
