CMM_PHP_REPO    = process.env["CMM_PHP_REPO"] # something like: https://api.github.com/repos/dapplebeforedawn/a-test/git/refs/heads
STAGEMOTRON_URL = process.env["STAGEMOTRON_URL"] || 'http://localhost:8080/stagemotron'

module.exports = (robot) ->
  masterURL = "#{CMM_PHP_REPO}/master"
  shutUp    = false
  lastSHA   = ""

  checkForNewMaster = ()->
    return if shutUp
    getMasterSHA (err, ghData)->
      return robot.messageRoom(err) if err
      return if ghData.sha == lastSHA

      lastSHA = ghData.sha
      notifyOfNewMaster(ghData)

  getMasterSHA = (callback)->
    robot.http(masterURL)
      .get() (err, res, body)->
        ghData = JSON.parse(body)
        callback ghData['message'], ghData['object']

  notifyOfNewMaster = (ghData)->
    robot.http(STAGEMOTRON_URL)
      .post(ghData) (err, res, body)->
        console.log "New master pushed to Stagemotron"

  # give it a SHA to bootstrap
  robot.hear /stagemotron, watch\s?(.+)?/i, (msg)->
    lastSHA = msg.match[1] if msg.match[1]
    checkForNewMaster()
    setInterval checkForNewMaster, 1000*60*2

  # a kill switch incase something goes wrong
  robot.hear /stagemotron, shutup/i, (msg)->
    shutUp = true
    msg.send "Stagemotron will sulk in a corner now."
