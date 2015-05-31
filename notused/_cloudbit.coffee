# Description:
#   cloudbit
#
# Commands:
#   hubot cloudbit 5 - cloudbit に 5秒 信号を送ります

_DEVICE_ID = '00e04c1e822a'
_ACCESS_TOKEN = 'becd3a00dd00e2d14af4113a5f4d75e4eb597534e8ed6bc4018809dfbd48e9c9'

module.exports = (robot) ->
  robot.respond /cloudbit (\d+)/i, (msg) ->
    data = JSON.stringify
      percent: 100
      duration_ms: msg.match[1] * 1000

    robot.http("https://api-http.littlebitscloud.cc/devices/#{_DEVICE_ID}/output")
    .header('Authorization', "Bearer #{_ACCESS_TOKEN}")
    .header('Accept', 'application/vnd.littlebits.v2+json')
    .header('Content-Type', 'application/json')
    .post(data) (err, res, body) ->
      msg.send 'ピコーン'
