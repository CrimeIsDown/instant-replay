#!/bin/bash
URL=$1 # the URL to stream
SEGMENT_TIME=${2-1800} # how often we want to split up the recording, in seconds
DIR=${3-"."} # the directory we want to save the stream files to

if [ "$1" == "" ]; then
    echo "Usage: ./stream.sh streaming_url [segment_time [output_directory]]"
    exit
fi

# download the URL defined above
# if connection fails, try to reconnect
# once segment time elapses, erase the current segment and write over it (only when segment_wrap=1)
# ^ we do this to save disk space
ffmpeg -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 2 -i "$URL" -c copy -f segment -segment_time $SEGMENT_TIME -segment_wrap 1 "$DIR/%01d.mp3"
