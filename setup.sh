#!/bin/bash

# GenAI on Edge Setup Script
echo "==================================="
echo "GenAI on Edge Setup Script"
echo "==================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed."

# Create model directories if they don't exist
echo "📁 Creating model directories..."
mkdir -p models/models/llama2/model
mkdir -p models/models/gpt_neo/model
mkdir -p models/models/mistral/model

echo "✅ Model directories created."

# Check for model files
echo "🔍 Checking for model files..."

LLAMA_MODEL_EXISTS=false
GPT_NEO_MODEL_EXISTS=false
MISTRAL_MODEL_EXISTS=false

if [ "$(ls -A models/models/llama2/model 2>/dev/null)" ]; then
    echo "✅ Llama 2 model files found"
    LLAMA_MODEL_EXISTS=true
else
    echo "⚠️  Llama 2 model files not found in models/models/llama2/model/"
fi

if [ "$(ls -A models/models/gpt_neo/model 2>/dev/null)" ]; then
    echo "✅ GPT-Neo model files found"
    GPT_NEO_MODEL_EXISTS=true
else
    echo "⚠️  GPT-Neo model files not found in models/models/gpt_neo/model/"
fi

if [ "$(ls -A models/models/mistral/model 2>/dev/null)" ]; then
    echo "✅ Mistral model files found"
    MISTRAL_MODEL_EXISTS=true
else
    echo "⚠️  Mistral model files not found in models/models/mistral/model/"
fi

if [ "$LLAMA_MODEL_EXISTS" = false ] && [ "$GPT_NEO_MODEL_EXISTS" = false ] && [ "$MISTRAL_MODEL_EXISTS" = false ]; then
    echo "❌ No model files found."
    echo ""
    echo "Would you like me to download some test models for you?"
    echo "This will download smaller models suitable for testing:"
    echo "  - Llama 2 7B Chat (Q4_K_M) - ~4GB"
    echo "  - Mistral 7B Instruct (Q4_K_M) - ~4GB"
    echo "  - Phi-3 Mini (Q4_K_M) - ~2GB (as GPT-Neo alternative)"
    echo ""
    echo "WARNING: This will download approximately 10GB of data!"
    echo ""
    read -p "Do you want to download models? (y/N): " download_choice
    
    if [[ $download_choice =~ ^[Yy]$ ]]; then
        download_models
    else
        echo ""
        echo "Please download and place model files manually in the respective directories:"
        echo "  - models/models/llama2/model/ (for Llama 2 GGUF files)"
        echo "  - models/models/gpt_neo/model/ (for GPT-Neo model files)"
        echo "  - models/models/mistral/model/ (for Mistral GGUF files)"
        exit 1
    fi
fi

echo ""
echo "🚀 Ready to start the GenAI on Edge system!"
echo ""
echo "To start the system, run:"
echo "  docker-compose up --build"
echo ""
echo "To start in background mode:"
echo "  docker-compose up -d --build"
echo ""
echo "Access points:"
echo "  - Frontend: http://localhost:3000"
echo "  - API: http://localhost:8000"
echo ""

download_models() {
    echo ""
    echo "📥 Starting model downloads..."
    echo "This may take a while depending on your internet connection."
    echo ""

    # Check if curl or wget is available
    if command -v curl &> /dev/null; then
        DOWNLOADER="curl -L -o"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget -O"
    else
        echo "❌ Neither curl nor wget is available. Please install one of them to download models."
        echo "On Ubuntu/Debian: sudo apt update && sudo apt install curl"
        echo "On macOS: curl should be pre-installed"
        exit 1
    fi

    echo "✅ Download tool found. Starting downloads..."

    # Download Llama 2 7B Chat Q4_K_M
    if [ "$LLAMA_MODEL_EXISTS" = false ]; then
        echo ""
        echo "📥 Downloading Llama 2 7B Chat (Q4_K_M) - ~4GB..."
        echo "This may take 10-30 minutes depending on your connection."
        
        if command -v curl &> /dev/null; then
            curl -L -o "models/models/llama2/model/llama-2-7b-chat.Q4_K_M.gguf" \
                 "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf"
        else
            wget -O "models/models/llama2/model/llama-2-7b-chat.Q4_K_M.gguf" \
                 "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf"
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Llama 2 model downloaded successfully!"
        else
            echo "❌ Failed to download Llama 2 model."
        fi
    fi

    # Download Mistral 7B Instruct Q4_K_M
    if [ "$MISTRAL_MODEL_EXISTS" = false ]; then
        echo ""
        echo "📥 Downloading Mistral 7B Instruct (Q4_K_M) - ~4GB..."
        
        if command -v curl &> /dev/null; then
            curl -L -o "models/models/mistral/model/mistral-7b-instruct-v0.1.Q4_K_M.gguf" \
                 "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf"
        else
            wget -O "models/models/mistral/model/mistral-7b-instruct-v0.1.Q4_K_M.gguf" \
                 "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf"
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Mistral model downloaded successfully!"
        else
            echo "❌ Failed to download Mistral model."
        fi
    fi

    # Download Phi-3 Mini Q4_K_M (for GPT-Neo alternative)
    if [ "$GPT_NEO_MODEL_EXISTS" = false ]; then
        echo ""
        echo "📥 Downloading Phi-3 Mini (Q4_K_M) as GPT-Neo alternative - ~2GB..."
        
        if command -v curl &> /dev/null; then
            curl -L -o "models/models/gpt_neo/model/Phi-3-mini-4k-instruct-q4.gguf" \
                 "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
        else
            wget -O "models/models/gpt_neo/model/Phi-3-mini-4k-instruct-q4.gguf" \
                 "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Phi-3 Mini model downloaded successfully!"
        else
            echo "❌ Failed to download Phi-3 Mini model."
        fi
    fi

    echo ""
    echo "🎉 Model downloads completed!"
    echo ""
    echo "📝 Note: You may need to update the model file names in your Python scripts"
    echo "if they expect different filenames."
    echo ""
}