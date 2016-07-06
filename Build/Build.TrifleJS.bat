@ECHO OFF

:: Define variables

SET CompilePath=..\bin\Release
SET MergePath=.\Merge
SET BinaryPath=.\Binary
SET ILMerge=Tools\ILMerge.exe
SET Zip=Tools\7za.exe
SET MsBuild40=C:\Windows\Microsoft.NET\Framework\v4.0.30319\MsBuild.exe

:: Clean up last release

RMDIR /S /Q %CompilePath%
RMDIR /S /Q %MergePath%
DEL %BinaryPath%\*.* /Q /F
MKDIR %MergePath%
MKDIR %BinaryPath%

:: Run MSBuild

IF EXIST "%MsBuild40%" (
	SET "MsBuild=%MsBuild40%"
) ELSE (
	ECHO Cannot Find MsBuild!
	EXIT /b 1
)

ECHO Using MsBuild at %MsBuild%

%MsBuild% ..\TrifleJS.csproj /t:Rebuild /p:Configuration=Release

IF EXIST "%CompilePath%\TrifleJS.exe" (
	ECHO Compilation Ok!
) ELSE (
	ECHO Compilation Fail.
	EXIT /b 1	
)

:: Prepare & Zip Release
XCOPY %CompilePath%\*.* %MergePath% /Y /E
DEL %MergePath%\TrifleJS.exe /Q
DEL %MergePath%\Interop.IWshRuntimeLibrary.dll /Q
DEL %MergePath%\Interop.CERTENROLLLib.dll /Q
DEL %MergePath%\Interop.SHDocVw.dll /Q
DEL %MergePath%\Newtonsoft.Json.dll /Q

ECHO 
ECHO Merging and zipping to \Build\Binary directory. 
ECHO NOTE: This will take about 2 minutes..

%ILMerge% /out:%MergePath%\TrifleJS.exe %CompilePath%\TrifleJS.exe %CompilePath%\Interop.IWshRuntimeLibrary.dll %CompilePath%\Interop.CERTENROLLLib.dll %CompilePath%\Interop.SHDocVw.dll %CompilePath%\Newtonsoft.Json.dll
DEL %MergePath%\TrifleJS.pdb
CD %MergePath%
..\%Zip% a ..\Binary\TrifleJS.Latest.zip -r *.*
CD ..
RMDIR /S /Q %MergePath%

ECHO SUCCESS!!

