# Canada-Creative-Industries

This project contains outputs from the GERG creative industries project for Canada, along with source data and SSIS modules to create the outputs. Viewers can just study the output data; it's not required that you access the source data or geek stuff

# 7 October 2020
Monthly Data now available, making it possible to track COVID impact

# How to use the data

This section to be expanded. All outputs (as well as some other stuff) are stored in the RESULTS folder

# How to use this project

If you want to recreate the output data yourself (you don't have to) the following is relevant:

The project runs on Visual Studio (with SSIS tools, which have to be downloaded additionally to the main VS installation) and imports data from the /SOURCE DATA folder to an SQL server (R2012 or higher) of  your choosing. Having pulled the source from Github, you will need to change the following:

1. in Project Parameters, change the 'Root' parameter soit  direct to the root folder of your repository
2. In Project Parameters change 'ServerName' to refer to a SQL server in which you have CRUD rights
3. Create a database (if not already present) in your SQL server to contain the tables and views. We have named this CANADA_CI_OLTP but you can use any name you like. You should however edit Project Parameters so that the database refers to the name you use.

You should then start Visual Studio and open the CANADA-CI.sln solution in the root folder

The three principal packages which must be run before the project will be functional are:

**Create initial tables and views**: creates and imports the dimension and data tables. Destroys any previous data
**ImportMaps**: Imports the dimension tables
**ImportData**: Imports the data dables. 

You should then be able to connect to the SQL server using software of your choice. In the releases after September 2020, we've opted to create standalone (offline) excel workbooks which contain all the data. Since these are only 14MB or so in size, there's no point in forcing users to connect to an SQL server

# Known bugs/limitations
There may be missing data in the LFS monthly series. To be investigated
