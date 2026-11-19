# Notices

## DEIMv2 Wholebody34 (S and N)
By Katsuya Hyodo (PINTO0309), built on DEIMv2 by Intellindust AI Lab.
Source: https://github.com/PINTO0309/PINTO_model_zoo/tree/main/472_DEIMv2-Wholebody34
Licence: Apache-2.0.
Changes: none. Taken from the folder's release archive and renamed:
- deimv2_dinov3_s_wholebody34_1750query_640x640_nopre.onnx → deimv2-s-wholebody34.onnx
- deimv2_hgnetv2_n_wholebody34_680query_640x640_nopre.onnx → deimv2-n-wholebody34.onnx

## MediaPipe selfie multiclass segmentation (256×256)
By Google.
Source: https://storage.googleapis.com/mediapipe-models/image_segmenter/selfie_multiclass_256x256/float32/latest/selfie_multiclass_256x256.tflite
Licence: Apache-2.0 (model card).
Changes: converted from TFLite to ONNX with tf2onnx (opset 13), and internal names renamed
so the conversion is reproducible. Weights unchanged.
