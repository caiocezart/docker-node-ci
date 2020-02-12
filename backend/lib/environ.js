const environ = {};

environ.logLevel = process.env['LOG_LEVEL'] || 'info';
environ.serviceName = process.env['SERVICE_NAME'] || 'caio-api';
environ.serviceVersion = process.env['SERVICE_VERSION'] || '1.0.0';
environ.servicePort = process.env['SERVICE_PORT'] || '5000';
environ.gitSha = process.env['GIT_SHA'] || '';

module.exports = environ;
