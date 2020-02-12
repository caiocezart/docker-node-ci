const environ = require('../lib/environ');

function info(req, res) {
  try {  
    const result = {
      service_name: environ.serviceName,
      version: environ.serviceVersion,
      git_commit_sha: environ.gitSha,
      environment: {
        service_port: environ.servicePort,
        log_level: environ.logLevel
      }
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

module.exports = info
