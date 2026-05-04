#!/bin/bash
# Test idempotent corrector vs baseline on the same input.
#
# Usage:
#   bash test_corrector.sh [image] [src_prompt] [tgt_prompt] [steps] [inject] [guidance] [beta] [name]
#
# Defaults use the horse→camel example from run_horse.sh.
# Beta values to sweep can be passed as the 7th argument (default 0.1).
# Results land in output/corrector_test/{no_corrector,beta<value>}/
export HF_HOME=/ocean/projects/cis220031p/shared/hf_cache/
export HF_TOKEN=""

IMAGE="${1:-examples/source/horse.jpg}"
SRC_PROMPT="${2:-A young boy is riding a brown horse in a countryside field, with a large tree in the background.}"
TGT_PROMPT="${3:-A young boy is riding a camel in a countryside field, with a large tree in the background.}"
STEPS="${4:-15}"
INJECT="${5:-3}"
GUIDANCE="${6:-2.0}"
BETA="${7:-0.1}"
NAME="${8:-flux-dev}"

BASE="output/corrector_test"

echo "============================================"
echo "RF-Solver idempotent corrector ablation"
echo "Image:    $IMAGE"
echo "Targest:   $TGT_PROMPT"
echo "Steps:    $STEPS  Inject: $INJECT  Guidance: $GUIDANCE"
echo "Beta:     $BETA"
echo "============================================"
echo ""

# --- Baseline: no corrector (beta=0) ---
echo ">>> [1/2] Baseline (beta=0)"
python edit.py \
    --source_img_dir "$IMAGE" \
    --source_prompt  "$SRC_PROMPT" \
    --target_prompt  "$TGT_PROMPT" \
    --num_steps      "$STEPS" \
    --inject         "$INJECT" \
    --guidance       "$GUIDANCE" \
    --beta           0.0 \
    --name           "$NAME" \
    --output_dir     "${BASE}/no_corrector"
echo ""

# --- With idempotent corrector ---
echo ">>> [2/2] With idempotent corrector (beta=$BETA)"
python edit.py \
    --source_img_dir "$IMAGE" \
    --source_prompt  "$SRC_PROMPT" \
    --target_prompt  "$TGT_PROMPT" \
    --num_steps      "$STEPS" \
    --inject         "$INJECT" \
    --guidance       "$GUIDANCE" \
    --beta           "$BETA" \
    --name           "$NAME" \
    --output_dir     "${BASE}"
echo ""

echo "============================================"
echo "Done. Results:"
echo "  Baseline:       ${BASE}/no_corrector/"
echo "  With corrector: ${BASE}/beta${BETA}/"
echo ""
echo "To sweep beta values, re-run with different 7th argument, e.g.:"
echo "  bash test_corrector.sh \"$IMAGE\" \"$SRC_PROMPT\" \"$TGT_PROMPT\" $STEPS $INJECT $GUIDANCE 0.05"
echo "  bash test_corrector.sh \"$IMAGE\" \"$SRC_PROMPT\" \"$TGT_PROMPT\" $STEPS $INJECT $GUIDANCE 0.2"
echo "  bash test_corrector.sh \"$IMAGE\" \"$SRC_PROMPT\" \"$TGT_PROMPT\" $STEPS $INJECT $GUIDANCE 0.5"
echo "============================================"
