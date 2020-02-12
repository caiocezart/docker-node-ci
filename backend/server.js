const express = require('express');
const infoRoute = require('./routes/info');
const environ = require('./lib/environ');

const app = express();
const PORT = environ.servicePort;

app.get('/info', infoRoute)

app.listen(PORT, () => console.log(`app listening on port ${PORT}!`))
