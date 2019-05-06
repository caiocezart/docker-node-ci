const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.port;

if (!PORT) {
    throw Error(`Listening port not defined.`);
}

app.get('/status', function async (req, res) {
    const staticDescription = 'Technical test.';
    const result = {
        version: fs.readFileSync(path.join(__dirname + '/.appversion')).toString().trim(),
        description: staticDescription,
        lastcommitsha: fs.readFileSync(path.join(__dirname + '/.lastcommitsha')).toString().trim()
    }
    res.status(200).send(result);
});

app.get('/healthcheck', (req, res) => {
    res.sendStatus(200);
});

app.listen(PORT, () => console.log(`app listening on port ${PORT}!`));