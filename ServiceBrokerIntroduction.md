<!-- Space: CCMSFT -->
<!-- Parent: Knowledge Center -->
<!-- Parent: Service Broker -->
<!-- Title: Introduction -->

# Service Broker Introduction
## Definition
* Service Broker is a message delivery framework that enables you to create native in-database service-oriented applications in the SQL Server Database Engine and [Azure SQL Managed Instance](https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/transact-sql-tsql-differences-sql-server#service-broker).
* It provides the infrastructure for reliable, asynchronous meassaging and queuing
* Communicationcan take place inside the same database, across databases/instances/servers (but only SQL Server).
* Message queues can be processed in order of receive or based on various kinds of sorting and priorities.
* Also allows parallel processing of messages (one message =3D max. 2GB). The number of threads can be configured for each queue individually.
* Provides the possibility of building event-based applications (your own "events" or as an alternative to DDL triggers and SQL Trace).

## Typical scenarios for Service Broker
Service Broker can be useful for any application that needs to perform processing asynchronously, or that needs to distribute processing across a number of computers. Typical uses of Service Broker include:

* Asynchronous triggers
* Reliable query processing
* Reliable data collection
* Distributed server-side processing for client applications
* Data consolidation for client applications
* Large-scale batch processing

## Architecture
Unlike classic query processing functionalities that constantly read data from the tables and process them during the query lifecycle, in service-oriented application you have database services that are exchanging the messages. Every service has a queue where the messages are placed until they are processed.
<br/>
![image](https://user-images.githubusercontent.com/85419575/138928786-c3cffa0c-6f82-4c4e-880e-efd12c2d6865.png)
![image](https://user-images.githubusercontent.com/85419575/138929011-2528664b-3061-4078-940c-091624e6b029.png)
![image](https://user-images.githubusercontent.com/85419575/138929098-cd14c6dc-b576-46a6-b2c7-913768e9b9c1.png)
