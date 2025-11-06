# Generative AI on the Edge: PromptAI and Performance Evaluation

This project is focused on **Generative AI experimentation on Edge devices**, specifically utilizing a **Raspberry Pi** cluster as the testbed. The goal of this project is to deploy a distributed **PromptAI** system using **Docker containers** and a **Kubernetes (K3s) cluster** on Raspberry Pi devices.

The **PromptAI** system consists of interconnected services, including a prompt front-end, proxy, and model containers. These services are developed and deployed using modern technologies such as **FastAPI** (for the back-end), **React** (for the front-end), and containerized using **Docker** for easy deployment and management. Docker images are also available on DockerHub https://hub.docker.com/u/myicap.

Users can choose from a pool of **Large Language Models (LLMs)** and interact with their selected model. The requests are forwarded through a **proxy service**, which directs the traffic to the appropriate model container running on the Raspberry Pi nodes.

In addition to deployment and interaction, the project also focuses on evaluating the performance of these models using the **Llama.cpp** framework.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Building Docker Images](#building-docker-images)
- [Deployment Options](#deployment-options)
- [Usage](#usage)
- [Available Models](#available-models)
- [Performance Evaluation](#performance-evaluation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Prerequisites

Before installing and running this project, ensure you have the following prerequisites:

### Software Requirements
- **Docker** (version 20.10 or later)
- **Docker Compose** (version 2.0 or later)
- **Kubernetes** (K3s for Raspberry Pi deployment) - optional for cluster deployment
- **Git** for cloning the repository
- **Node.js** (version 18 or later) - for local frontend development
- **Python** (version 3.9 or later) - for local model development

### Hardware Requirements
- **For local development**: Any modern computer with at least 8GB RAM
- **For edge deployment**: Raspberry Pi 4 (4GB+ RAM recommended) or similar ARM devices
- **Storage**: At least 20GB free space for model files and containers

### Model Files
You'll need to download the appropriate model files for each LLM you want to use:
- **Llama 2**: `llama-2-7b-chat.Q4_K_M.gguf`
- **GPT-Neo**: Compatible GGUF format models
- **Mistral**: Compatible GGUF format models
- **InternLM**: Compatible GGUF format models

Place model files in the respective `models/models/[model-name]/` directories.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/alanssoares/GenAIOnEdge.git
cd GenAIOnEdge
```

### 2. Download Model Files

Create the necessary directories and download your preferred model files:

```bash
# Create model directories
mkdir -p models/models/llama2/model
mkdir -p models/models/gpt_neo/model
mkdir -p models/models/mistral/model

# Download your GGUF model files to the respective directories
# For example:
# - Place Llama 2 GGUF file in models/models/llama2/model/
# - Place GPT-Neo model files in models/models/gpt_neo/model/
# - Place Mistral GGUF file in models/models/mistral/model/
```

### 3. Quick Setup with Automatic Model Download

You can use the provided setup scripts to check your environment, prepare the system, and **automatically download test models**:

**For Windows (Command Prompt - Recommended):**
```cmd
setup.bat
```

**For Windows (PowerShell):**
```powershell
# Use cmd to run the batch file for best compatibility
cmd /c "setup.bat"
# OR use the PowerShell version
.\setup.ps1
```

**For Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

These scripts will:
- ✅ Check if Docker and Docker Compose are installed
- ✅ Create necessary model directories
- ✅ Verify that model files are present
- ✅ **Offer to download test models automatically** (~10GB total):
  - **Llama 2 7B Chat (Q4_K_M)** - ~4GB
  - **Mistral 7B Instruct (Q4_K_M)** - ~4GB  
  - **Phi-3 Mini (Q4_K_M)** - ~2GB (as GPT-Neo alternative)
- ✅ Provide next steps to run the system

> **Note**: The automatic download will fetch smaller, quantized models that are perfect for testing and development. For production use, you may want to use larger, unquantized models.

## Project Structure

```
GenAIOnEdge/
├── front/chat-frontend/          # React frontend application
├── proxy/                        # FastAPI proxy service
├── models/models/               # Model implementations
│   ├── llama2/                  # Llama 2 model service
│   ├── gpt_neo/                 # GPT-Neo model service
│   ├── mistral/                 # Mistral model service
│   └── internlm/                # InternLM model service
├── deployments/                 # Kubernetes deployment files
└── README.md
```

## Building Docker Images

Build the Docker images for each service:

### 1. Build the Proxy Service

```bash
cd proxy
docker build -t proxy:amd64-1 .
cd ..
```

### 2. Build the Frontend Service

```bash
cd front/chat-frontend
docker build -t frontend:amd64-1 .
cd ../..
```

### 3. Build Model Services

Build Docker images for each model you want to use:

```bash
# Llama 2
cd models/models/llama2/fastAPI
docker build -t llama:amd64-1 .
cd ../../../..

# GPT-Neo
cd models/models/gpt_neo/fastAPI
docker build -t gpt-neo:amd64-1 .
cd ../../../..

# Mistral
cd models/models/mistral/fastAPI
docker build -t mistral:amd64-1 .
cd ../../../..

# InternLM
cd models/models/internlm/fastAPI
docker build -t internlm:amd64-1 .
cd ../../../..
```

## Deployment Options

### Option 1: Docker Compose (Recommended for Testing)

The easiest way to run the entire system locally is using Docker Compose with 3 pre-configured models:

#### Prerequisites
- Ensure you have model files in the respective directories:
  - `models/models/llama2/model/` - Place your Llama 2 GGUF model file here
  - `models/models/gpt_neo/model/` - Place your GPT-Neo model files here
  - `models/models/mistral/model/` - Place your Mistral GGUF model file here

#### Run with Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode (background)
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

#### Access the Application
- **Frontend**: http://localhost:3000
- **Proxy API**: http://localhost:8000
- **Llama 2 Model**: http://localhost:8001
- **GPT-Neo Model**: http://localhost:8002
- **Mistral Model**: http://localhost:8003

### Option 2: Individual Docker Containers

For local development and testing, you can run services individually:

```bash
# Run the proxy service
docker run -p 8000:8000 proxy:amd64-1

# Run a model service (e.g., Llama 2)
docker run -p 8001:8000 llama:amd64-1

# Run the frontend
docker run -p 3000:80 frontend:amd64-1
```

### Option 3: Kubernetes Deployment

For production deployment on a Raspberry Pi cluster or any Kubernetes cluster:

#### Prerequisites
- K3s installed on your Raspberry Pi cluster
- `kubectl` configured to connect to your cluster

#### Deploy Services

```bash
# Deploy the proxy service
kubectl apply -f deployments/proxy.yaml

# Deploy model services
kubectl apply -f deployments/llama.yaml
kubectl apply -f deployments/gpt_neo.yaml
kubectl apply -f deployments/mistral.yaml
kubectl apply -f deployments/internlm.yaml

# Deploy the frontend
kubectl apply -f deployments/front.yaml
```

#### Check Deployment Status

```bash
# Check all pods
kubectl get pods

# Check services
kubectl get services

# Get external IP for frontend access
kubectl get service front-service
```

## Usage

### Accessing the Application

1. **Local Development**: Open your browser and navigate to `http://localhost:3000`
2. **Kubernetes Deployment**: Use the external IP provided by the LoadBalancer service

### Using the Chat Interface

1. Select your preferred model from the dropdown menu
2. Type your message in the chat input
3. Click "Send" to get a response from the selected model
4. The response will include the inference time for performance analysis

### API Endpoints

The proxy service exposes the following endpoints:

- `GET /`: Health check
- `POST /chat`: Send a chat message
  ```json
  {
    "message": "Your question here",
    "model": "llama" // or "gpt_neo", "mistral", "internlm"
  }
  ```

Individual model services:
- `GET /{model-name}`: Health check for specific model
- `POST /{model-name}/chat`: Direct chat with specific model

## Available Models

The following models are supported:

1. **Llama 2** (`llama`) - Meta's Llama 2 7B Chat model
2. **GPT-Neo** (`gpt_neo`) - EleutherAI's GPT-Neo model
3. **Mistral** (`mistral`) - Mistral AI's language model
4. **InternLM** (`internlm`) - InternLM model

Each model runs as a separate service and can be scaled independently.

## Performance Evaluation

The project includes performance evaluation tools using the Llama.cpp framework:

### Running Evaluations

Each model has evaluation scripts in their respective `eval-cpp/` directories:

```bash
# Example: Run Llama 2 evaluation
cd models/models/llama2/eval-cpp
docker build -t llama2-eval .
docker run llama2-eval
```

### Evaluation Results

Results are stored in the `results/` directories for each model:
- `inference_metrics_conversations_run_1.csv`: Conversation-based metrics
- `inference_metrics_sustained.csv`: Sustained load metrics

## Troubleshooting

### Common Issues

1. **Model files not found**: Ensure GGUF model files are placed in the correct directories
2. **Docker build fails**: Check that you have sufficient disk space and Docker is running
3. **Pods not starting**: Verify that Docker images are built and available
4. **Connection refused**: Ensure all services are running and network policies allow communication

### Debugging Commands

```bash
# Check Docker containers
docker ps -a

# Check Kubernetes pods
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check services
kubectl get services
kubectl describe service <service-name>
```

### Resource Requirements

- **Memory**: Each model service requires 4-8GB RAM depending on model size
- **CPU**: Multi-core ARM processors recommended for Raspberry Pi deployment
- **Storage**: 10-20GB per model for GGUF files

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
This work is supported by the Communications Hub for Empowering Distributed Cloud Computing Applications and Research (CHEDDAR) (https://cheddarhub.org/), a hub dedicated to advancing future communications. CHEDDAR is funded by the Engineering and Physical Sciences Research Council (EPSRC) – UK Research and Innovation (UKRI) via the Technology Missions Fund (TMF).



