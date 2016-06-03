#!/usr/bin/env node
'use strict';

const child_process = require('child_process');
const fs = require('fs');
const http = require('http');
const PORT = 8080;

const streams = require('./online_streams.json');

function startRecording() {
  for (let key in streams) {
    if (streams.hasOwnProperty(key)) {
      let stream = streams[key];
      if (!fs.existsSync('./streams/' + key)) {
        fs.mkdirSync('./streams/' + key);
      }
      let proc = child_process.spawn('bash', ['./stream.sh', '-url', stream.directStreamUrl, '-dir', 'streams/' + key]);
      proc.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
      });
      proc.stderr.on('data', (data) => {
        console.log(`stderr: ${data}`);
      });
      proc.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
      });
    }
  }
}

function handleRequest(request, response) {
  if (request.url == '/hi' && request.method == 'GET') {
    response.setHeader('Content-Type', 'text/plain');
    response.end("Welcome to the server!");
  } else {
    response.statusCode = 403;
    response.end();
  }
}

let server = http.createServer(handleRequest);

server.listen(PORT, () => {
  console.log("Server listening on: http://localhost:%s", PORT);
});

startRecording();
