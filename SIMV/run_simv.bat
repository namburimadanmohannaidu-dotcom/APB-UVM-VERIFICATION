@echo off
setlocal enabledelayedexpansion

rem -----------------------------------------------------------------------------
rem APB_UVM simulation build script for VCS
rem Usage: run_simv.bat [<uvm_testname>]
rem Default test: apb_test
rem -----------------------------------------------------------------------------

set SCRIPT_DIR=%~dp0
set PROJ_ROOT=%SCRIPT_DIR%..\
set BUILD_DIR=%SCRIPT_DIR%build
set SRC_DIR=%BUILD_DIR%\src
set TESTNAME=apb_test

if not "%~1"=="" set TESTNAME=%~1

echo Preparing simulation sources...
if not exist "%SRC_DIR%" mkdir "%SRC_DIR%"

copy /Y "%PROJ_ROOT%TESTBENCH\Top.sv.txt" "%SRC_DIR%\Top.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Interface.sv.txt" "%SRC_DIR%\Interface.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Driver.sv.txt" "%SRC_DIR%\apb_driver.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Sequencer.sv.txt" "%SRC_DIR%\apb_sequencer" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Transaction.sv.txt" "%SRC_DIR%\apb_transaction.sv" >nul
copy /Y "%PROJ_ROOT%PACKAGES\Apb_pkg.sv.sv" "%SRC_DIR%\apb_pkg.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Agent.sv.sv" "%SRC_DIR%\apb_agent.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Monitor.sv.sv" "%SRC_DIR%\apb_monitor.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Scoreboard.sv.sv" "%SRC_DIR%\apb_scoreboard.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Env.sv.sv" "%SRC_DIR%\apb_env.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\Test.sv.sv" "%SRC_DIR%\apb_test.sv" >nul
copy /Y "%PROJ_ROOT%SEQUENCES\Sequence.sv.txt" "%SRC_DIR%\apb_sequence.sv" >nul
copy /Y "%PROJ_ROOT%RTL\Design.sv.txt" "%SRC_DIR%\Design.sv" >nul
copy /Y "%PROJ_ROOT%TESTBENCH\apb_coverage_test.sv" "%SRC_DIR%\apb_coverage_test.sv" >nul
copy /Y "%PROJ_ROOT%COVERAGES\apb_coverage.sv" "%SRC_DIR%\apb_coverage.sv" >nul
copy /Y "%PROJ_ROOT%COVERAGES\apb_functional_coverage.sv" "%SRC_DIR%\apb_functional_coverage.sv" >nul
copy /Y "%PROJ_ROOT%COVERAGES\apb_protocol_coverage.sv" "%SRC_DIR%\apb_protocol_coverage.sv" >nul

echo Creating build directory...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

echo Compiling project with VCS...
vcs -full64 -sverilog -uvm +acc +vpi +vcs+lic+wait -timescale=1ns/1ps -debug_pp -l vcs.log -o simv \
    "%SRC_DIR%\Top.sv" \
    "%SRC_DIR%\Interface.sv" \
    "%SRC_DIR%\apb_driver.sv" \
    "%SRC_DIR%\apb_monitor.sv" \
    "%SRC_DIR%\apb_agent.sv" \
    "%SRC_DIR%\apb_scoreboard.sv" \
    "%SRC_DIR%\apb_env.sv" \
    "%SRC_DIR%\apb_test.sv" \
    "%SRC_DIR%\apb_sequence.sv" \
    "%SRC_DIR%\apb_sequencer" \
    "%SRC_DIR%\apb_transaction.sv" \
    "%SRC_DIR%\apb_pkg.sv" \
    "%SRC_DIR%\Design.sv" \
    "%SRC_DIR%\apb_coverage_test.sv" \
    "%SRC_DIR%\apb_coverage.sv" \
    "%SRC_DIR%\apb_functional_coverage.sv" \
    "%SRC_DIR%\apb_protocol_coverage.sv"

if errorlevel 1 (
    echo Compilation failed. Check %BUILD_DIR%\vcs.log
    exit /b 1
)

echo Running simulation with test %TESTNAME%...
"%BUILD_DIR%\simv" +UVM_TESTNAME=%TESTNAME% +UVM_VERBOSITY=UVM_LOW

endlocal
