#Author: Humberto Nieves
#Date: July2017
#
#Description: PowerShell script written for the Army CCTC
#course. This will pull the running processes from TaskList, WMIC Process 
#(get-wmiobject win32_process) and the powershell Get-Process cmdlet.
#It will compare the three and look for any differences using Compare-Object.

#Get sorted list of PID, and Image Names from tasklist
$taskListDict = @{}
$rawTaskList = tasklist /NH

foreach ($line in $rawTaskList){
    $splitLine = $line -split "\s\s+"
    $taskListDict.add(($splitLine[1] -split "\s")[0],$splitLine[0])
}

$sortedTaskList = $(foreach ($key in $taskListDict.keys){Write-Output "$($key) `t $($taskListDict[$key])"}) | SORT
$pidTaskList = $(foreach ($key in $taskListDict.keys){Write-Output "$($key)"}) | SORT
$sortedTasklist = $sortedTaskList[1..$sortedTaskList.Length]
$pidTasklist = $pidTaskList[1..$pidTaskList.Length]

#Get sorted list of PID, and Image Name from WMIC Process
$rawWMICProc = Get-WmiObject -class win32_process | select processId,name
$sortedWMICProc = $(foreach ($item in $rawWMICProc){ write-output "$($item.processid) `t $($item.name)"}) | sort
$pidWMICProc = $(foreach ($item in $rawWMICProc){ write-output "$($item.processid)"}) | sort

#Get sorted lists of PID and Process name from PS Get-Process
$rawPSProc = Get-Process | select ID,ProcessName
$sortedPSProc = $(foreach ($item in $rawPSProc){ write-output "$($item.id) `t $($item.Processname)"}) | sort
$pidPSProc = $(foreach ($item in $rawPSProc){ write-output "$($item.id)"}) | sort


Write-Output "`n Task List Processes: $($sortedTaskList.length) `n WMIC Processes: $($sortedWMICProc.length) `n PS Processes: $($sortedPSProc.length) `n"

Write-Output "Comparing Tasklist Output to WMIC Process Output: `n"
$comparison = Compare-Object $pidTaskList $pidWMICProc
foreach ($item in $comparison){
    if ($item.SideIndicator -eq "<="){
        write-output "-PID Found Only in Tasklist: $($item.inputobject)"
    }
    else{
        write-output "-PID Found Only in WMIC Processes: $($item.inputobject)"
    }
}
write-output "`n"
Write-Output "Comparing WMIC Process Output to PS Get-Process: `n"
$comparison = Compare-Object $pidWMICProc $pidPSProc
foreach ($item in $comparison){
    if ($item.SideIndicator -eq "<="){
        write-output "-PID Found Only in WMIC Process: $($item.inputobject)"
    }
    else{
        write-output "-PID Found Only in PS Get-Process: $($item.inputobject)"
    }
}

write-output "`n"
Write-Output "Comparing TaskList to PS Get-Process: `n"
$comparison = Compare-Object $pidTaskList $pidPSProc
foreach ($item in $comparison){
    if ($item.SideIndicator -eq "<="){
        write-output "-PID Found Only in TaskList: $($item.inputobject)"
    }
    else{
        write-output "-PID Found Only in PS Get-Process: $($item.inputobject)"
    }
}