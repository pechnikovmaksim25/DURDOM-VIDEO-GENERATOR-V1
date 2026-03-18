#!/bin/bash
set -euo pipefail

COMFY_DIR="/workspace/ComfyUI"
CUSTOM_NODES_DIR="$COMFY_DIR/custom_nodes"
MODELS_DIR="$COMFY_DIR/models"
NODE_NAME="comfyui-teskors-utils-main"

mkdir -p "$CUSTOM_NODES_DIR"
mkdir -p "$MODELS_DIR/diffusion_models" \
         "$MODELS_DIR/loras" \
         "$MODELS_DIR/vae" \
         "$MODELS_DIR/text_encoders" \
         "$MODELS_DIR/clip_vision" \
         "$MODELS_DIR/onnx/wholebody"

download_file () {
  local URL="$1"
  local DEST="$2"
  mkdir -p "$(dirname "$DEST")"
  if [ ! -f "$DEST" ]; then
    echo "Downloading: $DEST"
    wget -O "$DEST" "$URL"
  else
    echo "Already exists: $DEST"
  fi
}

python -m pip install --no-cache-dir -U huggingface_hub

if [ ! -d "$CUSTOM_NODES_DIR/$NODE_NAME" ]; then
python - <<'PY'
from huggingface_hub import snapshot_download
import shutil, os

repo_id = "vilone60/workbombom"
node_name = "comfyui-teskors-utils-main"
target_dir = f"/workspace/ComfyUI/custom_nodes/{node_name}"
tmp_dir = "/tmp/hf_workbombom"

if os.path.exists(tmp_dir):
    shutil.rmtree(tmp_dir)

snapshot_download(
    repo_id=repo_id,
    repo_type="model",
    local_dir=tmp_dir,
    local_dir_use_symlinks=False,
    allow_patterns=[f"{node_name}/*"]
)

src = os.path.join(tmp_dir, node_name)
if not os.path.exists(src):
    raise RuntimeError(f"Folder not found: {src}")

if os.path.exists(target_dir):
    shutil.rmtree(target_dir)

shutil.copytree(src, target_dir)
print(f"Installed node: {target_dir}")
PY
fi

if [ -f "$CUSTOM_NODES_DIR/$NODE_NAME/requirements.txt" ]; then
  python -m pip install --no-cache-dir -r "$CUSTOM_NODES_DIR/$NODE_NAME/requirements.txt"
fi

download_file "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors" \
  "$MODELS_DIR/diffusion_models/Wan2_2-Animate-14B_fp8_scaled_e4m3fn_KJ_v2.safetensors"

download_file "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors" \
  "$MODELS_DIR/loras/Wan21_PusaV1_LoRA_14B_rank512_bf16.safetensors"

download_file "https://huggingface.co/alibaba-pai/Wan2.2-Fun-Reward-LoRAs/resolve/main/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors" \
  "$MODELS_DIR/loras/Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors"

download_file "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
  "$MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"

download_file "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" \
  "$MODELS_DIR/loras/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"

download_file "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
  "$MODELS_DIR/vae/wan_2.1_vae.safetensors"

download_file "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
  "$MODELS_DIR/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

download_file "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
  "$MODELS_DIR/clip_vision/clip_vision_h.safetensors"

download_file "https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx" \
  "$MODELS_DIR/onnx/wholebody/vitpose-l-wholebody.onnx"

echo "Provisioning complete."
