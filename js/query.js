var Query, Spine, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

Spine = require("spine");

_ = require("lodash");

Query = (function(_super) {
  __extends(Query, _super);

  Query.include(Spine.Events);

  Query.prototype.BASE_URL = "https://en.wikipedia.org/w/api.php";

  Query.prototype.BASE_OPTIONS = {
    format: "json",
    action: "help"
  };

  function Query(options) {
    this.options = options != null ? options : {};
    this.publish = __bind(this.publish, this);
    this.xhr = __bind(this.xhr, this);
  }

  Query.prototype.url = function() {
    return this.BASE_URL + this.url_encode(this.full_options());
  };

  Query.prototype.perform = function() {
    return this.xhr().send();
  };

  Query.prototype.options = function() {
    return {};
  };

  Query.prototype.full_options = function() {
    return _.extend(this.BASE_OPTIONS, this.options);
  };

  Query.prototype.url_encode = function(options) {
    return _.chain(options).pairs().map(function(pair) {
      return pair.join("=");
    }).reduce((function(memo, pair) {
      if (memo === "?") {
        return memo + pair;
      } else {
        return memo + "&" + pair;
      }
    }), "?").value();
  };

  Query.prototype.xhr = function() {
    var xhr;
    xhr = new XMLHttpRequest();
    xhr.onerror = this.publish("error");
    xhr.onload = this.publish("complete");
    xhr.onprogress = this.publish("progress");
    xhr.open("GET", this.url(), true);
    return xhr;
  };

  Query.prototype.publish = function(message) {
    return (function(_this) {
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.trigger.apply(_this, [message].concat(args));
      };
    })(this);
  };

  return Query;

})(Spine.Module);

module.exports = Query;