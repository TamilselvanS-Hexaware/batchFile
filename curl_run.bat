@echo off
:Test_credentials
set /p boolBatchBash=Do you want to perform a Batch run(y/n): 

IF "%boolBatchBash%" == "y" (
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun
) ELSE IF "%boolBatchBash%" == "n" (
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
GOTO:testRun

) ELSE IF "%boolBatchBash%" == "Y" (
set /p projName=Enter Project name: 
set /p batchName=Enter Batch name: 
set testName=batch Run
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://localhost:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt "http://localhost:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
set /p "outVal="<jumboTemp.txt
echo %outVal%
PAUSE
PAUSE
) ELSE IF "%boolBatchBash%" == "N" (
set /p projName=Enter Project name:
set /p testName=Enter Test names with comma seperated:
set batchName=parallelRun

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set HH=%TIME: =0%
set HH=%HH:~0,2%
set MI=%TIME:~3,2%
set SS=%TIME:~6,2%
set MS=%TIME:~9,3%
GOTO:parallelTestRun
) ELSE (
echo Enter a valid input
GOTO:Test_credentials)

:batchRun
set testName=batchRun
set boolBatch=yes
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://localhost:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is "http://localhost:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
set /p outVal=<jumboTemp.txt
echo %outVal%
PAUSE
EXIT

:testRun
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://localhost:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -H "Content-Type: application/octet-stream" -H "Content-Transfer-Encoding: Binary" -v -is "http://localhost:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
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
GOTO:Test_credentials

:parallelTestRun
set boolBatch=no
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://localhost:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -H "Content-Type: application/octet-stream" -H "Content-Transfer-Encoding: Binary" -is -v "http://localhost:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
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
GOTO:Test_credentials
