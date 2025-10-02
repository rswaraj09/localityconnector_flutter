@echo off
cd %~dp0
echo Running Gradle task to get SHA-1...
call gradlew signingReport
echo.
echo Look for the SHA-1 value under "Variant: debug"
pause 