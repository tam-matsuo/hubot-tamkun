# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot youtube なんたら - YouTube を検索します
#   hubot music なんたら - YouTubeの音楽カテゴリを検索します

module.exports = (robot) ->

  youtubeQuery = (msg, query, category = null) ->
    url = 'http://gdata.youtube.com/feeds/api/videos?v=2'
    if category
      url += "&category=#{category}"

    robot.http(url)
    .query(
      orderBy: "relevance"
      'max-results': 15
      alt: 'json'
      safeSearch: 'strict'
      q: query
    )
    .get() (err, res, body) ->
      videos = JSON.parse(body)
      videos = videos.feed.entry

      unless videos?
        msg.send "'#{query}' わからんー"
        return

      video = msg.random videos
      video.link.forEach (link) ->
        if link.rel is "alternate" and link.type is "text/html"
          msg.send "ほい #{link.href.replace(/(&.+$)/, '')}"

  robot.respond /(youtube|yt)( me)? (.*)/i, (msg) ->
    youtubeQuery(msg, msg.match[3])

  robot.respond /(music)( me)? (.*)/i, (msg) ->
    youtubeQuery(msg, msg.match[3], 'music')
