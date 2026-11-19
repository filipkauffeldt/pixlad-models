#!/usr/bin/env bash
# Rebuilds the release files in work/ from the original downloads, and writes work/SHA256SUMS.
# Needs curl, python3 and uv (https://docs.astral.sh/uv/).
set -euo pipefail

cd "$(dirname "$0")"
work=work
mkdir -p "$work"

PINTO=https://s3.ap-northeast-2.wasabisys.com/pinto-model-zoo/472_DEIMv2-Wholebody34/resources.tar.gz
MEDIAPIPE=https://storage.googleapis.com/mediapipe-models/image_segmenter/selfie_multiclass_256x256/float32/latest/selfie_multiclass_256x256.tflite

# DEIMv2: the two models are members of a 2.5 GB archive. Stream it and stop once both are out.
if [ ! -f "$work/deimv2-s-wholebody34.onnx" ] || [ ! -f "$work/deimv2-n-wholebody34.onnx" ]; then
  echo "Streaming the DEIMv2 archive (stops once both models are out, a few minutes)..."
  status=0
  # curl exits with 23 when python stops reading, which is fine.
  curl -fsSL "$PINTO" | python3 -I -c '
import os, sys, tarfile

wanted = {
    "deimv2_dinov3_s_wholebody34_1750query_640x640_nopre.onnx": "deimv2-s-wholebody34.onnx",
    "deimv2_hgnetv2_n_wholebody34_680query_640x640_nopre.onnx": "deimv2-n-wholebody34.onnx",
}
out = sys.argv[1]
left = dict(wanted)
with tarfile.open(fileobj=sys.stdin.buffer, mode="r|gz") as tar:
    for member in tar:
        name = member.name.rsplit("/", 1)[-1]
        if name not in left or not member.isfile():
            continue
        target = left.pop(name)
        source = tar.extractfile(member)
        with open(f"{out}/{target}.part", "wb") as f:
            while chunk := source.read(1 << 20):
                f.write(chunk)
        os.rename(f"{out}/{target}.part", f"{out}/{target}")
        print("Extracted", target)
        if not left:
            break
if left:
    sys.exit("not in the archive: " + ", ".join(left))
' "$work" || status=$?
  [ "$status" -eq 0 ] || exit "$status"
fi

# MediaPipe: a TFLite model, converted to ONNX. The tool versions are pinned.
if [ ! -f "$work/selfie-multiclass.onnx" ]; then
  curl -fsSL "$MEDIAPIPE" -o "$work/selfie_multiclass_256x256.tflite"
  uv run --no-project --python 3.11 \
    --with tf2onnx --with tensorflow-cpu==2.15.1 --with "numpy<2" --with onnx==1.16.2 \
    python -m tf2onnx.convert --tflite "$work/selfie_multiclass_256x256.tflite" \
    --output "$work/selfie-multiclass.onnx" --opset 13
fi

(cd "$work" && sha256sum deimv2-s-wholebody34.onnx deimv2-n-wholebody34.onnx selfie-multiclass.onnx > SHA256SUMS)
echo "Done:"
cat "$work/SHA256SUMS"
