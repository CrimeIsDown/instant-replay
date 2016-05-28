#!/bin/bash
ORIGINAL=`ls -t *.mp3 | head -n 1` # the file which was modified most recently (most recent ffmpeg segment)
NOSILENCE="output/lastminute-nosilence.mp3" # the name of our temporary file
OUTPUT="output/lastminute.mp3" # the name of our output file

# the user doesn't want much silence in their recording
if [ "$1" == "nosilence" ]; then
    # let's get the last 10 minutes (600s) of the stream so we don't work with a very large file
    ffmpeg -sseof -600 -t 600 -i $ORIGINAL "output/last10min.mp3"
    # remove the silence from the last 10 minutes of audio
    # silence longer than 1s will get truncated to 0.5s
    # "silence" is defined as being over the 1.07% threshold
    # (arrived at this number thru trial-and-error working with the Zone 10 stream)
    sox "output/last10min.mp3" $NOSILENCE silence -l 1 0.5 1.07% -1 1.0 1.07%
    rm "output/last10min.mp3" # remove our temporary file
    # pull the last 30 seconds from our silence-removed file, not the original mp3
    ORIGINAL=$NOSILENCE
fi

# get the last 60 seconds of the mp3, and write it to our output file
ffmpeg -sseof -60 -t 60 -i $ORIGINAL -c copy $OUTPUT -y
rm $NOSILENCE

# play the generated file
mpg123 $OUTPUT
