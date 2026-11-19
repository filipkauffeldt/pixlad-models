# pixlad-models

ONNX models used by [pixlad](https://github.com/filipkauffeldt/pixlad) to find and outline
faces. The files are on the releases; pixlad's build downloads them and checks their SHA-256.

| File | What it does | Source | Licence |
|---|---|---|---|
| `deimv2-s-wholebody34.onnx` | Finds heads, faces and hands | PINTO model zoo 472, DEIMv2-S | Apache-2.0 |
| `deimv2-n-wholebody34.onnx` | Same, smaller and faster | PINTO model zoo 472, DEIMv2-N | Apache-2.0 |
| `selfie-multiclass.onnx` | Labels hair, face skin, body skin and clothes | MediaPipe selfie multiclass 256×256 | Apache-2.0 |

## Rebuild

    ./convert.sh

Needs `curl`, `python3` and [uv](https://docs.astral.sh/uv/). It downloads the originals,
converts the MediaPipe model to ONNX and writes the files and `SHA256SUMS` to `work/`.
The output should match the checksums in this repo.

See [NOTICE.md](NOTICE.md) for credits and what was changed.
