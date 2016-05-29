#!/bin/bash

END_OFFSET=60
TRIMSILENCE=0
ORIGINAL=""
OUTPUT="output/lastminute.mp3" # the name of our output file (@TODO: needs to be unique)

for arg; do
    if [[ "$arg" == "-duration" ]]; then
        shift
        if [[ $1 -gt 600 ]]; then
            echo "Error: Replay duration must be under 600 seconds (10 minutes)"
            exit
        fi
        END_OFFSET=$1
        shift
    elif [[ "$arg" == "-trimsilence" ]]; then
        shift
        TRIMSILENCE=1
    elif [[ "$arg" == "-original" ]]; then
        shift
        ORIGINAL=$1
        shift
    elif [[ "$arg" == "-output" ]]; then
        shift
        OUTPUT=$1
        shift
    elif [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        echo "Usage: ./replay.sh [-duration 60] [-trimsilence] [-original 0.mp3] [-output output/lastminute.mp3]"
        exit
    fi
done

if [[ "$ORIGINAL" == "" ]]; then
    ORIGINAL=`ls -t *.mp3 | head -n 1` # the file which was modified most recently (most recent ffmpeg segment)
    if [[ "$ORIGINAL" == "" ]]; then
        echo "Error: No MP3 file available to read. Use ./replay.sh -h for help."
        exit
    fi
fi

# let's get the last 10 minutes (600s) of the stream so we don't work with a very large file
ffmpeg -sseof -600 -t 600 -i $ORIGINAL -f mp3 - |

# check if the user doesn't want much silence in their recording (otherwise just save the output)
( [[ $TRIMSILENCE -gt 0 ]] && sox -t mp3 - -t mp3 $OUTPUT.tmp silence -l 1 0.5 1.07% -1 0.5 1.07% || cat > $OUTPUT.tmp )
# remove the silence from the last 10 minutes of audio
# silence longer than 0.5s will get truncated to 0.5s
# "silence" is defined as being over the 1.07% threshold
# (arrived at this number thru trial-and-error working with the Zone 10 stream)

# get the last 60 seconds of the mp3, and write it to our output file
ffmpeg -sseof -$END_OFFSET -t $END_OFFSET -i $OUTPUT.tmp -c copy $OUTPUT -y
# this cannot be done with pipes because we need to use sseof

# remove the temporary file
rm $OUTPUT.tmp

echo "File generated: $OUTPUT"
