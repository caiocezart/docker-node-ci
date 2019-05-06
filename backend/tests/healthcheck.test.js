const expect = require('chai').expect
const healthcheck = require('../routes/healthcheck')

let req = {
  body: {}
}

let res = {
  send: function (result) {
    this.status = result.status
  }
}

describe('Healthcheck Route', function () {
  describe('healthcheck() function', function () {
    it('should return http 200', function () {
      healthcheck(req, res)
      expect(res.status).to.equals(200)
    })
  })
})
