@echo off
set /p ipaddr=Enter IP Address:
:Test_runType
set /p runType=For batch run press(B) For test run press(T):
IF "%runType%" == "b" (
GOTO:Test_exeType_batch
) ELSE IF "%runType%" == "B" (
GOTO:Test_exeType_batch
) ELSE IF "%runType%" == "t" (
GOTO:Test_exeType_test
) ELSE IF "%runType%" == "T" (
GOTO:Test_exeType_test
) ELSE (
echo Enter a valid input
GOTO:Test_runType
)

:Test_exeType_batch
GOTO:processBatch

:Test_exeType_test
GOTO:processTest

:processBatch
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun_indi

:processTest
GOTO:testRun_indi

:testRun_indi
set /p projName=Enter Project name:
set /p testName=Enter Test name:
set batchName=individualRun
set boolBatch=no
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set HH=%TIME: =0%
set HH=%HH:~0,2%
set MI=%TIME:~3,2%
set SS=%TIME:~6,2%
set MS=%TIME:~9,3%
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
echo ----------------------
echo Running test Case...
echo ----------------------
curl -# --cookie cookies.txt --cookie-jar cookies.txt -H "Content-Type: application/octet-stream" -H "Content-Transfer-Encoding: Binary" -is "http://%ipaddr%:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
findstr /B "HTTP/1.1 500" jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=HTTP/1.1 500
IF "%valFound%" == "%condVal% " (GOTO:500) ELSE (GOTO:200)

:200
echo --------------------------
echo Test executed successfully
echo --------------------------
set testID=%mydate%%HH%%MI%%SS%%MS%
ren jumboTemp.txt %projName%_%testName%_%testID%.pdf
IF EXIST tempVal (del tempVal)
del cookies.txt
PAUSE
cls
GOTO :Test_runType


:500
echo Enter the valid input data...
break>jumboTemp.txt
GOTO:Test_runType

:batchRun_indi
set testName=batchRun
set boolBatch=yes
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
echo ----------------------
echo Running test Case...
echo ----------------------
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is "http://%ipaddr%:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
findstr /B "Batch run completed successfully..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=Batch run completed successfully...
IF "%valFound%" == "%condVal% " (GOTO:batch200)
findstr /B "HTTP/1.1 500" jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=HTTP/1.1 500
IF "%valFound%" == "%condVal% " (GOTO:batch500)
PAUSE
EXIT


:batch200
cls
echo ---------------------------------------
echo %valFound%                              
echo ---------------------------------------
echo ---------------------------------------------------------------
echo Downloading PDF reports for the executed test cases in batch...
echo ---------------------------------------------------------------
cd >> pathfile
set /p pathVal=<pathfile
for /f "skip=17 delims=*" %%a in (%pathVal%\jumboTemp.txt) do (
echo %%a >>%pathVal%\newfile.txt
)
xcopy %pathVal%\newfile.txt %pathVal%\jumboTemp.txt /y >nul
del %pathVal%\newfile.txt

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set HH=%TIME: =0%
set HH=%HH:~0,2%
set MI=%TIME:~3,2%
set SS=%TIME:~6,2%
set MS=%TIME:~9,3%
set testID=%mydate%%HH%%MI%%SS%%MS%
setlocal enabledelayedexpansion
set /a incrementer = 0
for /F "usebackq" %%a in ("%pathVal%\jumboTemp.txt") do (
IF "%%a" == "otherfiletype" (
CALL :otherfiletype
) ELSE IF "%%a" == "jsonvsjson" (
CALL :jsonvsjson
) ELSE IF "%%a" == "xmlvsxml" ( 
CALL :xmlvsxml
) ELSE (
set /a incrementer=incrementer+1
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is -H "Content-Type: application/json"  "http://%ipaddr%:8080/jumbo/downloadPDF/%projName%/%%a/!fileType!" -o %batchName%_!incrementer!.pdf
)
)

del jumboTemp.txt
del tempVal

curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt "http://%ipaddr%:8080/jumbo/getTestNamesForBatch/%batchName%/%projName%" -o TestNameList.txt
for /f "skip=1 delims=*" %%a in (TestNameList.txt) do (
echo %%a >>%pathVal%\newfile.txt
)
xcopy %pathVal%\newfile.txt %pathVal%\TestNameList.txt /y >nul
del %pathVal%\newfile.txt
del cookies.txt

set /a incrementerTest = 0
for /F "usebackq" %%a in ("%pathVal%\TestNameList.txt") do (
set /a incrementerTest=incrementerTest+1
ren %batchName%_!incrementerTest!.pdf %projName%_%%a_%testID%.pdf
)
del %pathVal%\TestNameList.txt
del pathfile
endlocal
msg * PDF reports downloaded successfully!!! in this path %pathVal%
PAUSE
cls
GOTO :Test_runType

:otherfiletype
set "fileType=other"
goto :EOF
:jsonvsjson
set "fileType=jsonvsjson"
goto :EOF
:xmlvsxml
set "fileType=xmlvsxml"
goto :EOF

:batch500
cls
echo -----------------------------
echo Enter the valid input data...
echo -----------------------------
PAUSE
GOTO:Test_runType
