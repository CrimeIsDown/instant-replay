#!/bin/bash
ORIGINAL=`ls -t *.mp3 | head -n 1` # the file which was modified most recently (most recent ffmpeg segment)
OUTPUT="output/lastminute.mp3" # the name of our output file (@TODO: needs to be unique)

# let's get the last 10 minutes (600s) of the stream so we don't work with a very large file
ffmpeg -sseof -600 -t 600 -i $ORIGINAL -f mp3 - |

# check if the user doesn't want much silence in their recording (otherwise just save the output)
( [[ "$1" == "nosilence" ]] && sox -t mp3 - -t mp3 $OUTPUT.tmp silence -l 1 0.5 1.07% -1 0.5 1.07% || cat > $OUTPUT.tmp )
# remove the silence from the last 10 minutes of audio
# silence longer than 0.5s will get truncated to 0.5s
# "silence" is defined as being over the 1.07% threshold
# (arrived at this number thru trial-and-error working with the Zone 10 stream)

# get the last 60 seconds of the mp3, and write it to our output file
ffmpeg -sseof -60 -t 60 -i $OUTPUT.tmp -c copy $OUTPUT -y
# this cannot be done with pipes because we need to use sseof

# remove the temporary file
rm $OUTPUT.tmp

# play the generated file
mpg123 $OUTPUT

