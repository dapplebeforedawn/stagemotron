// Generated by CoffeeScript 1.4.0
(function() {
  var CMM_PHP_REPO, STAGEMOTRON_URL;

  CMM_PHP_REPO = process.env["CMM_PHP_REPO"];

  STAGEMOTRON_URL = process.env["STAGEMOTRON_URL"] || 'http://localhost:8080/stagemotron';

  module.exports = function(robot) {
    var checkForNewMaster, getMasterSHA, lastSHA, masterURL, notifyOfNewMaster, shutUp;
    masterURL = "" + CMM_PHP_REPO + "/master";
    shutUp = false;
    lastSHA = "";
    checkForNewMaster = function() {
      if (shutUp) {
        return;
      }
      return getMasterSHA(function(err, ghData) {
        if (err) {
          return robot.messageRoom(err);
        }
        if (ghData.sha === lastSHA) {
          return;
        }
        lastSHA = ghData.sha;
        return notifyOfNewMaster(ghData);
      });
    };
    getMasterSHA = function(callback) {
      return robot.http(masterURL).get()(function(err, res, body) {
        var ghData;
        ghData = JSON.parse(body);
        return callback(ghData['message'], ghData['object']);
      });
    };
    notifyOfNewMaster = function(ghData) {
      return robot.http(STAGEMOTRON_URL).post(ghData)(function(err, res, body) {
        return console.log("New master pushed to Stagemotron");
      });
    };
    robot.hear(/stagemotron, watch\s?(.+)?/i, function(msg) {
      if (msg.match[1]) {
        lastSHA = msg.match[1];
      }
      checkForNewMaster();
      return setInterval(checkForNewMaster, 1000 * 60 * 2);
    });
    return robot.hear(/stagemotron, shutup/i, function(msg) {
      shutUp = true;
      return msg.send("Stagemotron will sulk in a corner now.");
    });
  };

}).call(this);
