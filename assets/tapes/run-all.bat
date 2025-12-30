@echo off
echo Running all VHS tape files...
echo.

for %%f in (*.tape) do (
    echo === Running: %%f ===
    start /wait cmd /c "vhs "%%f""
    echo Completed: %%f
    echo Waiting 3 seconds before next to prevent hanging...
    timeout /t 3 /nobreak >nul
    echo.
)

echo All tapes completed!
pause
