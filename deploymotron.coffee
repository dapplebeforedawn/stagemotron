pipeline     = []
history      = []
CMM_PHP_REPO = process.env["CMM_PHP_REPO"] # something like: https://api.github.com/repos/dapplebeforedawn/a-test/git/refs/heads

module.exports = (robot) ->

  # a helper fuction for specs, cause mocha is no rspec
  if robot == "wipe"
    pipeline = []
    return {}

  newPipeUnit = (featureName)->
    branch: featureName
    lsotd:  false

  branchUrl = (branchName)->
    "#{CMM_PHP_REPO}/#{branchName}"

  getSHAofBranch = (branchName, callback)->
    robot.http(branchUrl branchName)
      # .header('Accept', 'application/json')
      .get() (err, res, body)->
        ghData = JSON.parse(body)
        callback ghData['message'], ghData['object']

  readyForBranch = (branch)->
    robot.messageRoom "The staging environment is ready for #{branch}"

  shaMatches = (masterSHA, pipeSHA)->
    history.push pipeline.shift()
    readyForBranch pipeline[0].branch if pipeline[0]

  shaChange =
    true:  shaMatches
    false: (masterSHA, pipeSHA)->
      robot.messageRoom(
        """
        Master was updated, but doesn't match the SHA at the front of the pipe
            Master: #{masterSHA}
          Pipeline: #{pipeSHA}
        """
      )

  # the SHA of master has changed
  # check the SHA of the front of the pipeline to see if they are
  # the same.  If so, notify the next guy
  robot.router.post '/deploymotron', (req, res)->
    return unless pipeline[0]
    masterSHA = JSON.parse(req.body.payload)['sha']
    getSHAofBranch pipeline[0].branch, (err, ghData)->
      return robot.messageRoom(err) if err
      shaChange[masterSHA == ghData.sha](masterSHA, ghData.sha)

  robot.hear /deploymotron, ls/i, (msg)->
    msg.send "" + pipeline.map (pipeUnit)->
      pipeUnit.branch

  robot.hear /deploymotron, << (.+)/i, (msg)->
    feature = msg.match[1]
    newUnit = newPipeUnit(feature)
    pipeline.push newUnit
    if pipeline.length > 1
      msg.send "You're number: #{pipeline.length} in the pipeline"
    else
      readyForBranch newUnit.branch


  robot.hear /deploymotron, dump/i, (msg)->
    msg.send JSON.stringify
      pipeline: pipeline
      history:  history

