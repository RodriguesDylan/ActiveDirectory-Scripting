<#
================================================================================
 Script        : List-ScheduledTasks.ps1
 Description   : List scheduled tasks in System32\Tasks in a desktop file named "TaskLog.csv"
 Author        : Dylan Rodrigues 
 Created on    : 12/03/2025
 Version       : v1.0
 Last update   : 12/03/2025

================================================================================
#>

Import-Module ActiveDirectory
$VerbosePreference = "continue"
$list = (Get-ADComputer -LDAPFilter "(&(objectcategory=computer)(OperatingSystem=*server*))").Name
Write-Verbose  -Message "Trying to query $($list.count) servers found in AD"
$logfilepath = "$home\Desktop\TasksLog.csv"
$ErrorActionPreference = "SilentlyContinue"

foreach ($computername in $list)
{
    $path = "\\" + $computername + "\c$\Windows\System32\Tasks"
    $tasks = Get-ChildItem -Path $path -File

    if ($tasks)
    {
        Write-Verbose -Message "I found $($tasks.count) tasks for $computername"
    }

    foreach ($item in $tasks)
    {
        $AbsolutePath = $path + "\" + $item.Name
        $task = [xml] (Get-Content $AbsolutePath)
        [STRING]$check = $task.Task.Principals.Principal.UserId

        if ($task.Task.Principals.Principal.UserId)
        {
          Write-Verbose -Message "Writing the log file with values for $computername"           
          Add-content -path $logfilepath -Value "$computername,$item,$check"
        }

    }
}