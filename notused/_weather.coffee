# Description:
#   weather
#
# Commands:
#   hubot tenki - 明日の天気をしらべます

cron = require('cron').CronJob
request = require 'request'
cheerio = require 'cheerio'


module.exports = (robot) ->

  new cron '0 0 17 * * 1-5', ->
    getWeather (weather) ->
      if weather.rainTokyo > 30 || weather.rainOsaka > 30
        robot.send {room: '#random'}, weather.text
  , null, true, 'Asia/Tokyo'


  robot.respond /(tenki|weather)( me)?/i, (msg) ->
    getWeather (weather) ->
      msg.send weather.text


  # get weather from yahoo (scraping)
  getWeather = (cb) ->
    options =
      url: 'http://weather.yahoo.co.jp/weather/?day=2'
      timeout: 2000
      headers: {'user-agent': 'node title fetcher'}

    request options, (error, response, body) ->
      $ = cheerio.load body
      w =
        date: $('#navCal .current em').text()
        weatherTokyo: $('.pt4410 .forecast > span').text()
        weatherOsaka: $('.pt6200 .forecast > span').text()
        rainTokyo: parseInt $('.pt4410 .precip').text()
        rainOsaka: parseInt $('.pt6200 .precip').text()

      if w.rainTokyo > 50 && w.rainOsaka > 50
        w.text = '明日は東京も大阪も雨っぽいよ'
      else if w.rainTokyo > 50
        w.text = '明日は東京は傘いりそうねー'
      else if w.rainOsaka > 50
        w.text = '明日の大阪、傘いりそうねー'
      else if w.rainTokyo > 30 && w.rainOsaka > 30
        w.text = '明日は東京も大阪も微妙な天気っぽい'
      else if w.rainTokyo > 30
        w.text = '明日の東京、雨降るかもねー'
      else if w.rainOsaka > 30
        w.text = '明日、大阪は雨降るかもねー'
      else
        w.text = '明日は東京も大阪も、雨だいじょうぶっぽいよ'

      w.text += " (#{w.date}日 東京:#{w.weatherTokyo} #{w.rainTokyo}% / 大阪:#{w.weatherOsaka} #{w.rainOsaka}%)"
      cb w
