$sb = {
    param($folders)
    $User = “Everyone”
    $Rules = “FullControl”
    $InheritType = "ContainerInherit,ObjectInherit"
    $AuditType = “Failure”
    #$hostn = $env:COMPUTERNAME
    $str="ops,note"
    Set-Content "report.csv" $str
    $data=""
    $data+=$str+"\n"
    
    foreach($folder in $folders){
        try
        {
            $ACL = $folder | Get-Acl -Audit -ErrorAction Stop
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($user,$Rules,$InheritType,"None",$AuditType)
            $ACL.SetAuditRule($AccessRule)
            $ACL | Set-Acl $Folder -ErrorAction Stop
            write-host "Setting Audit Rules on $folder"
            $str = $folder + ",Done"
            Add-Content "report.csv" $str
            $data+=$str+"\n"
        }
        catch
        {
            write-host  $_.Exception.Message
            $str = $folder + ","+ $_.Exception.Message
            Add-Content "report.csv" $str
            $data+=$str+"\n"
        }
    
    }
    $folder="HKLM:\SYSTEM\CurrentControlSet\Services\W3SVC"
    try
        {
            $ACL = $folder | Get-Acl -Audit -ErrorAction Stop
            $AccessRule = New-Object System.Security.AccessControl.RegistryAuditRule($user,$Rules,$InheritType,"None",$AuditType)
            $ACL.SetAuditRule($AccessRule)
            $ACL | Set-Acl $Folder -ErrorAction Stop
            write-host "Setting Audit Rules on $folder"
            $str = $folder + ",Done"
            Add-Content "report.csv" $str
            $data+=$str+"\n"
        }
        catch
        {
            write-host  $_.Exception.Message
            $str = $folder + ","+ $_.Exception.Message
            Add-Content "report.csv" $str
            $data+=$str+"\n"
        }
    
    try{
        $IISOpsLog = Get-WinEvent -ListLog Microsoft-IIS-Configuration/Operational -ErrorAction Stop
        $IISOpsLog.IsEnabled = $true
        $IISOpsLog.SaveChanges()
        $str = "IIS-Metabase-Operational,Done"
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }catch{
        $str = "IIS-Metabase-Operational,"+ $_.Exception.Message
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }
    try{
        $IISOpsLog = Get-WinEvent -ListLog Microsoft-IIS-Configuration/Administrative -ErrorAction Stop
        $IISOpsLog.IsEnabled = $true
        $IISOpsLog.SaveChanges()
        $str = "IIS-Metabase-Administrative,Done"
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }catch{
        $str = "IIS-Metabase-Administrative,"+ $_.Exception.Message
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }
    try{
        Set-WebConfigurationProperty -pspath 'IIS:\'  -filter "system.applicationHost/sites/siteDefaults/logFile" -name "logTargetW3C" -value "File,ETW" -ErrorAction Stop
        $str = "IIS-log-file-ETW,Done"
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }catch{
        $str = "IIS-log-file-ETW," + $_.Exception.Message
        Add-Content "report.csv" $str
        $data+=$str+"\n"
    }
    return $data
    }
    $folders =  Get-Content "paths.txt"
    Invoke-Command -ComputerName SEINT3208 -ScriptBlock $sb -ArgumentList $folders