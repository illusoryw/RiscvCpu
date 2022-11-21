@echo off

del build\cpu.dat >nul 2>nul
del build\cputest.out >nul 2>nul
del build\wave.vcd >nul 2>nul

iverilog -o build\cpu.dat -Wall src\*.v src\memory\*.v src\stageregs\*.v src\testbench\*.v
if errorlevel 1 (goto end)

cd build
echo.
vvp -n cpu.dat
cd ..

:end
echo.
pause