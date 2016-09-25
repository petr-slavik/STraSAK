﻿param([String]$StudioVersion = "Studio4")

if ("${Env:ProgramFiles(x86)}")
{
    $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
}
else
{
    $ProgramFilesDir = "${Env:ProgramFiles}"
}

Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.ProjectAutomation.FileBased.dll";
Add-Type -Path "$ProgramFilesDir\SDL\SDL Trados Studio\$StudioVersion\Sdl.ProjectAutomation.Core.dll";

function New-Package
{
	param([Sdl.Core.Globalization.Language] $language,[String] $packagePath, [Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToProcess,
		[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions)
	
	#$today = Get-Date;
	$packageDueDate = [DateTime]::MaxValue;
	$packageName = $projectToProcess.GetProjectInfo().Name + "_" + $targetLanguage.IsoAbbreviation;
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]] $taskFiles =  Get-TaskFileInfoFiles $language $projectToProcess;
#	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $today +1 ,$taskFiles);
	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $packageDueDate, $taskFiles);
	[Sdl.ProjectAutomation.Core.ProjectPackageCreation] $package = $projectToProcess.CreateProjectPackage($task.Id, $packageName,
                "A package created by the API", $packageOptions);
	$projectToProcess.SavePackageAs($package.PackageId, $packagePath);
}

function Get-PackageOptions
{
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = New-Object Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions;
	$packageOptions.IncludeAutoSuggestDictionaries = $false;
	$packageOptions.IncludeMainTranslationMemories = $false;
	$packageOptions.IncludeTermbases = $false;
	$packageOptions.ProjectTranslationMemoryOptions = [Sdl.ProjectAutomation.Core.ProjectTranslationMemoryPackageOptions]::UseExisting;
	$packageOptions.RecomputeAnalysisStatistics = $false;
	$packageOptions.RemoveAutomatedTranslationProviders = $true;
	return $packageOptions;
}

function New-PackageOptions
{
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = New-Object Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions;
	return $packageOptions;
}


Export-ModuleMember New-Package;
Export-ModuleMember New-PackageOptions;
Export-ModuleMember Get-PackageOptions;
