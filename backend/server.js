const express = require('express');
const infoRoute = require('./routes/info');
const environ = require('./lib/environ');
const winston = require('winston');

try {
    const console = new winston.transports.Console();
    winston.format = winston.format.splat();
    winston.level = environ.logLevel;
    winston.add(console);

    const app = express();
    const PORT = environ.servicePort;

    app.get('/info', infoRoute)

    app.listen(PORT, () => winston.info(`app listening on port ${PORT}!`))

} catch (err) {
    winston.error(`Something went wrong. ${err}`);
}
