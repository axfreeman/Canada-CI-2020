# Canada-Creative-Industries

This project contains SSIS modules and source data for the production of data on the creative industries in Canada.

# 14 August 2020
Project streamlined and prepared for connections with remote servers - see 'Change Tracking.docx'
# How to use this project
The project runs on Visual Studio (with SSIS tools, which have to be downloaded additionally to the main VS installation) and imports data from the /SOURCE DATA folder to an SQL server (R2012 or higher) of  your choosing. Having pulled the source from Github, you will need to change the following:

1. in Project Parameters, change the 'Root' parameter soit  direct to the root folder of your repository
2. In Project Parameters change 'ServerName' to refer to a SQL server in which you have CRUD rights
3. Create a database (if not already present) in your SQL server to contain the tables and views. We have named this CANADA_CI_OLTP but you can use any name you like. You should however edit Project Parameters so that the database refers to the name you use.

You should then start Visual Studio and open the CANADA-CI.sln solution in the root folder

The two principal packages which must be run before the project will be functional are:

ImportMaps: creates and imports the dimension tables. Note this destroys any previous dimension data
ImportData: creates and imports the data dables. Note this destroys any previous data in the main data table

These two packages are independent, except of course that if the dimension table fields are renamed, any corresponding fields in the data tables must also be renamed.

You should then be able to connect to the SQL server using software of your choice. Two prebuilt views may be helpful:

1. creative_industries maps industries to Creative Sectors as defined by UK DCMS in 2011
2.Industries (under development) provides more detail

# Known bugs/limitations
We are waiting for more up-to-date annual LFS data, and to update the data from the Productivity and Hours (P&H) series provided by Statscan. Monthly LFS data is available, but only for Manitoba and all Canada






