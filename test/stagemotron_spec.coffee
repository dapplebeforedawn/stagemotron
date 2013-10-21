assert        = require("assert")
stagemotron  = require("../stagemotron.js")
robot         = require("./support/hubot_mock.js")

featureName = "feature-branch"

assertChat = (expect, done)->
  (chatPost)->
    assert.equal chatPost, expect
    done()

describe 'Stagemotron', ->
  beforeEach ->
    stagemotron('wipe')

  describe 'asking for the pipe contents', ->
    chat = (name)->
      name or= featureName
      "stagemotron, << #{name}"

    it 'resonds with two', (done)->
      sizeReq = "stagemotron, ls"
      expect  = "#{featureName},another-feature"
      r       = robot()
      stagemotron r.setInput(chat())
      stagemotron r.setInput(chat('another-feature'))
      stagemotron r.setInput(sizeReq).setChatRoom(assertChat expect, done)

  describe 'adding a feature to the pipe', ->
    chat = "stagemotron, << #{featureName}"

    it 'lets the first feature start', (done)->
      expect    = "The staging environment is ready for feature-branch"
      r       = robot().setInput(chat).setChatRoom(assertChat expect, done)
      stagemotron(r)

    it 'tells the second feature to wait', (done)->
      expect        = "You're number: 2 in the pipeline"
      firstFeature  = "stagemotron, << a-feature"
      secondFeature = "stagemotron, << another-feature"
      r             = robot()
      stagemotron r.setInput(firstFeature)
      stagemotron r.setInput(secondFeature).setChatRoom(assertChat expect, done)

    it 'increases the pipe length', (done)->
      dumpReq = "stagemotron, dump"
      expect  = JSON.stringify
        pipeline: [ {branch: featureName, lsotd: false} ]
        history:  []
      r       = robot()
      stagemotron r.setInput(chat)
      stagemotron r.setInput(dumpReq).setChatRoom(assertChat expect, done)

  describe 'a user merges master', ->

    it 'notifies the next feature that they can stage', (done)->
      expect        = "The staging environment is ready for next-feature-branch"
      featureSHA    = "415364bea630d56e0fc6d6b5449e8faac613992c"
      firstFeature  = "stagemotron, << feature-branch"
      nextFeature   = "stagemotron, << next-feature-branch"
      r             = robot()

      stagemotron r.setInput(firstFeature)
      stagemotron r.setInput(nextFeature)
      stagemotron r.setInput('/stagemotron')
                    .setPayload(JSON.stringify { sha: featureSHA })  # the masterSHA matches the feature
                    .setChatRoom(assertChat expect, done)




# how do we know when to advance the pipeline?
#   - when the SHA of master == the SHA of head
# how does stagemotron know when the SHA of master has changed?
#   - it gets a POST from the repo-watcher.


#  stagemotron, << name-of-feature-branch     # add your (tested) branch to the pipeline
#  stagemotron, lsotd name-of-feature-branch  # request lsotd status, will alert if already taken.
#  stagemotron, ls                            # list the contents of the pipeline
#  stagemotron, ls | head                     # who's next for staging
#  stagemotron, rm name-of-feature-branch     # remove a feature from the pipeline
