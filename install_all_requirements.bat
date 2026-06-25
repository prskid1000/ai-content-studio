@echo off
echo ========================================
echo Installing All Requirements
echo ========================================
echo.

REM Check if .venv exists
if not exist ".venv" (
    echo ERROR: .venv folder not found!
    echo Please create a virtual environment first.
    pause
    exit /b 1
)

REM Install wheel first (required for flash-attn)
echo Installing wheel (required for flash-attn)...
.venv\Scripts\python.exe -m pip install --no-cache-dir wheel
if errorlevel 1 (
    echo ERROR: Failed to install wheel
    pause
    exit /b 1
)
echo SUCCESS: wheel installed
echo.

REM Install PyTorch first (torch 2.12.1 to match the flash-attn cu132torch2.12.1 wheel)
REM NOTE: torchaudio is discontinued (final release was 2.9.0); there is no cu132/torch-2.12 wheel.
REM       Audio decode/encode is now handled by torchcodec (installed below).
echo [1/4] Installing PyTorch (CUDA 13.2)...
.venv\Scripts\python.exe -m pip install --no-cache-dir torch==2.12.1 torchvision==0.27.1 --index-url https://download.pytorch.org/whl/cu132
if errorlevel 1 (
    echo ERROR: Failed to install PyTorch
    pause
    exit /b 1
)
echo SUCCESS: PyTorch installed
echo.

REM Install TorchCodec (audio/video decode-encode; 0.14.0 requires torch>=2.11, OK for 2.12)
echo Installing TorchCodec 0.14.0...
.venv\Scripts\python.exe -m pip install --no-cache-dir torchcodec==0.14.0
if errorlevel 1 (
    echo ERROR: Failed to install TorchCodec
    pause
    exit /b 1
)
echo SUCCESS: TorchCodec installed
echo.

REM Install xformers (attention backend; 0.0.35 requires torch>=2.10, ships a generic win wheel on PyPI)
echo Installing xformers...
.venv\Scripts\python.exe -m pip install --no-cache-dir xformers==0.0.35
if errorlevel 1 (
    echo ERROR: Failed to install xformers
    pause
    exit /b 1
)
echo SUCCESS: xformers installed
echo.

REM Install flash-attn (pre-built wheel for Python 3.12 + CUDA 13.2)
echo [2/4] Installing flash-attn (pre-built wheel for CUDA 13.2)...
.venv\Scripts\python.exe -m pip install --no-cache-dir https://huggingface.co/ussoewwin/Flash-Attention-2_for_Windows/resolve/main/flash_attn-2.9.1+cu132torch2.12.1cxx11abiTRUE-cp312-cp312-win_amd64.whl
if errorlevel 1 (
    echo ERROR: Failed to install flash-attn
    pause
    exit /b 1
)
echo SUCCESS: flash-attn installed
echo.

REM Install sage-attn (no cu132 build exists; cu130 wheel is forward-compatible with the CUDA 13.2 runtime)
echo [3/4] Installing sage-attn (cu130 wheel, torch 2.10+)...
.venv\Scripts\python.exe -m pip install --no-cache-dir https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post5/sageattention-2.2.0+cu130torch2.10.0andhigher.post5-cp310-abi3-win_amd64.whl
if errorlevel 1 (
    echo ERROR: Failed to install sage-attn
    pause
    exit /b 1
)
echo SUCCESS: sage-attn installed
echo.

REM Install ONNX Runtime GPU deps first (required for CUDA 13 nightly; see microsoft/onnxruntime#26568)
echo Installing ONNX Runtime GPU dependencies...
.venv\Scripts\python.exe -m pip install --no-cache-dir coloredlogs flatbuffers numpy packaging protobuf sympy
if errorlevel 1 (
    echo ERROR: Failed to install ONNX Runtime GPU dependencies
    pause
    exit /b 1
)
echo.

REM Install ONNX Runtime GPU (nightly CUDA 13 - pin version + --no-deps to avoid pip downloading many nightlies)
echo [4/4] Installing ONNX Runtime GPU (nightly CUDA 13.2)...
.venv\Scripts\python.exe -m pip install --no-cache-dir --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ort-cuda-13-nightly/pypi/simple/ onnxruntime-gpu
if errorlevel 1 (
    echo ERROR: Failed to install ONNX Runtime GPU
    pause
    exit /b 1
)
echo SUCCESS: ONNX Runtime GPU installed
echo.

REM Install additional required Python packages (if not already installed)
echo Installing additional required Python packages...
.venv\Scripts\python.exe -m pip install --no-cache-dir coloredlogs flatbuffers numpy packaging protobuf sympy
if errorlevel 1 (
    echo ERROR: Failed to install additional Python packages
    pause
    exit /b 1
)
echo SUCCESS: Additional Python packages installed
echo.

REM Install root requirements.txt
echo [1/3] Installing root requirements.txt...
if exist "requirements.txt" (
    .venv\Scripts\python.exe -m pip install --no-cache-dir -r requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install root requirements.txt
        pause
        exit /b 1
    )
    echo SUCCESS: Root requirements installed
) else (
    echo WARNING: Root requirements.txt not found, skipping...
)
echo.

REM Install ComfyUI requirements.txt
echo [2/3] Installing ComfyUI requirements.txt...
if exist "ComfyUI\requirements.txt" (
    .venv\Scripts\python.exe -m pip install --no-cache-dir -r ComfyUI\requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install ComfyUI requirements.txt
        pause
        exit /b 1
    )
    echo SUCCESS: ComfyUI requirements installed
) else (
    echo WARNING: ComfyUI\requirements.txt not found, skipping...
)
echo.

REM Clone custom nodes if missing
echo ========================================
echo Cloning missing custom nodes...
echo ========================================
echo.

if not exist "ComfyUI\custom_nodes\ComfyMath" (
    echo Cloning ComfyMath...
    git clone https://github.com/evanspearman/ComfyMath "ComfyUI\custom_nodes\ComfyMath"
)
if not exist "ComfyUI\custom_nodes\ComfyUI-LTXVideo" (
    echo Cloning ComfyUI-LTXVideo...
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo "ComfyUI\custom_nodes\ComfyUI-LTXVideo"
)
if not exist "ComfyUI\custom_nodes\ComfyUI-MediaUtilities" (
    echo Cloning ComfyUI-MediaUtilities...
    git clone https://github.com/ThanaritKanjanametawatAU/ComfyUI-MediaUtilities "ComfyUI\custom_nodes\ComfyUI-MediaUtilities"
)
if not exist "ComfyUI\custom_nodes\ComfyUI-Whisper" (
    echo Cloning ComfyUI-Whisper...
    git clone https://github.com/yuvraj108c/ComfyUI-Whisper "ComfyUI\custom_nodes\ComfyUI-Whisper"
)
if not exist "ComfyUI\custom_nodes\ComfyUI_LoadImageFromHttpURL" (
    echo Cloning ComfyUI_LoadImageFromHttpURL...
    git clone https://github.com/jerrywap/ComfyUI_LoadImageFromHttpURL "ComfyUI\custom_nodes\ComfyUI_LoadImageFromHttpURL"
)
if not exist "ComfyUI\custom_nodes\comfyui-manager" (
    echo Cloning ComfyUI-Manager...
    git clone https://github.com/ltdrdata/ComfyUI-Manager "ComfyUI\custom_nodes\comfyui-manager"
)
if not exist "ComfyUI\custom_nodes\controlaltai-nodes" (
    echo Cloning ControlAltAI-Nodes...
    git clone https://github.com/gseth/ControlAltAI-Nodes "ComfyUI\custom_nodes\controlaltai-nodes"
)
if not exist "ComfyUI\custom_nodes\ComfyUI-GGUF" (
    echo Cloning ComfyUI-GGUF...
    git clone https://github.com/city96/ComfyUI-GGUF "ComfyUI\custom_nodes\ComfyUI-GGUF"
)
if not exist "ComfyUI\custom_nodes\comfyui-kjnodes" (
    echo Cloning ComfyUI-KJNodes...
    git clone https://github.com/kijai/ComfyUI-KJNodes "ComfyUI\custom_nodes\comfyui-kjnodes"
)
if not exist "ComfyUI\custom_nodes\comfyui-rmbg" (
    echo Cloning ComfyUI-RMBG...
    git clone https://github.com/1038lab/ComfyUI-RMBG "ComfyUI\custom_nodes\comfyui-rmbg"
)
if not exist "ComfyUI\custom_nodes\comfyui-videohelpersuite" (
    echo Cloning ComfyUI-VideoHelperSuite...
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite "ComfyUI\custom_nodes\comfyui-videohelpersuite"
)
if not exist "ComfyUI\custom_nodes\ComfyUI-OmniVoice-TTS" (
    echo Cloning ComfyUI-OmniVoice-TTS...
    git clone https://github.com/Saganaki22/ComfyUI-OmniVoice-TTS.git "ComfyUI\custom_nodes\ComfyUI-OmniVoice-TTS"
)
echo.

REM Install all custom_nodes requirements.txt
echo [3/3] Installing custom nodes requirements...
echo.

REM Loop through all subdirectories in ComfyUI\custom_nodes
for /d %%i in (ComfyUI\custom_nodes\*) do (
    if exist "%%i\requirements.txt" (
        echo Installing requirements for: %%~nxi
        .venv\Scripts\python.exe -m pip install --no-cache-dir -r "%%i\requirements.txt"
        if errorlevel 1 (
            echo WARNING: Failed to install %%~nxi requirements.txt
            echo Continuing with next custom node...
        ) else (
            echo SUCCESS: %%~nxi requirements installed
        )
        echo.
    )
)

REM Install Triton
echo ========================================
echo Installing Triton (triton-windows)...
echo ========================================
.venv\Scripts\python.exe -m pip install --no-cache-dir triton-windows
if errorlevel 1 (
    echo ERROR: Failed to install Triton
    pause
    exit /b 1
)
echo SUCCESS: Triton installed
echo.

echo ========================================
echo Installing Additional Tools via winget...
REM Install ffmpeg
winget install "FFmpeg (Shared)"
echo.

echo ========================================
echo All requirements installation completed!
echo ========================================
pause

