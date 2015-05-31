# Description:
#   Interacts with the Google Maps API.
#
# Commands:
#   hubot map なんたら - Google Map を検索します

module.exports = (robot) ->

  robot.respond /(?:(satellite|terrain|hybrid)[- ])?map( me)? (.+)/i, (msg) ->
    mapType  = msg.match[2] or "roadmap"
    location = msg.match[3]
    mapUrl   = "http://maps.google.com/maps/api/staticmap?markers=" +
                encodeURIComponent(location) +
                "&size=400x400&maptype=" +
                mapType +
                "&sensor=false" +
                "&format=png" # So campfire knows it's an image
    url      = "http://maps.google.com/maps?q=" +
               encodeURIComponent(location) +
              "&sll=37.0625,-95.677068&sspn=73.579623,100.371094&vpsrc=0&hnear=" +
              encodeURIComponent(location) +
              "&t=m&z=11"

    msg.send "#{msg.match[3]}です〜 #{mapUrl}"
    msg.send url

