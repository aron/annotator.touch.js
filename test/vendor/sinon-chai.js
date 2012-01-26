var assertions = {};
sinon.assert.expose(assertions, {prefix: "", includeFail: false});

for (var prop in assertions) {
  (function (assertion) {
    chai.Assertion.prototype[prop] = function () {
      var args = [].slice.call(arguments);
      assertion.apply(this, [this.obj].concat(args));
    };
  })(assertions[prop]);
}

Object.defineProperty(chai.Assertion.prototype, "was", {
  get: function () {
    return this;
  }
});

sinon.createPromiseStub = function () {
  var promise = sinon.stub(jQuery.Deferred().promise());
  promise.done.returns(promise);
  promise.fail.returns(promise);
  promise.then.returns(promise);
  return promise;
}