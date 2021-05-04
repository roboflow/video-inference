#!/bin/bash

##################################################
# Roboflow Video Inference Example               #
# Bash script released under MIT License         #
# Copyright (c) 2021 Roboflow Inc                #
#                                                #
# https://github.com/roboflow-ai/video-inference #
##################################################

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([host], , [The Roboflow Infer host; set for On-Device Inference], ["https://infer.roboflow.com"])
# ARG_OPTIONAL_SINGLE([confidence], c, [The minimum threshold for the model to output box predictions.], [50])
# ARG_OPTIONAL_SINGLE([overlap], o, [The maximum amount two predicted boxes of the same class can intersect before being combined.], [50])
# ARG_OPTIONAL_SINGLE([stroke], s, [The thickness of the predicted bounding boxes.], [5])
# ARG_OPTIONAL_BOOLEAN([labels], l, [Print the class names])
# ARG_OPTIONAL_SINGLE([fps_in], , [The sample rate from the input video (in frames per second).], [6])
# ARG_OPTIONAL_SINGLE([fps_out], , [The render rate (setting higher than fps_in will give a timelapse effect).], [24])
# ARG_OPTIONAL_SINGLE([scale], , [The amount to shrink the video; eg 2 to make video_out width and height 2x smaller than video_in.], [1])
# ARG_OPTIONAL_SINGLE([tmp], t, [The tmp directory; must be writable.], ["/tmp"])
# ARG_OPTIONAL_SINGLE([retries], r, [The number of times to retry a failed inference.], [3])
# ARG_OPTIONAL_SINGLE([parallel], p, [The number of concurrent frames to send to the model.], [8])
# ARG_OPTIONAL_SINGLE([classes], f, [The classes to show, separated by a comma (no spaces).], [])
# ARG_OPTIONAL_BOOLEAN([verbose], v, [Print debugging information.])
# ARG_POSITIONAL_SINGLE([model], [The Roboflow model to use for inference (required).])
# ARG_POSITIONAL_SINGLE([video_in], [The input video file (required).])
# ARG_POSITIONAL_SINGLE([video_out], [The output video file (required).])
# ARG_DEFAULTS_POS
# ARG_HELP([<Use a Roboflow Trained model to make predictions on a video.>])
# ARGBASH_GO

# [ <-- needed because of Argbash

if [ -z "$ROBOFLOW_KEY" ]; then
    echo "ROBOFLOW_KEY environment variable not found; please set it to your Roboflow API key."
    exit 1
fi

verbose=$_arg_verbose

if [ ! -z "$verbose" ]; then
    printf 'Value of --%s: %s\n' 'host' "$_arg_host"
    printf 'Value of --%s: %s\n' 'confidence' "$_arg_confidence"
    printf 'Value of --%s: %s\n' 'overlap' "$_arg_overlap"
    printf 'Value of --%s: %s\n' 'stroke' "$_arg_stroke"
    printf 'Value of --%s: %s\n' 'labels' "$_arg_labels"
    printf 'Value of --%s: %s\n' 'fps_in' "$_arg_fps_in"
    printf 'Value of --%s: %s\n' 'fps_out' "$_arg_fps_out"
    printf 'Value of --%s: %s\n' 'scale' "$_arg_scale"
    printf 'Value of --%s: %s\n' 'tmp' "$_arg_tmp"
    printf 'Value of --%s: %s\n' 'retries' "$_arg_retries"
    printf 'Value of --%s: %s\n' 'parallel' "$_arg_parallel"
    printf 'Value of --%s: %s\n' 'classes' "$_arg_classes"
    printf 'Value of --%s: %s\n' 'verbose' "$_arg_verbose"
    printf "Value of '%s': %s\\n" 'model' "$_arg_model"
    printf "Value of '%s': %s\\n" 'video_in' "$_arg_video_in"
    printf "Value of '%s': %s\\n" 'video_out' "$_arg_video_out"

    printf "\n"
fi

in=$_arg_video_in
out=$_arg_video_out
tmp=$_arg_tmp
host=$_arg_host
model=$_arg_model
confidence=$_arg_confidence
overlap=$_arg_overlap
stroke=$_arg_stroke
labels=$_arg_labels
classes=$_arg_classes
fps_in=$_arg_fps_in
fps_out=$_arg_fps_out
scale=$_arg_scale

if [ $in = $out ]; then
    echo "Cannot overwrite input file. Please make sure video_in and video_out are different."
    exit 1
fi

# Check dependencies
for command in ffmpeg base64 curl
do
    command -v $command >/dev/null 2>&1 || { echo -en "\n$command needs to be installed but was not found.";deps=1; }
done
[[ $deps -ne 1 ]] || {
    echo -en "\nError: Install the above dependencies and rerun this script\n";
    exit 1;
}

inference_url="$host/$model?access_token=$ROBOFLOW_KEY&format=image&confidence=$confidence&overlap=$overlap&stroke=$stroke"
if [ $labels = "on" ]; then
    inference_url="$inference_url&labels=on"
fi

if [ $classes ]; then
    inference_url="$inference_url&classes=$classes"
fi

if [ ! -z "$verbose" ]; then
    echo "Inference URL: $inference_url"
fi

if [[ $(curl -s $inference_url | grep -e "not authorized" -e "does not exist") ]]; then
    echo "Invalid API Key or Model ID.";
    exit 1;
fi

mkdir -p $tmp/roboflow_in
rm -f $tmp/roboflow_in/*

mkdir -p $tmp/roboflow_out
rm -f $tmp/roboflow_out/*

if [[ $(find "$in" -type f -size +256c 2>/dev/null) ]]; then
    echo "Splitting input video ($in) into frames... this could take a while for large files."
else
    echo "Error: Input file ($in) not found..."
    exit 1
fi

ffmpeg -i $in -r $fps_in -vf scale=iw/$scale:ih/$scale $tmp/roboflow_in/frame%05d.jpg

FILES=$tmp/roboflow_in/frame*.jpg

echo "Running inference on $(ls $tmp/roboflow_in | wc -l | xargs) frames..."
trap 'exit' INT
for x in {0..$_arg_retries}
do
    for f in $FILES
    do
        ((i=i%$_arg_parallel)); ((i++==0)) && wait
        f=$(basename $f)
        if [[ $(find "$tmp/roboflow_out/$f" -type f -size +256c 2>/dev/null) ]]; then
            # this inference was already successful; no need to retry.
            true
        else
            if [ ! -z "$verbose" ]; then
                echo "Running inference on frame $f..."
            fi
            cat $tmp/roboflow_in/$f | base64 | curl -s -d @- $inference_url > "$tmp/roboflow_out/$f" &
        fi
    done
done

rm -f $out
echo "Rendering final video ($out)."
ffmpeg -i $tmp/roboflow_out/frame%05d.jpg -vf fps=$fps_out $out

rm -rf $tmp/roboflow_in
rm -rf $tmp/roboflow_out

# ] <-- needed because of Argbash
