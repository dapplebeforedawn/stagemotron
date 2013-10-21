http          = require("http")
assert        = require("assert")
repoWatcher   = require("../repo_watcher.js")
robot         = require("./support/hubot_mock.js")

describe 'RepoWatcher', ->
  it 'POSTs if the SHA changes', (done)->
    chat   = "stagemotron, watch"
    r      = robot().setInput(chat)
    expect =
      sha: '41lkajsdfwe0d56e0fc6d6b5449e8faac613992c'
      type: 'commit'
      url: 'https://api.github.com/repos/cmm/CMM_PHP/git/commits/41lkajsdfwe0d56e0fc6d6b5449e8faac613992c'

    # mockout the POST so we can assert that it's sent
    r.http = (url)->
      get:  robot().http(url).get
      post: (data)->
        (callback)->
          assert.equal JSON.stringify(expect), JSON.stringify(data)
          done()

    repoWatcher(r)
