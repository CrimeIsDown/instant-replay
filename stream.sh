#!/bin/bash

URL="" # the URL to stream
SEGMENT_TIME=1800 # how often we want to split up the recording, in seconds
DIR="." # the directory we want to save the stream files to

for arg; do
    if [[ "$arg" == "-url" ]]; then
        shift
        URL=$1
        shift
    elif [[ "$arg" == "-segment_time" ]]; then
        shift
        SEGMENT_TIME=$1
        shift
    elif [[ "$arg" == "-dir" ]]; then
        shift
        DIR=$1
        shift
    fi
done

if [[ "$URL" == "" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ./stream.sh -url streaming_url [-segment_time 1800] [-dir .]"
    exit
fi

# download the URL defined above
# if connection fails, try to reconnect
# once segment time elapses, erase the current segment and write over it (only when segment_wrap=1)
# ^ we do this to save disk space
ffmpeg -loglevel warning -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 2 -i "$URL" -c copy -f segment -segment_time $SEGMENT_TIME -segment_wrap 1 "$DIR/%01d.mp3"
