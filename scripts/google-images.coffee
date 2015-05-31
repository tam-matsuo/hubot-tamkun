# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot image なんたら - Google 画像検索です
#   hubot animate なんたら - アニメgif検索
#   hubot hige 画像URL - 画像にヒゲをつけます
#   hubot hige なんたら - 画像検索してからのヒゲをつけます

module.exports = (robot) ->
  robot.respond /(image|img)( me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[3], (url) ->
      msg.send "はいどうぞ #{url}"

  robot.respond /(animate|anime)( me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[3], true, (url) ->
      msg.send "はい #{url}"

  robot.respond /(mustache|hige)( me)? (.*)/i, (msg) ->
    type = Math.floor(Math.random() * 6)
    mustachify = "ヒゲ〜 http://mustachify.me/#{type}?src="
    imagery = msg.match[3]

    if imagery.match /^https?:\/\//i
      msg.send "#{mustachify}#{encodeURIComponent imagery}"
    else
      imageMe msg, imagery, false, true, (url) ->
        msg.send "#{mustachify}#{encodeURIComponent url}"

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image = msg.random images
        cb ensureImageExtension image.unescapedUrl

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"
