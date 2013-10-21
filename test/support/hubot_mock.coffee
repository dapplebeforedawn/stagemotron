fs           = require("fs")
newChatRoom  = require "./chatroom_mock.js"

module.exports = ()->
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

    post: (data)->
      (callback)->


