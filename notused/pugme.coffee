# Description:
#   Pugme is the most important thing in life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot pug - いぬの画像をランダムに
#   hubot cat WIDTH HEIGHT - ねこの画像をランダムに (横と縦のサイズを指定できます)

module.exports = (robot) ->

  robot.respond /pug( me)?/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/random")
      .get() (err, res, body) ->
        msg.send "いぬ〜 " + JSON.parse(body).pug

  robot.respond /pug bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    msg.http("http://pugme.herokuapp.com/bomb?count=" + count)
      .get() (err, res, body) ->
        msg.send pug for pug in JSON.parse(body).pugs

  robot.respond /how many pugs are there/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/count")
      .get() (err, res, body) ->
        msg.send "There are #{JSON.parse(body).pug_count} pugs."

  robot.respond /cat( me)?( \d*)?( \d*)?/i, (msg) ->
    w = if msg.match[2] > 0 then parseInt(msg.match[2]) else 300
    h = if msg.match[3] > 0 then parseInt(msg.match[3]) else 200
    msg.send "ねこ〜 http://placekitten.com/g/#{w}/#{h}"

