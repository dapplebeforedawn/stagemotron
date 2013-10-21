module.exports = (callback)->
  callback or= ->
  say: (message)->
    callback(message)
    message

