# llama.cpp Server Helm Chart

A Helm chart for deploying llama.cpp server with NVIDIA RTX 5090 GPU support on Kubernetes.

## Overview

This chart deploys llama.cpp server optimized for NVIDIA RTX 5090 GPUs (Blackwell architecture). It's based on the [phymbert/llama.cpp Kubernetes example](https://github.com/phymbert/llama.cpp/tree/example/kubernetes/examples/kubernetes/llama-cpp) with adaptations for:

- **Longhorn persistent storage**
- **MetalLB LoadBalancer with sealed secrets**
- **RTX 5090 GPU optimizations** (CUDA 12.8+, flash attention, 99 GPU layers)
- **OpenAI gpt-oss-20b model** (12.1GB MXFP4 quantization)

## Features

- ✅ **Automatic model download** via Kubernetes Job (PreSync hook)
- ✅ **GPU acceleration** with NVIDIA runtime and device plugin
- ✅ **Flash attention** enabled for better performance
- ✅ **Persistent storage** using Longhorn
- ✅ **LoadBalancer service** with sealed secret IP management
- ✅ **Prometheus metrics** endpoint
- ✅ **Health probes** for liveness and readiness
- ✅ **RBAC** and service account setup
- ✅ **Horizontal pod autoscaling** (optional)

## Prerequisites

- Kubernetes cluster with GPU nodes
- NVIDIA GPU operator or device plugin installed
- Node labeled with `gpu: "true"`
- NVIDIA runtime class configured (`runtimeClassName: nvidia`)
- Longhorn storage class deployed
- Sealed secrets controller (for LoadBalancer IP management)
- MetalLB or another LoadBalancer provider (optional)

## Installation

### Via Argo CD (Recommended)

The chart is managed by Argo CD. Apply the application manifest:

```bash
kubectl apply -f argocd/apps/applications/llamacpp/llamacpp-app.yaml
```

The deployment will:
1. Create PVC with Longhorn storage (50Gi)
2. Run model download job (PreSync hook) to fetch gpt-oss-20b from HuggingFace
3. Deploy llama.cpp server with GPU support
4. Patch LoadBalancer IP from sealed secret (PostSync hook)

### Manual Installation

```bash
helm install llamacpp-app helm/llamacpp-app --namespace applications --create-namespace
```

## Architecture

### Model Download Flow

1. **PreSync Job** (`jobs.yaml`):
   - Downloads `gpt-oss-20b-mxfp4.gguf` (12.1GB) from HuggingFace
   - Verifies SHA256 checksum (if provided)
   - Stores model in Longhorn PVC
   - Uses curl with resume capability (`-c` flag)
   - Idempotent (skips download if model exists and is valid)

2. **Deployment**:
   - Mounts PVC as read-only volume
   - Loads model from `/models/gpt-oss-20b-mxfp4.gguf`
   - Runs llama-server with GPU acceleration

### GPU Configuration

The chart configures RTX 5090 optimizations:

- **CUDA Version**: 12.8+ (via environment variable)
- **Flash Attention**: Enabled (`-fa` flag)
- **GPU Layers**: 99 layers offloaded (`-ngl 99`)
- **Runtime Class**: `nvidia`
- **GPU Tolerations**: Automatic for `nvidia.com/gpu` taints
- **Node Selector**: `gpu: "true"`

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `images.server.repository` | Server image repository | `ghcr.io/ggerganov/llama.cpp` |
| `images.server.name` | Server image name | `server-cuda` |
| `images.server.tag` | Server image tag | `latest` |
| `model.path` | Model storage path | `/models` |
| `model.file` | Model file to download | `gpt-oss-20b-GGUF/gpt-oss-20b-mxfp4.gguf` |
| `model.size` | PVC size | `50Gi` |
| `model.sha256` | SHA256 checksum (optional) | `""` |
| `server.port` | Server port | `8080` |
| `server.kvCache.size` | Context window size | `8192` |
| `server.slots` | Parallel processing slots | `4` |
| `server.metrics` | Enable Prometheus metrics | `true` |
| `server.completions` | Enable completions endpoint | `true` |
| `server.embeddings` | Enable embeddings endpoint | `false` |
| `server.extraArgs` | Additional server arguments | `["-fa", "-ngl", "99"]` |
| `gpu.enabled` | Enable GPU support | `true` |
| `gpu.nvidiaResource` | GPU resource name | `nvidia.com/gpu` |
| `gpu.number` | Number of GPUs | `1` |
| `resources.requests.memory` | Memory request | `32Gi` |
| `resources.limits.memory` | Memory limit | `64Gi` |
| `persistence.storageClass` | Storage class | `longhorn` |
| `service.type` | Service type | `LoadBalancer` |
| `runtimeClassName` | Runtime class | `nvidia` |
| `nodeSelector.gpu` | GPU node selector | `"true"` |

### Sealed Secret Configuration

To configure the LoadBalancer IP:

```bash
# Create sealed secret for your MetalLB IP
echo -n "YOUR_IP_ADDRESS" | kubeseal --raw --from-file=/dev/stdin \
  --namespace applications --name llamacpp-app-lb-ip

# Add the encrypted value to values.yaml
# sealedSecret:
#   encryptedData:
#     loadBalancerIP: "<encrypted-value-here>"
```

### Custom Model

To use a different model:

```yaml
model:
  path: /models
  alias: my-model
  repo: username
  file: repo-name/model-file.gguf
  size: 100Gi  # Adjust based on model size
  sha256: ""   # Optional checksum
```

## Usage

### API Endpoints

Once deployed, the server exposes:

- **Health Check**: `GET /health`
- **Completions**: `POST /v1/completions`
- **Chat Completions**: `POST /v1/chat/completions`
- **Embeddings**: `POST /v1/embeddings` (if enabled)
- **Metrics**: `GET /metrics` (Prometheus format)

### Example Requests

#### Text Completion

```bash
SERVICE_IP=$(kubectl get svc -n applications llamacpp-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -X POST http://$SERVICE_IP:8080/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain quantum computing in simple terms:",
    "max_tokens": 150,
    "temperature": 0.7,
    "top_p": 0.9
  }'
```

#### Chat Completion

```bash
curl -X POST http://$SERVICE_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is the capital of France?"}
    ],
    "max_tokens": 50
  }'
```

#### Health Check

```bash
curl http://$SERVICE_IP:8080/health
```

## Monitoring

### Prometheus Integration

The chart includes Prometheus pod annotations for automatic metric scraping:

```yaml
annotations:
  prometheus.io/scrape: 'true'
  prometheus.io/port: '8080'
```

Metrics are available at `/metrics` when `server.metrics: true`.

## Troubleshooting

### Model Download Issues

Check the download job logs:

```bash
kubectl logs -n applications job/llamacpp-app-download-model
```

If the download fails:
- Verify network connectivity to HuggingFace
- Check PVC has sufficient space (50Gi for gpt-oss-20b)
- Manually trigger download job deletion to retry

### GPU Not Detected

Verify GPU resources:

```bash
kubectl describe node <gpu-node-name> | grep nvidia.com/gpu
kubectl get pods -n kube-system | grep nvidia-device-plugin
```

Check pod GPU allocation:

```bash
kubectl describe pod -n applications <pod-name> | grep -A5 "Limits:"
```

### Pod Not Scheduling

Check node labels and taints:

```bash
kubectl get nodes --show-labels | grep gpu
kubectl describe node <gpu-node-name> | grep Taints
```

Verify tolerations match your node taints.

### Out of Memory

The RTX 5090 has 32GB VRAM. For gpt-oss-20b (21B parameters, 12.1GB model file):

- Model file: ~12GB
- KV cache (8192 ctx): ~4-6GB
- Activations: ~2-4GB
- Total: ~18-22GB (fits comfortably)

To reduce memory:
- Decrease `server.kvCache.size` (context window)
- Reduce `server.slots` (parallel requests)
- Use a smaller quantization (Q4 instead of MXFP4)

### LoadBalancer IP Not Applied

Check the patch job:

```bash
kubectl logs -n applications job/llamacpp-app-lb-ip-patch
```

Verify sealed secret decrypts correctly:

```bash
kubectl get secret -n applications llamacpp-app-lb-ip -o jsonpath='{.data.loadBalancerIP}' | base64 -d
```

## Performance Tips

1. **Context Size**: Balance between capability and memory. 8192 is a good default.
2. **Parallel Slots**: Increase for higher concurrency, decrease for longer contexts.
3. **Flash Attention**: Keep enabled (`-fa`) for best performance with long contexts.
4. **GPU Layers**: 99 offloads nearly all layers to GPU for maximum acceleration.
5. **Batch Size**: Continuous batching (`--cont-batching`) improves throughput.

## Model Information

### gpt-oss-20b

- **Parameters**: 21B total, 3.6B active (Mixture of Experts)
- **Quantization**: MXFP4 (mixed-precision floating-point)
- **File Size**: 12.1GB
- **Context**: Supports extended context (tested up to 128K)
- **License**: Apache 2.0
- **Source**: [HuggingFace - ggml-org/gpt-oss-20b-GGUF](https://huggingface.co/ggml-org/gpt-oss-20b-GGUF)

## Differences from Reference Chart

This chart extends the [phymbert/llama.cpp example](https://github.com/phymbert/llama.cpp/tree/example/kubernetes/examples/kubernetes/llama-cpp) with:

- **Longhorn storage** instead of generic storage class
- **Sealed secrets + patch job** for LoadBalancer IP management
- **RTX 5090 optimizations** (CUDA 12.8, runtime class, tolerations)
- **RBAC and ServiceAccount** for Argo CD integration
- **GPU resource management** in deployment spec
- **gpt-oss-20b model** configuration (vs. tinyllamas example)
- **Enhanced job with SHA256 validation** and resume capability

## References

- [llama.cpp GitHub](https://github.com/ggml-org/llama.cpp)
- [llama.cpp Docker Images](https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md)
- [phymbert/llama.cpp Kubernetes Example](https://github.com/phymbert/llama.cpp/tree/example/kubernetes/examples/kubernetes/llama-cpp)
- [OpenAI gpt-oss](https://github.com/openai/gpt-oss)
- [gpt-oss-20b GGUF Models](https://huggingface.co/ggml-org/gpt-oss-20b-GGUF)
- [RTX 5090 Specifications](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/)
