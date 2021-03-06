// Generated by CoffeeScript 1.4.0
(function() {
  var assert, http, repoWatcher, robot;

  http = require("http");

  assert = require("assert");

  repoWatcher = require("../repo_watcher.js");

  robot = require("./support/hubot_mock.js");

  describe('RepoWatcher', function() {
    return it('POSTs if the SHA changes', function(done) {
      var chat, expect, r;
      chat = "stagemotron, watch";
      r = robot().setInput(chat);
      expect = {
        sha: '41lkajsdfwe0d56e0fc6d6b5449e8faac613992c',
        type: 'commit',
        url: 'https://api.github.com/repos/cmm/CMM_PHP/git/commits/41lkajsdfwe0d56e0fc6d6b5449e8faac613992c'
      };
      r.http = function(url) {
        return {
          get: robot().http(url).get,
          post: function(data) {
            return function(callback) {
              assert.equal(JSON.stringify(expect), JSON.stringify(data));
              return done();
            };
          }
        };
      };
      return repoWatcher(r);
    });
  });

}).call(this);
