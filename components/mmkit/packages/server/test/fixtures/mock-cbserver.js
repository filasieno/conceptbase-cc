#!/usr/bin/env node
"use strict";

const net = require("node:net");

let port = 4001;
for (let i = 0; i < process.argv.length; i += 1) {
  if (process.argv[i] === "-p" && process.argv[i + 1] !== undefined) {
    port = Number.parseInt(process.argv[i + 1], 10);
    i += 1;
  }
}

const server = net.createServer((socket) => {
  socket.end();
});

server.listen(port, "127.0.0.1", () => {
  process.stdout.write(`mock-cbserver listening on ${port}\n`);
});

function shutdown(code) {
  server.close(() => {
    process.exit(code);
  });
}

process.on("SIGTERM", () => shutdown(0));
process.on("SIGINT", () => shutdown(0));
