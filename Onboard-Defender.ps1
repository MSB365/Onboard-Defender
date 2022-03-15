<#     
       .NOTES
       ==============================================================================
       Created on:         2022/03/15 
       Created by:         Drago Petrovic
       Organization:       MSB365.blog
       Filename:           Onboard-Defender.ps1
       Current version:    V1.00     
       Find us on:
             * Website:         https://www.msb365.blog
             * Technet:         https://social.technet.microsoft.com/Profile/MSB365
             * LinkedIn:        https://www.linkedin.com/in/drago-petrovic/
             * MVP Profile:     https://mvp.microsoft.com/de-de/PublicProfile/5003446
       ==============================================================================
       .DESCRIPTION
       This script gets the onboarding settings that are previously downloaded to a file share and onboards the device to the Microsoft security center.            
       
       .NOTES
       Prerequisits are to download the generated onboarding ZIP file from Microsoft.
       Go to:
       https://security.microsoft.com
       In the navigation pane, choose Settings > Endpoints, and then under Device management, choose Onboarding.
       Select an operating system, such as Windows 10 or 11 or, and then, in the Deployment method section, choose Local script.
       Select Download onboarding package.
        
       .EXAMPLE
       .\Onboard-Defender.ps1
             
       .COPYRIGHT
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
       to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
       and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
       WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
       ===========================================================================
       .CHANGE LOG
             V1.00, 2022/03/15 - DrPe - Initial version

			 
--- keep it simple, but significant ---
--- by MSB365 Blog ---
#>




# Set variable
$Source = $(Write-Host "Enter Network path where the onboardin ZIP is located. Example: " -NoNewLine) + $(Write-Host """" -NoNewline) +$(Write-Host "\\MSB365-LAB-DC01\TestShare1" -ForegroundColor Yellow -NoNewline; Read-Host """")


######################
cls
# Check or create MDM Directory
$directory1 = "C:\MDM\Defender_onboarding"
Write-Host "Checking if $directory1 is available..." -ForegroundColor Magenta
Start-Sleep -s 1
If ((Test-Path -Path $directory1) -eq $false)
{
        Write-Host "The Directory $directory1 don't exists!" -ForegroundColor Cyan
        Start-Sleep -s 2
        Write-Host "Creating directory $directory1 ..." -ForegroundColor Cyan
        Start-Sleep -s 2
        New-Item -Path $directory1 -ItemType directory
        Start-Sleep -s 2
        Write-Host "New Directory $directory1 is is created" -ForegroundColor Green
        Start-Sleep -s 2
}else{
Write-Host "The Path $directory1 already exists" -ForegroundColor green
Start-Sleep -s 3
}


######################
# Collecting Domain information
$File1 = Get-ChildItem -Path $Source\*.zip | fl Name 


Write-Host "Downloading onboading ZIP file for Windows..." -ForegroundColor Cyan
Start-Sleep -s 2
Copy-Item -Path $Source\*.zip -Destination $directory1 -Force
Start-Sleep -s 2
Write-Host "The onboarding ZIP file is copied to $directory1" -ForegroundColor Green
Start-Sleep -s 2

Write-Host "Expanding ZIP file in $directory1..." -ForegroundColor Cyan
Start-Sleep -s 2
IF ((Test-Path -Path $directory1\WindowsDefenderATPOnboardingPackage.cmd) -eq $false)
{
        Expand-Archive -LiteralPath $directory1\WindowsDefenderATPOnboardingPackage.Zip -DestinationPath $directory1
        Start-Sleep -s 2
        Write-Host "Done!" -ForegroundColor Green
        Start-Sleep -s 2
}else{
Write-Host "The File WindowsDefenderATPLocalOnboardingScript.cmd already exists" -ForegroundColor green
Start-Sleep -s 3
}



######################
Write-Host "Starting onboarding progress..." -ForegroundColor Cyan
Start-Sleep -s 2
Write-Host "NOTE! The command Prompt needs to be run as Administrator, if this is not the case you can start the CMD batch manually!" -ForegroundColor Yellow -BackgroundColor Black


######################
$TNlink = Read-Host -Prompt "Would you like to run the onboarding CMD [M]anually or [A]utomatically? [M] | [A]"
if ($TNlink -eq 'm') {
    $directory2 = "C:\MDM\Defender_onboarding\manually"
Write-Host "Checking if $directory1 is available..." -ForegroundColor Magenta
Start-Sleep -s 1
If ((Test-Path -Path $directory2) -eq $false)
{
        Write-Host "The Directory $directory2 don't exists!" -ForegroundColor Cyan
        Start-Sleep -s 2
        Write-Host "Creating directory $directory2 ..." -ForegroundColor Cyan
        Start-Sleep -s 2
        New-Item -Path $directory2 -ItemType directory
        Start-Sleep -s 2
        Write-Host "New Directory $directory2 is is created" -ForegroundColor Green
        Start-Sleep -s 2
}else{
Write-Host "The Path $directory2 already exists" -ForegroundColor green
Start-Sleep -s 3
}
Copy-Item "$directory1\WindowsDefenderATPLocalOnboardingScript.cmd" -Destination $directory2

    explorer.exe $directory2
} else {
    "continuing script..."
    cmd /c $directory1\WindowsDefenderATPLocalOnboardingScript.cmd
}


# TMP informaiton
#New-PSDrive -Name "T" -Root "\\MSB365-LAB-DC01\TestShare1" -Persist -PSProvider "FileSystem"
#$Dom1 = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain
