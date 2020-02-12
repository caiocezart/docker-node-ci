const environ = require('../lib/environ');
const winston = require('winston');

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
    };

    if (!result.git_commit_sha){
      throw Error("GIT COMMIT SHA MISSING!")
    }

    winston.debug(`${result}`);
    winston.info(`Request from ${req.hostname} received. Returning info.`);
    
    res.send({
      status: 200,
      body: result
    })
  } catch (err) {
    winston.error(`Something went wrong. ${err}`);    
    res.send({
      status: 500,
      body: String(err)
    });
  }
}

module.exports = info;
