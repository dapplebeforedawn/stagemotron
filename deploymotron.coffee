pipeline = []
module.exports = (robot) ->

  newPipeUnit = (featureName)->
    { branch: featureName }

  # a helper fuction for specs, cause mocha is no rspec
  if robot == "wipe"
    pipeline = []
    return {}

  robot.hear /deploymotron, ls/i, (msg)->
    msg.send "" + pipeline.map (pipeUnit)->
      pipeUnit.branch

  robot.hear /deploymotron, << (.+)/i, (msg)->
    feature = msg.match[1]
    pipeline.push newPipeUnit(feature)
    msg.send "You're number: #{pipeline.length} in the pipeline"

  robot.hear /deploymotron, dump/i, (msg)->
    msg.send JSON.stringify(pipeline)

