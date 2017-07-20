#Author: Humberto Nieves
#Date: July2017
#
#Description: PowerShell script written for the Army CCTC
#course. This will enumerate all users on the local machine 
#and the groups that they are in using only the "net" family
#of commands and string manipulation.

$userList = @()
$userDict = @{}

#Get output string fromt he "net user" command
$users = net user

#Go through each line looking for the string of users
#that are separated by a series of repeating spaces
#and putting them into an array and removing the empty
#entries.

foreach ($line in $users[4..($users.Length - 3)]){
    $tempUsers = $line -split "\s+"
    $cleanUsers = $tempUsers.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
    foreach ($user in $cleanUsers){
        $userList += $user
    }
}

#Go through each user in the list and and get the
#values listed in the Local Groups and Global Groups

foreach ($user in $userList){
    $userDetail = net user $user
    $index = 0
    $localGroups = @()
    $globalGroups = @()

     while ($index -lt $userDetail.length){
        if ($userDetail[$index] -like "Local Group*"){
            $startLocalGroup = $index
        }
        elseif ($userDetail[$index] -like "Global Group*"){
            $startGlobalGroup = $index
        }
        $index = $index + 1
    }
    foreach ($line in $userDetail[$startLocalGroup .. ($startGlobalGroup - 1)]){
        $tempLine = $line.split("*")
        $localGroups += $tempLine[1..($tempLine.length - 1)]
        
    }

    foreach ($line in $userDetail[$startGlobalGroup .. ($userDetail.length - 3)]){
        $tempLine = $line.split("*")
        $globalGroups += $tempLine[1..($tempLine.length - 1)]
        
    }

    #Write for all of the users onto the screen.

    write-output "User: '$($user)' in Local Groups: "
    foreach ($lgroup in $localGroups) {"`t $($lGroup)"} 
    write-output "User: '$($user)' in Global Groups: "
    foreach ($ggroup in $globalGroups) {"`t $($gGroup)"}
    write-output "`n`n" 
}

#Cycle through all of the groups in localgroup and list the users
#in each group.

$localGroupList = net localgroup
$localGroups = $localGroupList[4..($localGroupList.length-3)]
$localGroups = $localGroups.split("*", [System.StringSplitOptions]::RemoveEmptyEntries)
$localGroupDict = @{}

#Cycle through each group and identify what is available in the
#members section. If the members section is blank write none.
foreach ($group in $localGroups){
    $members = net localgroup $group
    $index = 0
    while ($index -lt $members.length){
        if($members[$index] -like ("--*")){
            
            $startMember = $index + 1
        }
        elseif($members[$index].contains("completed successfully")){
            
            $endMember = $index
        }
        $index = $index + 1
    }

    if ($startMember -eq $endMember){
        $members = "None"
    }
    else{
        $members = $members[6..($members.length - 3)]
    }
    $localGroupDict.add($group,$members)
    
}

foreach ($key in $localGroupDict.keys){
    write-output "LocalGroup: '$($key)'  Users: $(foreach ($user in $localgroupDict[$key]){write-output "`n `t $($user)"}) `n"
}