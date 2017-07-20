#Author: Humberto Nieves
#Date: July2017
#
#Description: PowerShell script written for the Army CCTC
#course. This will list all unique DLLs currently loaded
#and being used. Basically using the Get-Process command
#to get the information then adding it to a dictionary with
#the key being the path to the DLL and the value being the filename
#then sorts it and prints it to screen

$uniqueModules = @{}
$procList = (get-process).id
foreach ($id IN $procList){
	$module = ((get-process -id $id).modules)
	
	if ($module.size -gt 0) {
		foreach ($moduleName IN $module){
			if ($moduleName.ModuleName -like "*.dll"){
				if (!$uniqueModules.contains($moduleName.Filename)){
					$uniqueModules.add($moduleName.FileName, $moduleName.ModuleName)
				}
			}
		}
	}	
}

$(foreach($key in $uniqueModules.keys) {Write-output "DLL: $($uniqueModules[$key]) `n `t Path: $($key) `n"}) | Sort
