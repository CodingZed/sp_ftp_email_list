# sp_ftp_email_list
Connect to data warehouse, create historical data stored procedure, Manipulate data and save the file in ftp location, Set up the email list in MS azure

Issue
In Prisma, we don't have histroical data. Everyday, the new data will hover over the old one. We need a system to help us store historical data. Meanwhile, we will create a file and deliver to the right member in the team to check the input from Prisma.

Solution
1. Create queries in sql server as well as stored procedure
2. Connect to pyodbc and manipulate the data in the right layout and schema
3. Output the data in excel file and store it in FTP location
4. Pull the file in the FTP and create the email list in MS Azure
