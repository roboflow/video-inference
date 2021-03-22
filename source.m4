#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([base], , [The Roboflow Infer host; set for On-Device Inference], ["https://infer.roboflow.com"])
# ARG_OPTIONAL_SINGLE([confidence], c, [The minimum threshold for the model to output box predictions.], [50])
# ARG_OPTIONAL_SINGLE([overlap], o, [The maximum amount two predicted boxes of the same class can intersect before being combined.], [50])
# ARG_OPTIONAL_SINGLE([stroke], s, [The thickness of the predicted bounding boxes.], [5])
# ARG_OPTIONAL_BOOLEAN([labels], l, [Print the class names])
# ARG_OPTIONAL_SINGLE([fps], f, [The number of frames per second (2 means sample 1 frame per second of video_in).], [12])
# ARG_OPTIONAL_SINGLE([tmp], t, [The tmp directory; must be writable.], ["/tmp"])
# ARG_OPTIONAL_SINGLE([retries], r, [The number of times to retry a failed inference.], [3])
# ARG_OPTIONAL_SINGLE([parallel], p, [The number of concurrent frames to send to the model.], [8])
# ARG_POSITIONAL_SINGLE([model], [The Roboflow model to use for inference (required).])
# ARG_POSITIONAL_SINGLE([video_in], [The input video file (required).])
# ARG_POSITIONAL_SINGLE([video_out], [The output video file (required).])
# ARG_DEFAULTS_POS
# ARG_HELP([<Use a Roboflow Trained model to make predictions on a video.>])
# ARGBASH_GO

# [ <-- needed because of Argbash

printf 'Value of --%s: %s\n' 'base' "$_arg_base"
printf 'Value of --%s: %s\n' 'confidence' "$_arg_confidence"
printf 'Value of --%s: %s\n' 'overlap' "$_arg_overlap"
printf 'Value of --%s: %s\n' 'stroke' "$_arg_stroke"
printf 'Value of --%s: %s\n' 'labels' "$_arg_labels"
printf 'Value of --%s: %s\n' 'fps' "$_arg_fps"
printf 'Value of --%s: %s\n' 'tmp' "$_arg_tmp"
printf 'Value of --%s: %s\n' 'retries' "$_arg_retries"
printf 'Value of --%s: %s\n' 'parallel' "$_arg_parallel"
printf "Value of '%s': %s\\n" 'model' "$_arg_model"
printf "Value of '%s': %s\\n" 'video_in' "$_arg_video_in"
printf "Value of '%s': %s\\n" 'video_out' "$_arg_video_out"

# ] <-- needed because of Argbash
