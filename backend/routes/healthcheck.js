const fs = require('fs')

function healthcheck (req, res) {
  try {
    const staticDescription = 'Technical test example.'
    const result = {
      version: fs
        .readFileSync(__dirname + '/../.appversion')
        .toString()
        .trim(),
      description: staticDescription,
      lastcommitsha: fs
        .readFileSync(__dirname + '/../.lastcommitsha')
        .toString()
        .trim()
    }

    res.send({
      status: 200,
      body: result
    })
  } catch (err) {
    res.send({
      status: 500,
      error: err
    })
  }
}

module.exports = healthcheck
