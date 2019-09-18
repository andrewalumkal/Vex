# Vex
Test runner built on Pester with scheduling and logging support

Requires the `Pester` module. Optionally will also require `SqlServer` and `OMSIngestionAPI` modules if saving output to OMS / SQL Server.

## Example Usage

Import the module.

```powershell
Import-Module .\src\Vex -Force
```

The config repository (tests / environments) is seperated by design so it can be source controlled independently. Set the path to the Config repository
```powershell
$ConfigRepoPath = "C:\src\VexConfigRepo"
```

Run all tests with default parameters
```powershell
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath
```

Run all tests tagged with "Daily" schedule
```powershell
$Schedule = "Daily"
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath -RunType "schedule" -RunTypeParams $Schedule -OutputTarget "None" -Show All
```

Run specific tests
```powershell
$TestList = ("Team1\OneEqualsOne.tests.ps1", "Team2\TwoEqualsTwo.tests.ps1")
Invoke-VexTest -ConfigRepoPath $ConfigRepoPath -RunType "TestList" -RunTypeParams $TestList -Show All
```
