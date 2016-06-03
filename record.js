#!/usr/bin/env node
'use strict';

const child_process = require('child_process');
const fs = require('fs');

const streams = require('./online_streams.json');

function log(message, isError) {
  if (isError) {
    console.error(message);
  } else {
    console.log(message);
  }
}

function startRecording(callback) {
  for (let key in streams) {
    if (streams.hasOwnProperty(key)) {
      let stream = streams[key];
      if (!fs.existsSync('./streams/' + key)) {
        fs.mkdirSync('./streams/' + key);
      }
      let proc = child_process.spawn('bash', ['./stream.sh', '-url', stream.directStreamUrl, '-dir', 'streams/' + key]);
      proc.stdout.on('data', (data) => {
        log(`stdout: ${data}`);
      });
      proc.stderr.on('data', (data) => {
        log(`stderr: ${data}`, true);
      });
      proc.on('close', (code) => {
        log(`child process exited with code ${code}`);
      });
    }
  }
  callback();
}

startRecording(() => {
  console.log("Recording started");
});
