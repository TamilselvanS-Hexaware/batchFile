@echo off
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
echo Provide data to run individual batch(%processType%)
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun_indi
) ELSE IF "%processType%" == "I" (
echo Provide data to run individual batch(%processType%)
set /p projName=Enter Project name:
set /p batchName=Enter Batch name:
GOTO:batchRun_indi
) ELSE IF "%processType%" == "p" (
echo %processType%
PAUSE
) ELSE IF "%processType%" == "P" (
echo %processType%
PAUSE
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
echo Provide data to run individual test(%processType%)
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
GOTO:Test_runType

:batchRun_indi
set testName=batchRun
set boolBatch=yes
curl --cookie-jar cookies.txt -L --data "secret=secret_password" --header "Content-Type: application/x-www-form-urlencoded" --request POST --data "username=administrator&password=Password123" http://localhost:8080/jumbo/login
curl -# --cookie cookies.txt --cookie-jar cookies.txt -is "http://localhost:8080/jumbo/jumboAPICall/%projName%/%testName%/%boolBatch%/%batchName%" -o jumboTemp.txt
set /p outVal=<jumboTemp.txt
echo %outVal%
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
GOTO:Test_runType