<#
================================================================================
 Script        : Get-ADinfo.ps1
 Description   : List information about current Active Directory Domain (number of objects, levels, etc...)
 Author        : Dylan Rodrigues 
 Created on    : 12/03/2025
 Version       : v1.0
 Last update   : 12/03/2025

================================================================================
#>

# Get counts of different types of objects in Active Directory
$Computers = (Get-ADComputer -Filter * | Measure-Object).Count
$Workstations = (Get-ADComputer -Filter { OperatingSystem -notlike "*Server*" } | Measure-Object).Count
$Servers = (Get-ADComputer -Filter { OperatingSystem -like "*Server*" } | Measure-Object).Count
$Users = (Get-ADUser -Filter * | Measure-Object).Count
$Groups = (Get-ADGroup -Filter * | Measure-Object).Count
$DomainControllers = (Get-ADDomainController -filter * | Measure-Object).Count

# Get Active Directory Forest information
$ADForest = (Get-ADDomain).Forest
$ADForestMode = (Get-ADForest).ForestMode
$ADDomainMode = (Get-ADDomain).DomainMode

# Obtain Active Directory Schema version and translate it to the corresponding Windows Server version
$ADVer = Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select-Object objectVersion
$ADNum = $ADVer -replace "@{objectVersion=", "" -replace "}", ""
If ($ADNum -eq '88') { $srv = 'Windows Server 2019/Windows Server 2022' }
ElseIf ($ADNum -eq '87') { $srv = 'Windows Server 2016' }
ElseIf ($ADNum -eq '69') { $srv = 'Windows Server 2012 R2' }
ElseIf ($ADNum -eq '56') { $srv = 'Windows Server 2012' }
ElseIf ($ADNum -eq '47') { $srv = 'Windows Server 2008 R2' }
ElseIf ($ADNum -eq '44') { $srv = 'Windows Server 2008' }
ElseIf ($ADNum -eq '31') { $srv = 'Windows Server 2003 R2' }
ElseIf ($ADNum -eq '30') { $srv = 'Windows Server 2003' }

# Display collected information
Write-host "Active Directory Info" -ForegroundColor Yellow
Write-host ""
Write-Host "Computers  = $Computers" -ForegroundColor Cyan
Write-Host "Workstions = $Workstations" -ForegroundColor Cyan
Write-Host "Servers    = $Servers" -ForegroundColor Cyan
Write-Host "Users      = $Users" -ForegroundColor Cyan
Write-Host "Groups     = $Groups" -ForegroundColor Cyan
Write-Host "DCs        = $DomainControllers" -ForegroundColor Cyan
Write-host ""
Write-Host "Active Directory Forest Name = "$ADForest -ForegroundColor Cyan
Write-Host "Active Directory Forest Mode = "$ADForestMode -ForegroundColor Cyan
Write-Host "Active Directory Domain Mode = "$ADDomainMode -ForegroundColor Cyan
Write-Host "Active Directory Schema Version is $ADNum which corresponds to $srv" -ForegroundColor Cyan
Write-Host ""


# Display list of DC

$DomainControllersNames = Get-ADDomainController -Filter * | Select hostname

Write-Host "Domain Controllers Names :" -ForegroundColor Cyan
Write-Host($DomainControllersNames.hostname -join "`n") -ForegroundColor Cyan
Write-Host ""

# Retrieve FSMO roles individually
Write-Host "FSMO Role Owners" -ForegroundColor Cyan
Write-Host ""
$Forest = Get-ADForest
$SchemaMaster = $Forest.SchemaMaster
$DomainNamingMaster = $Forest.DomainNamingMaster
$Domain = Get-ADDomain
$RIDMaster = $Domain.RIDMaster
$PDCEmulator = $Domain.PDCEmulator
$InfrastructureMaster = $Domain.InfrastructureMaster

# Display FSMO role owners
Write-Host "Schema Master         =  $SchemaMaster" -ForegroundColor Cyan
Write-Host "Domain Naming Master  =  $DomainNamingMaster" -ForegroundColor Cyan
Write-Host "RID Master            =  $RIDMaster" -ForegroundColor Cyan
Write-Host "PDC Emulator          =  $PDCEmulator" -ForegroundColor Cyan
Write-Host "Infrastructure Master =  $InfrastructureMaster" -ForegroundColor Cyan