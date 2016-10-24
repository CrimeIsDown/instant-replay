# instant-replay
Replay recent #ChicagoScanner audio from Broadcastify streams.

Warning: This software is experimental. Use at your own risk.

## Getting Started

### Software required

You will need (or at least, this is what I used):

- ffmpeg 3.x (version 3.x isn't usually available through package managers)
- SoX 14.x (with MP3 support)
- LAME mp3 encoding library

To install all of these on Ubuntu 16.04:

```shell
sudo add-apt-repository ppa:djcj/hybrid
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get install ffmpeg sox libsox-fmt-mp3 lame
```

### Using the shell scripts

Start two terminals in this directory.

In one, run `./stream.sh -url URL_TO_RECORD` to start the stream recording.

Once you hear something interesting and want to hear it again, run `./replay.sh` to get the last 60 seconds
of audio (soon to be a variable amount). If you want to get the last 60 seconds of actual transmissions (with
silence >0.5s truncated to 0.5s) then run `./replay.sh -trimsilence`.

Execute `./stream.sh -h` for help with streaming or `./replay.sh -h` for help with replaying. The usage will
be displayed.

### Using the web server

1. In one terminal, run `node record.js` to start recording all the
   streams in `online_streams.json`.
2. In another terminal, run `node app.js`
   to start the web server, modifying the different environment
   variables to suit your needs.

The server has the following URL structure:

`http://SERVER_HOST:SERVER_PORT/replay/STREAM_KEY?duration=DURATION_IN_SECONDS&trimsilence=TRUE_OR_FALSE`

where `STREAM_KEY` is one of the keys for the main JSON object in the
`online_streams.json` file. For example:
`http://SERVER_HOST:SERVER_PORT/replay/Z1?duration=60&trimsilence=true`

## Project Goal

I envision #ChicagoScanner listeners being able to click a button and get the last minute (or user-defined duration)
of audio for a given feed on Broadcastify.

Process on the frontend:

1. User selects Broadcastify feed from a list of ones the backend is already recording
2. If the user wants to remove silence and just get the last 60 seconds of transmissions, they check a box to do so.
3. User clicks "Replay" button (or something else) and that will tell the backend to run the `./getlastminute.sh`
   script, generating the audio and then sending the file back to the browser for streaming or downloading.

On the backend:

1. `./stream.sh` is run for each feed we want to record. This will record up to the last 30 minutes of audio,
   resetting every 30 minutes.
2. Backend server gets a request from the frontend for a certain feed recording.
3. Backend will execute `./getlastminute.sh`, passing along the user's preferences. Once an MP3 is generated, it
   will respond to the frontend with the contents of the MP3.

In the future, we always want to ensure the recording has the last minute of audio regardless when a segment was
last created, so perhaps some sort of rotation process will need to be implemented. For example, while a new
segment is accumulating audio, can combine the last part of the old segment with the new segment to get an
uninterrupted, full stream. Then when the new segment gets enough audio, we can switch over the backend server
to use just the new segment for generating recordings.

### Other Notes

If we use a longer segment duration, which usually means less recording rotations, there is a higher chance
for the stream to go down and not recover quickly. This will impact recording availablity. Additionally a longer
segment will use more storage space. However, if we use a shorter segment duration which reconnects to the stream
more frequently, then this will use less disk space, but may be more complex as we need to manage recording rotation.

For now we will try a segment time of 30 minutes as a balance between long durations and high availability.

To calculate the filesize of a segment: 2KB * [number of seconds in a segment]

Multiply that by 14 (13 zone feeds plus 1 citywide feed) to get the minimum storage space required for recordings.
