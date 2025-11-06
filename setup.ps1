# GenAI on Edge Setup Script (PowerShell)
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "GenAI on Edge Setup Script" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed." -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Docker Compose is installed
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose is installed." -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create model directories if they don't exist
Write-Host "📁 Creating model directories..." -ForegroundColor Yellow
$dirs = @(
    "models\models\llama2\model",
    "models\models\gpt_neo\model", 
    "models\models\mistral\model"
)

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "✅ Model directories created." -ForegroundColor Green

# Check for model files
Write-Host "🔍 Checking for model files..." -ForegroundColor Yellow

$llamaModelExists = (Get-ChildItem "models\models\llama2\model" -ErrorAction SilentlyContinue).Count -gt 0
$gptNeoModelExists = (Get-ChildItem "models\models\gpt_neo\model" -ErrorAction SilentlyContinue).Count -gt 0
$mistralModelExists = (Get-ChildItem "models\models\mistral\model" -ErrorAction SilentlyContinue).Count -gt 0

if ($llamaModelExists) {
    Write-Host "✅ Llama 2 model files found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Llama 2 model files not found in models\models\llama2\model\" -ForegroundColor Yellow
}

if ($gptNeoModelExists) {
    Write-Host "✅ GPT-Neo model files found" -ForegroundColor Green
} else {
    Write-Host "⚠️  GPT-Neo model files not found in models\models\gpt_neo\model\" -ForegroundColor Yellow
}

if ($mistralModelExists) {
    Write-Host "✅ Mistral model files found" -ForegroundColor Green
} else {
    Write-Host "⚠️  Mistral model files not found in models\models\mistral\model\" -ForegroundColor Yellow
}

if (-not $llamaModelExists -and -not $gptNeoModelExists -and -not $mistralModelExists) {
    Write-Host "❌ No model files found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Would you like me to download some test models for you?" -ForegroundColor Cyan
    Write-Host "This will download smaller models suitable for testing:" -ForegroundColor White
    Write-Host "  - Llama 2 7B Chat (Q4_K_M) - ~4GB" -ForegroundColor White
    Write-Host "  - Mistral 7B Instruct (Q4_K_M) - ~4GB" -ForegroundColor White
    Write-Host "  - Phi-3 Mini (Q4_K_M) - ~2GB (as GPT-Neo alternative)" -ForegroundColor White
    Write-Host ""
    Write-Host "WARNING: This will download approximately 10GB of data!" -ForegroundColor Yellow
    Write-Host ""
    
    $downloadChoice = Read-Host "Do you want to download models? (y/N)"
    
    if ($downloadChoice -eq 'y' -or $downloadChoice -eq 'Y') {
        # Download models function
        Write-Host ""
        Write-Host "📥 Starting model downloads..." -ForegroundColor Cyan
        Write-Host "This may take a while depending on your internet connection." -ForegroundColor Yellow
        Write-Host ""

        # Download Llama 2 7B Chat Q4_K_M
        if (-not $llamaModelExists) {
            Write-Host "📥 Downloading Llama 2 7B Chat (Q4_K_M) - ~4GB..." -ForegroundColor Cyan
            Write-Host "This may take 10-30 minutes depending on your connection." -ForegroundColor Yellow
            
            try {
                Invoke-WebRequest -Uri "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf" `
                                 -OutFile "models\models\llama2\model\llama-2-7b-chat.Q4_K_M.gguf" `
                                 -UseBasicParsing
                Write-Host "✅ Llama 2 model downloaded successfully!" -ForegroundColor Green
            } catch {
                Write-Host "❌ Failed to download Llama 2 model: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        # Download Mistral 7B Instruct Q4_K_M
        if (-not $mistralModelExists) {
            Write-Host ""
            Write-Host "📥 Downloading Mistral 7B Instruct (Q4_K_M) - ~4GB..." -ForegroundColor Cyan
            
            try {
                Invoke-WebRequest -Uri "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf" `
                                 -OutFile "models\models\mistral\model\mistral-7b-instruct-v0.1.Q4_K_M.gguf" `
                                 -UseBasicParsing
                Write-Host "✅ Mistral model downloaded successfully!" -ForegroundColor Green
            } catch {
                Write-Host "❌ Failed to download Mistral model: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        # Download Phi-3 Mini Q4_K_M (for GPT-Neo alternative)
        if (-not $gptNeoModelExists) {
            Write-Host ""
            Write-Host "📥 Downloading Phi-3 Mini (Q4_K_M) as GPT-Neo alternative - ~2GB..." -ForegroundColor Cyan
            
            try {
                Invoke-WebRequest -Uri "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf" `
                                 -OutFile "models\models\gpt_neo\model\Phi-3-mini-4k-instruct-q4.gguf" `
                                 -UseBasicParsing
                Write-Host "✅ Phi-3 Mini model downloaded successfully!" -ForegroundColor Green
            } catch {
                Write-Host "❌ Failed to download Phi-3 Mini model: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "🎉 Model downloads completed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📝 Note: You may need to update the model file names in your Python scripts" -ForegroundColor Yellow
        Write-Host "if they expect different filenames." -ForegroundColor Yellow
        
    } else {
        Write-Host ""
        Write-Host "Please download and place model files manually in the respective directories:" -ForegroundColor Yellow
        Write-Host "  - models\models\llama2\model\ (for Llama 2 GGUF files)" -ForegroundColor White
        Write-Host "  - models\models\gpt_neo\model\ (for GPT-Neo model files)" -ForegroundColor White
        Write-Host "  - models\models\mistral\model\ (for Mistral GGUF files)" -ForegroundColor White
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "🚀 Ready to start the GenAI on Edge system!" -ForegroundColor Green
Write-Host ""
Write-Host "To start the system, run:" -ForegroundColor Cyan
Write-Host "  docker-compose up --build" -ForegroundColor White
Write-Host ""
Write-Host "To start in background mode:" -ForegroundColor Cyan
Write-Host "  docker-compose up -d --build" -ForegroundColor White
Write-Host ""
Write-Host "Access points:" -ForegroundColor Cyan
Write-Host "  - Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  - API: http://localhost:8000" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"