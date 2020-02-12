const express = require('express');
const infoRoute = require('./routes/info');
const environ = require('./lib/environ.js');
const pino = require('pino');
const expressPino = require('express-pino-logger');

const logger = pino({ level: environ.logLevel });
const expressLogger = expressPino({ logger });

const app = express();
const PORT = environ.servicePort;

app.use(expressLogger);
app.get('/info', infoRoute)

app.listen(PORT, () => logger.info(`app listening on port ${PORT}!`))
