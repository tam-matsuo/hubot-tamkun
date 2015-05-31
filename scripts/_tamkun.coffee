# Description:
#   tamkun
#
# Commands:
#   @tamkun - てきとうに相槌をうちます

module.exports = (robot) ->

  #
  # reply設定
  #
  sheets = process.env.TAMKUN_SHEET_REPLY ? null
  if ! sheets
    return

  robot.http(sheets).get() (err, res, body) ->

    data = {}

    # スプレッドシート json解析
    sheetData =  JSON.parse body
    for item in sheetData.feed.entry
      row = parseInt item['gs$cell']['row']
      col = parseInt item['gs$cell']['col']
      if col < 2 || row < 2
        # 見出しはスルー
        continue

      if row == 2
        data[col] =
          regex: item['gs$cell']['$t']
          messages: []
      else
        data[col].messages.push item['gs$cell']['$t']


    # reply用の robot.hear を仕込む
    for key of data
      replyData = data[key]
      do (replyData) ->
        regexp = new RegExp replyData.regex, 'i'
        robot.hear regexp, (msg) ->
          setTimeout ->
            msg.send msg.random replyData.messages
          , 1000


  # http post
  # https://tamkun.herokuapp.com/hubot/post_message
  #   {
  #	    "message": "MESSAGE",
  #	    "room": "#ROOM NAME",
  #	    "key": "SECRET KEY"
  #   }
  robot.router.post '/hubot/post_message', (req, res) ->

    secretKey = process.env.TAMKUN_SECRET ? null
    if ! secretKey
      return

    body = req.body

    if ! body.message
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'no message\n'
      return
    if body.key != secretKey
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'invalid key\n'
      return

    room = body.room
    envelope = robot.brain.userForId 'broadcast'
    envelope.user = {}
    envelope.user.room = envelope.room = room if room
    envelope.user.type = body.type or 'groupchat'

    robot.send envelope, body.message

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'
