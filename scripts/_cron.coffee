# Description:
#   tamkun cron
#
# Commands:
#   None

cron = require('cron').CronJob
random = require('hubot').Response::random

module.exports = (robot) ->

  sheets = 'https://spreadsheets.google.com/feeds/cells/1L2AsHmqP9RZRAXmbnUH3Q50-UDMGdC3nDDryAO2mNtg/od6/public/values?alt=json'

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
          tab: item['gs$cell']['$t']
          messages: []
      else if row == 3
        data[col].room = '#' + item['gs$cell']['$t']
      else
        data[col].messages.push item['gs$cell']['$t']

    # cron設定
    for key of data
      cronData = data[key]
      do (cronData) ->
        new cron cronData.tab, ->
          robot.send {room: cronData.room}, random cronData.messages
        , null, true, 'Asia/Tokyo'
