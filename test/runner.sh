#!/bin/sh

export NODE_ENV=test
# export PORT=5000
export CMM_PHP_REPO="http://localhost:$PORT"

# ruby -run -e httpd test/fixtures --port=$PORT &
# server_pid=$!

# mocha --reporter landing --compilers coffee:coffee-script --require test/test_helper.js
mocha
# kill $server_pid
