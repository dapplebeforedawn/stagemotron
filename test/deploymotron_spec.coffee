fs            = require("fs")
assert        = require("assert")
deploymotron  = require("../deploymotron.js")

newChatRoom = (callback)->
  callback or= ->
  say: (message)->
    callback(message)
    message

robot = ()->
  responses   = []
  input       = null
  chatRoom    = newChatRoom()
  payload     = null

  setChatRoom: (chatCallback)->
    chatRoom = newChatRoom(chatCallback)
    this

  setInput: (_input)->
    input = _input
    this

  setPayload: (_payload)->
    payload = _payload
    this

  hear: (regex, robotCallback)->
    match = input.match(regex)
    msg   =
      send:  (response)->
        return chatRoom.say(response)
      match: match

    robotCallback(msg) if match

  messageRoom: (message)->
    chatRoom.say(message)

  router:
    post: (urlPath, callback)->
      return unless input == urlPath
      callback(
        body:
          payload: payload
      )

  http: (url)->
    get: ->
      (callback)->
        filePath = url.match(/[^\/]+$/)[0]
        fs.readFile "test/fixtures/#{filePath}", (err, data)->
          callback err, {}, data.toString()

featureName = "feature-branch"

assertChat = (expect, done)->
  (chatPost)->
    assert.equal expect, chatPost
    done()

describe 'Deploymotron', ->
  beforeEach ->
    deploymotron('wipe')

  describe 'asking for the pipe contents', ->
    chat = (name)->
      name or= featureName
      "deploymotron, << #{name}"

    it 'resonds with two', (done)->
      sizeReq = "deploymotron, ls"
      expect  = "#{featureName},another-feature"
      r       = robot()
      deploymotron r.setInput(chat())
      deploymotron r.setInput(chat('another-feature'))
      deploymotron r.setInput(sizeReq).setChatRoom(assertChat expect, done)

  describe 'adding a feature to the pipe', ->
    chat = "deploymotron, << #{featureName}"

    it 'lets the first feature start', (done)->
      expect    = "The staging environment is ready for feature-branch"
      r       = robot().setInput(chat).setChatRoom(assertChat expect, done)
      deploymotron(r)

    it 'tells the second feature to wait', (done)->
      expect        = "You're number: 2 in the pipeline"
      firstFeature  = "deploymotron, << a-feature"
      secondFeature = "deploymotron, << another-feature"
      r             = robot()
      deploymotron r.setInput(firstFeature)
      deploymotron r.setInput(secondFeature).setChatRoom(assertChat expect, done)

    it 'increases the pipe length', (done)->
      dumpReq = "deploymotron, dump"
      expect  = JSON.stringify([ {branch: featureName, lsotd: false} ])
      r       = robot()
      deploymotron r.setInput(chat)
      deploymotron r.setInput(dumpReq).setChatRoom(assertChat expect, done)

  describe 'a user merges master', ->

    it 'notifies the next feature that they can stage', (done)->
      expect        = "The staging environment is ready for next-feature-branch"
      featureSHA    = "415364bea630d56e0fc6d6b5449e8faac613992c"
      firstFeature  = "deploymotron, << feature-branch"
      nextFeature   = "deploymotron, << next-feature-branch"
      r             = robot()

      deploymotron r.setInput(firstFeature)
      deploymotron r.setInput(nextFeature)
      deploymotron r.setInput('/deploymotron')
                    .setPayload(JSON.stringify { sha: featureSHA })  # the masterSHA matches the feature
                    .setChatRoom(assertChat expect, done)




# how do we know when to advance the pipeline?
#   - when the SHA of master == the SHA of head
# how does deploymotron know when the SHA of master has changed?
#   - it gets a POST from the repo-watcher.


#  deploymotron, << name-of-feature-branch     # add your (tested) branch to the pipeline
#  deploymotron, lsotd name-of-feature-branch  # request lsotd status, will alert if already taken.
#  deploymotron, ls                            # list the contents of the pipeline
#  deploymotron, ls | head                     # who's next for staging
#  deploymotron, rm name-of-feature-branch     # remove a feature from the pipeline
