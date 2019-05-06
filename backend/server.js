const express = require('express')
const fs = require('fs')
const path = require('path')

const app = express()
const PORT = process.env.port

if (!PORT) {
  throw Error(`Listening port not defined.`)
}

app.get('/healthcheck', (req, res) => {
  try {
    const staticDescription = 'Technical test example.'
    const result = {
      version: fs
        .readFileSync(path.join(__dirname + '/.appversion'))
        .toString()
        .trim(),
      description: staticDescription,
      lastcommitsha: fs
        .readFileSync(path.join(__dirname + '/.lastcommitsha'))
        .toString()
        .trim()
    }
  } catch (err) {
    res.sendStatus(500)
  }

  res.status(200).send(result)
})

app.listen(PORT, () => console.log(`app listening on port ${PORT}!`))
