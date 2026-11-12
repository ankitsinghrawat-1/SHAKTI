const http = require('http');
const app = require('./app');
const config = require('./config');

const server = http.createServer(app);

server.listen(config.port, config.host, () => {
  console.log(`SHAKTI backend listening on http://${config.host}:${config.port}`);
  console.log(`API base: http://localhost:${config.port}${config.apiPrefix}`);
});

module.exports = server;
