#!/bin/bash
#url="http://audio5.broadcastify.com/il_chicago_police2.mp3" # the main CPD feed
URL="http://relay.broadcastify.com/716183595.mp3" # Zone 10

# 1800 = 30min
SEGMENT_TIME=1800 # how often we want to split up the recording, in seconds

# download the URL defined above
# if connection fails, try to reconnect
# once segment time elapses, erase the current segment and write over it (only when segment_wrap=1)
# ^ we do this to save disk space
ffmpeg -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 2 -i "$URL" -c copy -f segment -segment_time $SEGMENT_TIME -segment_wrap 1 %01d.mp3
