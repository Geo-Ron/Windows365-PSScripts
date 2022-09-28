
<#PSScriptInfo

.VERSION 1.0.0.2

.GUID afa48b3c-60c5-42a6-9ae7-a8b8b59a3000

.AUTHOR Microsoft Corporation

.COMPANYNAME Microsoft Corporation

.COPYRIGHT (c) 2021 Microsoft Corporation. All rights reserved.

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 





<# 

.DESCRIPTION 
A PowerShell script to install additional languages machine-wide on Windows 10. After installing the desired languages through the script, you can capture this Windows 10 instance as a generalized image, use it as the base image for users' Cloud PCs, and have the languages readily available when they log in. 

To use this script for a Windows 365 custom device image, see the documentation site(https://go.microsoft.com/fwlink/?linkid=2172610).  

This PowerShell script is provided as-is. For any questions on using the script, see the Windows 365 Tech Community(https://aka.ms/w365tc). For any feedback to improve the script, see the Windows 365 Feedback page(https://aka.ms/w365feedback).  

This script supports the following versions of Windows 10: 
    • Windows 10, version 1903 
    • Windows 10, version 1909 
    • Windows 10, version 2004 
    • Windows 10, version 20H2
    • Windows 10, version 21H1
    • Windows 10, version 21H2

The script supports installing the following 38 languages: 
    • Arabic (Saudia Arabia) 
    • Bulgarian (Bulgaria) 
    • Czech (Czech Republic) 
    • Danish (Denmark) 
    • German (Germany) 
    • Greek (Greece) 
    • English (United Kingdom) 
    • English (United States) 
    • Spanish (Spain) 
    • Spanish (Mexico) 
    • Estonian (Estonia) 
    • Finnish (Finland) 
    • French (Canada) 
    • French (France) 
    • Hebrew (Israel) 
    • Croatian (Croatia) 
    • Hungarian (Hungary) 
    • Italian (Italy) 
    • Japanese (Japan) 
    • Korean (Korea) 
    • Lithuanian (Lithuania) 
    • Latvian (Latvia) 
    • Norwegian (Bokmål) (Norway) 
    • Dutch (Netherlands) 
    • Polish (Poland) 
    • Portuguese (Brazil) 
    • Portuguese (Portugal) 
    • Romanian (Romania) 
    • Russian (Russia) 
    • Slovak (Slovakia) 
    • Slovenian (Slovenia) 
    • Serbian (Latin, Serbia) 
    • Swedish (Sweden) 
    • Thai (Thailand) 
    • Turkish (Turkey) 
    • Ukrainian (Ukraine) 
    • Chinese (Simplified) 
    • Chinese (Traditional) 

#> 
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,
        Position = 0,
        ParameterSetName = "DefaultParameterSet",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Specify the language code.")]
    [Alias("lang")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Language = $null
)

Begin {
    #region Variable Declarations

    $downloadPath = "$env:SystemDrive\Users\$env:UserName\Downloads\"

    $languages = @("ar-SA", "bg-BG", "cs-CZ", "da-DK", "de-DE", "el-GR", "en-GB", "en-US", "es-ES",
        "es-MX", "et-EE", "fi-FI", "fr-CA", "fr-FR", "he-IL", "hr-HR", "hu-HU", "it-IT", "ja-JP", "ko-KR", "lt-LT",
        "lv-LV", "nb-NO", "nl-NL", "pl-PL", "pt-BR", "pt-PT", "ro-RO", "ru-RU", "sk-SK", "sl-SI", "sr-Cyrl-CS",
        "sv-SE", "th-TH", "tr-TR", "uk-UA", "zh-CN", "zh-TW")

    If ($PSBoundParameters.ContainsKey('Language') -eq $true) {
        foreach ($lang in $language) {
            If ($lang -notin $languages) {
                Write-Warning "Specified language $lang not supported."
                Write-Warning "Supported languages: $($languages -join ", ")"
                Break Script
            }
        }
    }

    $languagesDescription = @("Arabic (Saudi Arabia)", "Bulgarian (Bulgaria)", "Czech (Czech Republic)", "Danish (Denmark)", "German (Germany)", "Greek (Greece)", "English (United Kingdom)", "English (United States)", "Spanish (Spain)",
        "Spanish (Mexico)", "Estonian (Estonia)", "Finnish (Finland)", "French (Canada)", "French (France)", "Hebrew (Israel)", "Croatian (Croatia)", "Hungarian (Hungary)", "Italian (Italy)", "Japanese (Japan)", "Korean (Korea)", "Lithuanian (Lithuania)",
        "Latvian (Latvia)", "Norwegian (Bokmål) (Norway)", "Dutch (Netherlands)", "Polish (Poland)", "Portuguese (Brazil)", "Portuguese (Portugal)", "Romanian (Romania)", "Russian (Russia)", "Slovak (Slovakia)", "Slovenian (Slovenia)", "Serbian (Latin, Serbia)",
        "Swedish (Sweden)", "Thai (Thailand)", "Turkish (Turkey)", "Ukrainian (Ukraine)", "Chinese (Simplified)", "Chinese (Traditional)")

    $1903Files = @{
        'LanguagePack' = "https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"
        'FOD'          = "https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"
        'InboxApps'    = "https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_amd64fre_InboxApps.iso"
    }
    
    $1909Files = @{
        'LanguagePack' = 'https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_CLIENTLANGPACKDVD_OEM_MULTI.iso'
        'FOD'          = 'https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso'
        'InboxApps'    = 'https://software-download.microsoft.com/download/pr/18362.1.190318-1202.19h1_release_amd64fre_InboxApps.iso'
    }
    
    $2004Files = @{
        'LanguagePack' = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso'
        'FOD'          = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso'
        'InboxApps'    = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_InboxApps.iso'
    }
    
    $20H2Files = @{
        'LanguagePack' = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso'
        'FOD'          = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso'
        'InboxApps'    = 'https://software-download.microsoft.com/download/pr/19041.508.200905-1327.vb_release_svc_prod1_amd64fre_InboxApps.iso'
    }
    
    $21H1Files = @{
        'LanguagePack' = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso'
        'FOD'          = 'https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso'
        'InboxApps'    = 'https://software-download.microsoft.com/download/sg/19041.928.210407-2138.vb_release_svc_prod1_amd64fre_InboxApps.iso'
    }
    $1121H2Files = @{
        'LanguagePack' = 'https://software-download.microsoft.com/download/sg/22000.1.210604-1628.co_release_amd64fre_CLIENT_LOF_PACKAGES_OEM.iso'
    }
    
    
    $languageFiles = @{
        '101903' = $1903Files
        '101909' = $1909Files
        '102004' = $2004Files
        '1020H2' = $20H2Files
        '1021H1' = $21H1Files
        '1021H2' = $21H1Files
        '1121H2' = $1121H2Files
        '1122H2' = $1121H2Files
    }
    #endregion Variable Declarations

    #region FunctionDeclarations
    function ListSupportedLanguages() {
        foreach ($num in 1..$languages.Count) {
            Write-Host "`n[$num] $($languagesDescription[$num-1])"
        }
    }

    function DownloadFile($fileName, $url, $outFile) {
        Write-Output "Downloading $fileName file..." 
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $outFile
    }

    function DownloadLanguageFiles() {
        $files = $languageFiles[$OSPrefix + $winver]

        $space = 20
        foreach ($fileName in $files.Keys) {
            $fileUrl = $files[$fileName]
            $outFile = $downloadPath + $fileUrl.Split("/")[-1]
            if (Test-Path $outFile) {
                $space -= 5
            }
        }
    
        $CDrive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
        if ([Math]::Round($CDrive.FreeSpace / 1GB) -lt $space) {
            Write-Output "Not enough space. Install additional languages require $space GB free space, please try again after cleaning the disk."
            Break Script
        }

        foreach ($fileName in $files.Keys) {
            $fileUrl = $files[$fileName]
            $outFile = $downloadPath + $fileUrl.Split("/")[-1]

            if (!(Test-Path $outFile)) {
                DownloadFile $fileName $fileUrl $outFile
            }
        }
    }

    function GetOutputFilePath($fileName) {
        return $downloadPath + $languageFiles[$OSPrefix + $winver][$fileName].Split("/")[-1]
    }

    function MountFile($filePath) {
        $result = Mount-DiskImage -ImagePath $filePath -PassThru
        return ($result | Get-Volume).Driveletter
    }

    function DismountFile($filePath) {
        Dismount-DiskImage -ImagePath $filePath | Out-Null
    }

    function CleanupLanguageFiles() {
        Remove-Item (GetOutputFilePath 'LanguagePack')
        Remove-Item (GetOutputFilePath 'FOD')
        Remove-Item (GetOutputFilePath 'InboxApps')
    }

    function InstallLanguagePackage($languageCode, $driveletter) {
        Write-Output "Installing $languageCode language pack"

        $LIPContent = $driveLetter + ":"

        $lowerLanguageCode = $languageCode.ToLower()
        $packagePath = "$LIPContent\LocalExperiencePack\$lowerLanguageCode\LanguageExperiencePack.$languageCode.Neutral.appx"
        $licensePath = "$LIPContent\LocalExperiencePack\$lowerLanguageCode\License.xml"

        Add-AppProvisionedPackage -Online -PackagePath $packagePath -LicensePath $licensePath
        Add-WindowsPackage -Online -PackagePath $LIPContent\x64\langpacks\Microsoft-Windows-Client-Language-Pack_x64_$lowerLanguageCode.cab
    }

    function AddWindowsPackageIfExists ($filePath) {
        if (Test-Path $filePath) {
            Write-Output "Installing $filePath"
            Add-WindowsPackage -Online -PackagePath $filePath
        }
    }

    function InstallFOD($languageCode, $driveLetter) {
        Write-Output "Installing $languageCode FOD"

        $LIPContent = $driveLetter + ":"

        if ($languageCode -eq "zh-CN") {
            AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-Fonts-Hans-Package~31bf3856ad364e35~amd64~~.cab
        }

        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-Basic-$languagecode-Package~31bf3856ad364e35~amd64~~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-Handwriting-$languagecode-Package~31bf3856ad364e35~amd64~~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-OCR-$languagecode-Package~31bf3856ad364e35~amd64~~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-Speech-$languagecode-Package~31bf3856ad364e35~amd64~~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-LanguageFeatures-TextToSpeech-$languagecode-Package~31bf3856ad364e35~amd64~~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-MSPaint-FoD-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-PowerShell-ISE-FOD-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-Printing-WFS-FoD-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-StepsRecorder-Package~31bf3856ad364e35~amd64~$languagecode~.cab
        AddWindowsPackageIfExists $LIPContent\Microsoft-Windows-WordPad-FoD-Package~31bf3856ad364e35~amd64~$languagecode~.cab
    }

    function UpdateLanguageList($languageCode) {
        Write-Output "Adding $languageCode to LanguageList"

        $LanguageList = Get-WinUserLanguageList
        $LanguageList.Add($languageCode)
        Set-WinUserLanguageList $LanguageList -force
    }

    ###################################
    ## Update inbox apps for language##
    ###################################
    function InstallInboxApps() {
        Write-Output "Installing InboxApps"

        $file = GetOutputFilePath 'InboxApps'
        $driveletter = MountFile $file

        $AppsContent = $driveletter + ":\amd64fre"
        foreach ($App in (Get-AppxProvisionedPackage -Online)) {
            $AppPath = $AppsContent + $App.DisplayName + '_' + $App.PublisherId
            Write-Output "Handling $AppPath"
            $licFile = Get-Item $AppPath*.xml
            if ($licFile.Count) {
                $lic = $true
                $licFilePath = $licFile.FullName
            }
            else {
                $lic = $false
            }
            $appxFile = Get-Item $AppPath*.appx*
            if ($appxFile.Count) {
                $appxFilePath = $appxFile.FullName
                if ($lic) {
                    Add-AppxProvisionedPackage -Online -PackagePath $appxFilePath -LicensePath $licFilePath 
                }
                else {
                    Add-AppxProvisionedPackage -Online -PackagePath $appxFilePath -skiplicense
                }
            }
        }

        DismountFile $file
    }

    function InstallLanguageFiles($languageCode) { 
        $languagePackDriveLetter = MountFile (GetOutputFilePath 'LanguagePack')
        $fodDriveLetter = MountFile (GetOutputFilePath 'FOD')

        InstallLanguagePackage $languageCode $languagePackDriveLetter
        InstallFOD $languageCode $fodDriveLetter
        UpdateLanguageList $languageCode

        DismountFile (GetOutputFilePath 'LanguagePack')
        DismountFile (GetOutputFilePath 'FOD')

        InstallInboxApps
    }

    function Install($languageCode = $null) {
        try {
            
    
            If ($null -eq $languageCode) {
                ListSupportedLanguages
                $languageNumber = Read-Host "Select number to install language"
    
                if (!($languageNumber -in 1..$languages.Count)) {
                    Write-Host "Invalid language number." -ForegroundColor red
                    break
                }
    
                $languageCode = $languages[$languageNumber - 1]
            }
            else {
                #languageCode Remains
            }
    
            DownloadLanguageFiles 
            InstallLanguageFiles $languageCode
            CleanupLanguageFiles
        }
        catch {
            Write-Error $_
        }
    }
    #endregion FunctionDeclarations

}

Process {

    Foreach ($lang in $language) {

        If (!(test-path $downloadPath)) {
            New-Item -ItemType Directory -Force -Path $downloadPath
        }

        $currentWindowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $currentWindowsPrincipal = [Security.Principal.WindowsPrincipal]$currentWindowsIdentity
 
        if ( -not $currentWindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "Script needs to be run as Administrator." -ForegroundColor red
            Break Script
        }

        $currentOSbuildVersion = [System.Environment]::OSVersion.Version

        If ($currentOSbuildVersion.Major -eq 10 -and $currentOSbuildVersion.Build -lt 22000 -and $currentOSbuildVersion.Build -ge 10240) {
            $OSPrefix = '10'
        }
        elseif ($currentOSbuildVersion.Major -eq 10 -and $currentOSbuildVersion.Build -ge 22000) {
            $OSPrefix = '11'
        }

        $winver = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DisplayVersion')
        if (!$winver) {
            $winver = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseId')
        }

        if (!$languageFiles[$OSPrefix + $winver]) {
            Write-Host "Languages installer is not supportd Windows $winver." -ForegroundColor red
            Break Script
        }

        ##Disable language pack cleanup##
        Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"

        Write-Output "Install Windows $OSPrefix $winver languages:" 
        Install $lang
    }
}

End {}