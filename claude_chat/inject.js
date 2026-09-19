'use strict';
const net = require('net');
const fs = require('fs');

const keyPath = process.argv[2];
const pipePath = process.argv[3];
const message = process.argv[4];
if (!keyPath || !pipePath || !message) {
  console.error('usage: node inject.js <key.json> <pipe-path> <message>');
  process.exit(2);
}

const key = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
const token = key.peerToken;
if (typeof token !== 'string' || token.length < 8) {
  console.error('key file has no usable peerToken');
  process.exit(2);
}

const payload =
  JSON.stringify({type: 'auth', token}) + '\n' +
  JSON.stringify({type: 'user', message: {role: 'user', content: message}}) + '\n';

const started = Date.now();
const c = net.connect(pipePath);
let inbound = Buffer.alloc(0);
c.setTimeout(8000);
c.on('connect', () => {
  console.log('connected', Date.now() - started, 'ms');
  c.write(payload, (err) => {
    if (err) console.error('write_err', err.message);
    else console.log('wrote', Buffer.byteLength(payload), 'bytes');
    setTimeout(() => c.end(), 500);
  });
});
c.on('data', (d) => { inbound = Buffer.concat([inbound, d]); });
c.on('timeout', () => { console.log('timeout'); c.destroy(); });
c.on('error', (e) => { console.error('ERR', e.message); process.exitCode = 2; });
c.on('close', () => {
  console.log('closed inbound_bytes', inbound.length, 'elapsed_ms', Date.now() - started);
  if (inbound.length) console.log('REPLY_PRESENT');
  else console.log('NO_REPLY_ON_SOCKET');
});
