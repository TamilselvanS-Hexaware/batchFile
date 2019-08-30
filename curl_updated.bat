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
set /p processType=For individual batch run press(I) For Parallel batch run press(P):
GOTO:processBatch

:Test_exeType_test
set /p processType=For individual test run press(I) For Parallel test run press(P):
GOTO:processTest

:processBatch
IF "%processType%" == "i" (
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun_indi
) ELSE IF "%processType%" == "I" (
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun_indi
) ELSE IF "%processType%" == "p" (
set /p projName=Enter Project name:
set /p batchName=Enter Batch names in comma seperated format:
GOTO:batchRun_parallel
) ELSE IF "%processType%" == "P" (
set /p projName=Enter Project name:
set /p batchName=Enter Batch names in comma seperated format:
GOTO:batchRun_parallel
) ELSE (
echo Enter a valid input
GOTO:Test_exeType_batch
)

:processTest
IF "%processType%" == "i" (
GOTO:testRun_indi
) ELSE IF "%processType%" == "I" (
GOTO:testRun_indi
) ELSE IF "%processType%" == "p" (
GOTO:testRun_parallel
) ELSE IF "%processType%" == "P" (
GOTO:testRun_parallel
PAUSE
) ELSE (
echo Enter a valid input
GOTO:Test_exeType_test
)

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
curl -# --cookie cookies.txt --cookie-jar cookies.txt -H "Content-Type: application/octet-stream" -H "Content-Transfer-Encoding: Binary" -is "http://%ipaddr%:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
findstr /B "HTTP/1.1 500" jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=HTTP/1.1 500
IF "%valFound%" == "%condVal% " (GOTO:500) ELSE (GOTO:200)

:200
echo Test executed successfully
set testID=%mydate%%HH%%MI%%SS%%MS%
ren jumboTemp.txt %projName%_%testName%_%testID%.pdf
IF EXIST tempVal (del tempVal)
del cookies.txt
PAUSE
EXIT

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

:batchRun_parallel
set testName=parallelRun
set boolBatch=yes
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is "http://%ipaddr%:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
PAUSE
EXIT


:testRun_parallel
set /p projName=Enter Project name:
set /p testName=Enter Test names in a comma seperated format:
set batchName=parallelRun
set boolBatch=no
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set HH=%TIME: =0%
set HH=%HH:~0,2%
set MI=%TIME:~3,2%
set SS=%TIME:~6,2%
set MS=%TIME:~9,3%
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
curl --progress-bar --cookie cookies.txt --cookie-jar cookies.txt -H "Content-Type: application/octet-stream" -H "Content-Transfer-Encoding: Binary" -i "http://%ipaddr%:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
findstr /B "HTTP/1.1 500" jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=HTTP/1.1 500
IF "%valFound%" == "%condVal% " (GOTO:parallel500)

findstr /B "Check the comma seperations in the test cases..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=Check the comma seperations in the test cases...
IF "%valFound%" == "%condVal% " (GOTO:err_output)

findstr /B "Provide the test data correctly..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=Provide the test data correctly...
IF "%valFound%" == "%condVal% " (GOTO:err_output)

findstr /B "Test case count exceeded... Give only three test cases to execute..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=Test case count exceeded... Give only three test cases to execute...
IF "%valFound%" == "%condVal% " (GOTO:err_output)

findstr /B "Test cases are already running in the stack... wait for some time..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=Test cases are already running in the stack... wait for some time...
IF "%valFound%" == "%condVal% " (GOTO:err_output)

findstr /B "All test cases executed successfully..." jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=All test cases executed successfully...
IF "%valFound%" == "%condVal% " (GOTO:parallel200)

findstr /B "HTTP/1.1 200" jumboTemp.txt >tempVal
IF EXIST tempVal (set /p "valFound="<tempVal)
set condVal=HTTP/1.1 200
IF "%valFound%" == "%condVal% " (
set valFound=All test cases executed successfully... 
GOTO:parallel200)

:err_output
cls
echo ---------------------------------------------------------------------
echo %valFound%
echo ---------------------------------------------------------------------
GOTO:Test_runType

:parallel200
cls
echo ---------------------------------------------------------------------
echo %valFound%
echo ---------------------------------------------------------------------
del cookies.txt
PAUSE
EXIT

:parallel500
cls
echo -----------------------------
echo Enter the valid input data...
echo -----------------------------
GOTO:Test_runType

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
setlocal enabledelayedexpansion
for /F "usebackq" %%a in ("%pathVal%\jumboTemp.txt") do (
IF "%%a" == "txt" (
CALL :txt
) ELSE IF "%%a" == "jsonvsjson" (
CALL :jsonvsjson
) ELSE IF "%%a" == "xmlvsxml" ( 
CALL :xmlvsxml
) ELSE (
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://%ipaddr%:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is -H "Content-Type: application/json"  "http://%ipaddr%:8080/jumbo/downloadPDF/%projName%/%%a/!fileType!" -o %%a.pdf
)
)
endlocal
)
del jumboTemp.txt
del pathfile
del tempVal
del cookies.txt
msg * PDF reports downloaded successfully!!! in this path %pathVal%
EXIT

:txt
set "fileType=csv"
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