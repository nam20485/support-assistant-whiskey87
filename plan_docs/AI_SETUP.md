# AI Service Setup Guide

This guide explains how to set up the AI service for the Support Assistant application.

## Overview

The Support Assistant uses ONNX Runtime with the Phi-3-mini model for local AI inference. The service supports both CPU and GPU (DirectML) execution.

## Prerequisites

1. **Windows 10/11** (for DirectML support)
2. **.NET 8.0 Runtime**
3. **DirectML** (usually included with Windows 10 version 1903 and later)

## Model Setup

### Option 1: Download Phi-3-mini Model Manually

1. Download the Phi-3-mini ONNX model from Hugging Face:
   ```
   https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx
   ```

2. Place the model file in one of these locations:
   - `{AppDirectory}/assets/models/phi3-mini.onnx`
   - `{AppDirectory}/models/phi3-mini.onnx`
   - `%LOCALAPPDATA%/SupportAssistant/models/phi3-mini.onnx`
   - `%USERPROFILE%/.cache/huggingface/hub/phi3-mini.onnx`
   - `C:/AI/Models/phi3-mini.onnx`
   - `C:/Models/phi3-mini.onnx`

### Option 2: Configure Custom Model Path

1. Edit `appsettings.json` in the application directory:
   ```json
   {
     "AI": {
       "ModelPath": "C:/path/to/your/phi3-mini.onnx"
     }
   }
   ```

## Configuration Options

Edit `appsettings.json` to customize AI behavior:

```json
{
  "AI": {
    "UseGpuAcceleration": true,
    "ModelPath": "",
    "MaxTokens": 512,
    "Temperature": 0.7
  }
}
```

### Configuration Parameters

- **UseGpuAcceleration**: Enable/disable DirectML GPU acceleration
- **ModelPath**: Custom path to the ONNX model file
- **MaxTokens**: Maximum tokens to generate in responses
- **Temperature**: Controls randomness in responses (0.0-1.0)

## Troubleshooting

### DirectML Issues

If you see "Failed to enable DirectML provider" warnings:

1. **Update Windows**: Ensure you have Windows 10 version 1903 or later
2. **Update Graphics Drivers**: Install the latest drivers for your GPU
3. **Disable GPU Acceleration**: Set `UseGpuAcceleration: false` in configuration
4. **Check ONNX Runtime Version**: Ensure you're using a compatible version

### Model Not Found

If you see "Model file not found" warnings:

1. **Check File Path**: Verify the model file exists at the specified location
2. **Check Permissions**: Ensure the application has read access to the model file
3. **Download Model**: Follow the model setup instructions above
4. **Configure Path**: Set the correct path in `appsettings.json`

### Performance Issues

For better performance:

1. **Use GPU Acceleration**: Enable DirectML if available
2. **Optimize Model**: Use quantized models (INT4/INT8) for faster inference
3. **Adjust Parameters**: Reduce MaxTokens for faster responses

## Mock Mode

If no model is found, the service operates in mock mode, generating placeholder responses. This allows the application to function for testing purposes without requiring the full AI model.

## Model Information

- **Model**: Microsoft Phi-3-mini-4k-instruct
- **Size**: ~2.4GB (INT4 quantized)
- **Context Length**: 4096 tokens
- **License**: MIT License
- **Source**: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx
