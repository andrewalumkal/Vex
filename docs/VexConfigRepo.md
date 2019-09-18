# VexConfigRepo

The config repository (tests / environments) is seperated by design so it can be source controlled independently.

## Folders:

### .\EnvironmentConfig
Contains Environment.json file. These are the list of environments/servers you would like to run your tests against.

##### Example:
```json
{
    "EnvironmentList": [
        {
            "EnvironmentName": "Prod1",
            "Servers": [ "prod1server" ]
        },
		
	{
            "EnvironmentName": "AllProdServers",
            "Servers": [ "prod1server", "prod2server", "prod3server" ]
        },
		
	{
            "EnvironmentName": "DatabaseServers",
            "Servers": [ "dbserver1", "dbserver2" ]
        },
		
	{
            "EnvironmentName": "WebServers",
            "Servers": [ "webserver1", "webserver2" ]
        }
    ]
}
```
### .\Tests
Test files that can be seperated into custom subfolders as required (ex: Team1, Team2). Tests need to have extention `.tests.ps1`
Tests need to be Pester tests. For more information, please see https://github.com/pester/Pester/wiki/Pester

Server list to run the tests against will be passed into the test at runtime.

##### Sample test against a database:
```powershell
######Required Parameter for all tests - $ServersToTest########
Param(
    $ServersToTest
)
###############################################################


$query = "select 1 as TestResult"

Describe "Return One from all servers"  {

	foreach ($server in $ServersToTest) {
		
		#Use context to log the target server name for each test in the output
		Context $server {
			It "Testing return one on server $server" {

				@(Invoke-Sqlcmd -ServerInstance $server -Query $query).TestResult | Should Be 1

			}
		}

	}
}
```

### .\TestConfig
Configuration for the test. Tests *will not run* unless it is configured within this folder in a `.config.json`
It is recommended to have the same folder structure as "Tests" folder to have seperate configuration for seperate teams/folders
**Config fields:**
- **Testfile:** The Folder\\FileName as it exists in `.\VexConfigRepo\Tests` (needs `\\` to properly escape backslash in json)
- **EnvironmentsToTest:** A list of environments to test. Vex will parse the Environments.json file for the list of environments and pass in a distinct serverlist to the test during runtime.
- **AlertOperator:** This field will be part of the test result output that is saved to the OutputTarget. Custom alerts can be configured based on this data.
- **Schedule:** Tag schedules for the tests so it can be called when running all tests for a specific schedule. Jobs can be configured to Invoke-VexTest on multiple schedules with different tags

##### Example usage:
```json
{
    "TestConfig": [
        {
            "TestFile": "Team1\\OneEqualsOne.tests.ps1",
            "EnvironmentsToTest": [ "localhost", "WebServers" ],
            "AlertOperator": "Team1",
            "Schedule": [ "Daily" ]
        },
		
	{
            "TestFile": "Team1\\Team1DatabaseTest.tests.ps1",
            "EnvironmentsToTest": [ "DatabaseServers" ],
            "AlertOperator": "Team1@myorg.com",
            "Schedule": [ "Weekly", "Hourly" ]
        }

    ]
}
```
