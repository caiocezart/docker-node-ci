const environ = require('../lib/environ');
const pino = require('pino');
const logger = pino({ level: environ.logLevel });

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

    logger.debug(`${String(result)}`);
    logger.info(`Request from ${req.hostname} received. Returning info.`);
    
    res.send({
      status: 200,
      body: result
    })
  } catch (err) {
    logger.error(`Something went wrong. ${String(err)}`);    
    res.send({
      status: 500,
      body: String(err)
    });
  }
}

module.exports = info;
