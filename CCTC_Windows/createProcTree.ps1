#Author: Humberto Nieves
#Date: July2017
#
#Description: PowerShell script written for the Army CCTC
#course. This will go through all of the processes and print
#out a tree showing parent and indented child processes.

Function GetRootProc ($rawProc) {   
    $rootProcList = @()
    foreach ($process in $rawProc){
        if ($process.processID -eq $process.ParentProcessId){
            $rootProcList += $process
        }
        if ($rawProc.processId -notcontains $process.ParentProcessId){
            $rootProcList += $process
        }
    }
    return $rootProcList
}

Function GetChildProc ($parent, $rawProc, $count){
    $level = "-" * $count
    foreach ($process in $rawProc){
        if ($process.processID -ne $process.ParentProcessId){
            if ($process.ParentProcessID -eq $parent.processID){
                if ($rawProc.ParentProcessId -contains $process.processId){
                    WriteFormatedOut ("$($level)$($process.processid)") $process.name $process.parentprocessid
                    GetChildProc $process $rawProc $($count + 1)
                }
                else{
                    WriteFormatedOut ("$($level)$($process.processid)") $process.name $process.parentprocessid
                }
            }
        } 
    }
}

Function WriteFormatedOut ($pidx, $namex, $ppidx){
    Write-Output "$('{0,-15}{1,-50}{2,5}' -f $pidx, $namex, $ppidx)"
}

Function Main {
    WriteFormatedOut "PID" "Name" "PPID"
    $rawProcList = Get-WmiObject win32_process | select ProcessID,ParentProcessID,name
    $rootProc = GetRootProc $rawProcList
    foreach ($proc in $rootProc){
        WriteFormatedOut $proc.processid $proc.name $proc.parentprocessid
        GetChildProc $proc $rawProcList 1
    }
}

Main