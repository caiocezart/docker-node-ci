const express = require('express')
const healthcheckRoute = require('./routes/healthcheck')
const fs = require('fs')
const path = require('path')

const app = express()
const PORT = process.env.port

if (!PORT) {
  throw Error(`Listening port not defined.`)
}

app.get('/healthcheck', healthcheckRoute)

app.listen(PORT, () => console.log(`app listening on port ${PORT}!`))
