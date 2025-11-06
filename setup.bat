@echo off
echo ===================================
echo GenAI on Edge Setup Script
echo ===================================

:: Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed. Please install Docker first.
    pause
    exit /b 1
)

:: Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo SUCCESS: Docker and Docker Compose are installed.

:: Create model directories if they don't exist
echo Creating model directories...
if not exist "models\models\llama2\model" mkdir "models\models\llama2\model"
if not exist "models\models\gpt_neo\model" mkdir "models\models\gpt_neo\model"
if not exist "models\models\mistral\model" mkdir "models\models\mistral\model"

echo SUCCESS: Model directories created.

:: Check for model files
echo Checking for model files...

:: Check if directories have any files
dir /b "models\models\llama2\model" 2>nul | findstr /r ".*" >nul
if %errorlevel% equ 0 (
    echo SUCCESS: Llama 2 model files found
    goto :success_end
)

dir /b "models\models\gpt_neo\model" 2>nul | findstr /r ".*" >nul
if %errorlevel% equ 0 (
    echo SUCCESS: GPT-Neo model files found
    goto :success_end
)

dir /b "models\models\mistral\model" 2>nul | findstr /r ".*" >nul
if %errorlevel% equ 0 (
    echo SUCCESS: Mistral model files found
    goto :success_end
)

:: No models found, offer to download
echo WARNING: No model files found in any directory.
echo.
echo Would you like me to download some test models for you?
echo This will download smaller models suitable for testing:
echo   - Llama 2 7B Chat Q4_K_M - approx 4GB
echo   - Mistral 7B Instruct Q4_K_M - approx 4GB
echo   - Phi-3 Mini Q4_K_M - approx 2GB as GPT-Neo alternative
echo.
echo WARNING: This will download approximately 10GB of data!
echo.
set /p download_choice="Do you want to download models? (y/N): "

if /i "%download_choice%"=="y" goto :download_models

echo.
echo Please download and place model files manually in the respective directories:
echo   - models\models\llama2\model\ for Llama 2 GGUF files
echo   - models\models\gpt_neo\model\ for GPT-Neo model files
echo   - models\models\mistral\model\ for Mistral GGUF files
pause
exit /b 1

:download_models
echo.
echo Starting model downloads...
echo This may take a while depending on your internet connection.
echo.

:: Check if curl is available
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: curl is not available. Please install curl or download models manually.
    echo You can download curl from: https://curl.se/windows/
    pause
    exit /b 1
)

echo SUCCESS: curl found. Starting downloads...

echo.
echo Downloading Llama 2 7B Chat Q4_K_M - approx 4GB...
echo This may take 10-30 minutes depending on your connection.
curl -L -o "models\models\llama2\model\llama-2-7b-chat.Q4_K_M.gguf" "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf"

if %errorlevel% equ 0 (
    echo SUCCESS: Llama 2 model downloaded successfully!
) else (
    echo ERROR: Failed to download Llama 2 model.
)

echo.
echo Downloading Mistral 7B Instruct Q4_K_M - approx 4GB...
curl -L -o "models\models\mistral\model\mistral-7b-instruct-v0.1.Q4_K_M.gguf" "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf"

if %errorlevel% equ 0 (
    echo SUCCESS: Mistral model downloaded successfully!
) else (
    echo ERROR: Failed to download Mistral model.
)

echo.
echo Downloading Phi-3 Mini Q4_K_M as GPT-Neo alternative - approx 2GB...
curl -L -o "models\models\gpt_neo\model\Phi-3-mini-4k-instruct-q4.gguf" "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"

if %errorlevel% equ 0 (
    echo SUCCESS: Phi-3 Mini model downloaded successfully!
) else (
    echo ERROR: Failed to download Phi-3 Mini model.
)

echo.
echo SUCCESS: Model downloads completed!
echo.
echo NOTE: You may need to update the model file names in your Python scripts
echo if they expect different filenames.

:success_end
echo.
echo SUCCESS: Ready to start the GenAI on Edge system!
echo.
echo To start the system, run:
echo   docker-compose up --build
echo.
echo To start in background mode:
echo   docker-compose up -d --build
echo.
echo Access points:
echo   - Frontend: http://localhost:3000
echo   - API: http://localhost:8000
echo.
pause