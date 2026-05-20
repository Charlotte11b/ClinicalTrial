@echo off
setlocal

cd /d "%~dp0"
title Clinical Trial Virtual Participant Simulator

echo.
echo Clinical Trial Virtual Participant Simulator
echo -------------------------------------------
echo.

where python >nul 2>nul
if errorlevel 1 (
  echo ERROR: Python was not found.
  echo Install Python 3.10 or newer from https://www.python.org/downloads/windows/
  echo Make sure "Add python.exe to PATH" is checked.
  echo.
  pause
  exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
  echo Creating local Python virtual environment...
  python -m venv .venv
  if errorlevel 1 (
    echo.
    echo ERROR: Could not create the virtual environment.
    pause
    exit /b 1
  )
)

echo Installing or checking Python requirements...
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
  echo.
  echo ERROR: Could not install requirements.
  echo Check your internet connection, then try again.
  pause
  exit /b 1
)

if not exist "config.json" (
  echo Creating config.json from config.example.json...
  copy "config.example.json" "config.json" >nul
)

where ollama >nul 2>nul
if errorlevel 1 (
  echo.
  echo WARNING: Ollama was not found.
  echo The web app can start, but VP responses will not work until Ollama is installed.
  echo Install Ollama from https://ollama.com/download/windows
  echo.
) else (
  echo Checking default Ollama model...
  ollama list | findstr /C:"llama3.2:3b" >nul 2>nul
  if errorlevel 1 (
    echo Pulling llama3.2:3b with Ollama. This may take a while the first time...
    ollama pull llama3.2:3b
  )
)

echo.
echo Starting app at http://127.0.0.1:7860
echo Leave this window open while using the simulator.
echo Press Ctrl+C in this window to stop the app.
echo.

start "" "http://127.0.0.1:7860"
".venv\Scripts\python.exe" app.py

echo.
echo App stopped.
pause

