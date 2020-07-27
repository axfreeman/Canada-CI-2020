# Canada-Creative-Industries

This project contains SSIS modules and source data for the production of data on the creative industries in Canada.

# 5 July 2020
Project has been streamlined - see 'TODO 3 July' in TASKS folder
# How to use this project
The project runs on Visual Studio (with SSIS tools, which have to be downloaded additionally to the main VS installation) and imports data from the /SOURCE DATA folder to an SQL server (R2012 or higher) of  your choosing.
Having pulled the source from Github, you will need to change the following:

1. in Project Parameters, change the 'Scripts' and 'SourceData' parameters so they direct to the /SCRIPTS and /SOURCE DATA folders in your repository
2. Create a database (if not already present) in your SQL server to contain the tables and views. We have named this CANADA_CI_OLTP but you can use any name you like.
3. Edit the OLTP.conmgr connection manager to connect to your SQL server and to the database specified above

You should then start Visual Studio and open the CANADA-CI.sln solution in the root folder

Normally the packages should be executed in the following order:

Setup: drops any existing tables and views and creates new empty ones
Import maps: imports the dimension tables
Import source data: imports the data

You should then be able to connect to the SQL server using software of your choice. Two prebuilt views may be helpful:

1. CreativeIndustries maps industries to Creative Sectors as defined by UK DCMS in 2011 (Definition has changed somewhat since then)
2. MainIndustries maps industries to the standard Statscan Industries

# Known bugs
As of 5/7  data other than LFS data is only imported to the IOICC Flat table and is not yet integrated into the main fact file (and will not therefore show up in the two main queries)





