assert        = require("assert")
deploymotron  = require("../deploymotron.js")

assert['hubot'] = (a, b)->
  isValid = (a,b)->
    return true   if (a == b)
    return false  if (a == null || b == null)
    return false  if (a.length != b.length)

    for i in [0...a.length]
      return false if (a[i] != b[i])
    return true
  assert.fail(a, b, undefined, '==') unless isValid(a,b)

robot = (chat)->
  responses = []
  hear: (regex, robotCallback)->
    match = chat.match(regex)
    msg   =
      send:  (response)->
        return response
      match: match

    responses.push robotCallback(msg) if match
    responses

featureName = "feature-branch"

robotDo = (command)->
  deploymotron(robot command)

describe 'Deploymotron', ->
  beforeEach ->
    deploymotron('wipe')

  describe 'asking for the pipe contents', ->
    chat = (name)->
      name or= featureName
      "deploymotron, << #{name}"

    it 'resonds with two', ->
      sizeReq = "deploymotron, ls"
      expect  = "#{featureName},another-feature"
      robotDo chat()
      robotDo chat('another-feature')
      assert.hubot robotDo(sizeReq), [expect]

  describe 'adding a feature to the pipe', ->
    chat = "deploymotron, << #{featureName}"

    it 'responds with the pipe length', ->
      expect  = "You're number: 1 in the pipeline"
      assert.hubot robotDo(chat), [expect]

    it 'increases the pipe length', ->
      dumpReq = "deploymotron, dump"
      expect  = JSON.stringify([ {branch: featureName} ])

      deploymotron(robot chat)
      assert.hubot robotDo(dumpReq), [expect]

  # describe 'the first user being notified that they can stage', ->

  # describe '', ->



#  deploymotron, << name-of-feature-branch     # add your (tested) branch to the pipeline
#  deploymotron, lsotd name-of-feature-branch  # request lsotd status, will alert if already taken.
#  deploymotron, ls                            # list the contents of the pipeline
#  deploymotron, ls | head                     # who's next for staging
#  deploymotron, rm name-of-feature-branch     # remove a feature from the pipeline
