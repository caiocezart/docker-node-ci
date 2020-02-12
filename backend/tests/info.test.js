const expect = require('chai').expect
const info = require('../routes/info')

let req = {
  body: {}
}

let res = {
  send: function (result) {
    this.status = result.status
  }
}

describe('Info Route', function () {
  describe('info() function', function () {
    it('should return http 200', function () {
      info(req, res)
      expect(res.status).to.equals(200)
    })
  })
})
