const expect = require('chai').expect;
const environ = require('../lib/environ');
const info = require('../routes/info');

let req = {
  body: {}
};

let res = {
  send: function (result) {
    this.status = result.status;
  }
};

describe('Should pass tests', function () {
  before(function (){
    environ.gitSha = "12344";
  });

  it('GIT SHA was provided - should return http 200', function () {
    info(req, res);
    expect(res.status).to.equals(200);
  });

  after(function () {
    environ.gitSha = "";
  });
});

describe('Should fail tests', function () {

  it('missing GIT SHA - should return http 500', function () {
    info(req, res);
    expect(res.status).to.equals(500);
  });
});
