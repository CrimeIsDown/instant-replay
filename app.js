#!/usr/bin/env node
'use strict';

const child_process = require('child_process');
const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const querystring = require('querystring');
const HOST = process.env.SERVER_HOST || 'localhost';
const PORT = process.env.SERVER_PORT || 8080;
const DEBUG = process.env.APP_DEBUG || true;

const streams = require('./online_streams.json');

function log(message, isError) {
  if (isError) {
    console.error(message);
  } else {
    console.log(message);
  }
}

function getReplay(stream_name, duration, trim_silence, callback) {
  let token = crypto.randomBytes(16).toString('hex');
  let outputfile = 'output/'+token+'.mp3';
  let replayopts = [
    './replay.sh',
    '-duration', duration,
    '-original', 'streams/'+stream_name+'/0.mp3',
    '-output', outputfile
  ];
  if (trim_silence) {
    replayopts.push('-trimsilence');
  }
  let proc = child_process.spawn('bash', replayopts);
  proc.stdout.on('data', (data) => {
		log(`stdout: ${data}`);
	});
	proc.stderr.on('data', (data) => {
		log(`stderr: ${data}`, true);
	});
	proc.on('close', (code) => {
		log(`child process exited with code ${code}`);
    callback(outputfile);
	});
}

function serveReplay(filename, stream_name, response) {
  fs.readFile(filename, 'binary', (err, file) => {
    if (err) {
      response.statusCode = 500;
      response.setHeader('Content-Type', 'text/plain');
      response.write(err + '\n');
      response.end();
      return;
    }
    response.statusCode = 200;
    response.setHeader('Content-Type', 'audio/mpeg');
    response.setHeader('Content-Disposition', 'inline; filename="'+stream_name+'.mp3"');
    response.write(file, 'binary');
    response.end();
  });
}

function handleRequest(request, response) {
  if (request.url.indexOf('/replay/')==0 && request.method == 'GET') {
    let stream_name = request.url.substring('/replay/'.length);
    let opts = {
      duration: '60',
      trimsilence: 'false'
    };
    if (request.url.indexOf('?')!==-1) {
      stream_name = request.url.substring('/replay/'.length, request.url.indexOf('?'));
      opts = querystring.parse(request.url.substring(request.url.indexOf('?')+1));
    }
    if (streams.hasOwnProperty(stream_name)) {
      getReplay(stream_name, opts.duration, opts.trimsilence=='true', (filename) => {
        serveReplay(filename, stream_name, response);
      });
    } else {
      response.statusCode = 400;
      response.end();
    }
  } else {
    response.statusCode = 403;
    response.end();
  }
}

let server = http.createServer(handleRequest);

server.listen(PORT, HOST, () => {
  console.log("Server listening on: http://%s:%s", HOST, PORT);
});
