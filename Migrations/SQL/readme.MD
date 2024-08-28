**1. Download and install SQLPackage**

First download the latest version from here [Download and install SqlPackage - SQL Server | Microsoft Learn](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver16&ref=mattmansoomi.com#windows-net-framework)

After installing SQLPackage go to the installed folder C:\Program Files\Microsoft SQL Server\160\DAC\bin, You need to run CMD from this location.

<IMG  src="https://www.mattmansoomi.com/content/images/2022/10/image-3.png"/>


Before you starting I suggest to check “Set server firewall” and make sure your IP is in the firewall rules.

**2. Export Database**

Export with the following command, You only need to replace your path, server and database name as well as username and password to connect to the database.

`SqlPackage /Action:Export /TargetFile:"C:\SQLPackageFiles\ExportHere.bacpac" /df:"C:\SQLPackageFiles\log.txt" /SourceConnectionString:"Server=tcp:xxx.database.windows.net,1433;Initial Catalog=YourDatabaseNameHere;Persist Security Info=False;User ID=YourUserName;Password=YourPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"`

<IMG  src="https://www.mattmansoomi.com/content/images/2022/10/image-5.png"/>

**3. Import the database to new subscription/ tenants**

For import new database in the target you do not need to create or prepare anything, the only thing you need to run the following command and put your parameter there!

`SqlPackage /Action:Import /SourceFile:"C:\SQLPackageFiles\ExportHere.bacpac" /df:"C:\SQLPackageFiles\log_import.txt" /TargetConnectionString:"Server=tcp:YourTargetServerName.windows.net,1433;Initial Catalog=MyNewDatabase;Persist Security Info=False;User ID=YourUserName;Password=YourPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"`

After only 3 minutes I restored the database in the target, If I go to the portal I can see my new database has been created.
<IMG  src="https://www.mattmansoomi.com/content/images/2022/10/image-6.png"/>

Reference document: https://www.mattmansoomi.com/how-to-copy-azure-sql-database-between-tenants-or-subscriptions/






