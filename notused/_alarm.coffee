# Description:
#   alarm and timer
#
# Commands:
#   hubot timer 5 - 5分後にお知らせします
#   hubot alarm 19:00 - 19:00にお知らせします

module.exports = (robot) ->

  robot.respond /(alarm|timer) ([\d:]+) ?(.+)?/i, (msg) ->

    text = "@#{msg.message.user.name} " + (msg.match[3] ? '時間なりましたで〜')

    if msg.match[2].match /^\d+$/
      timer = msg.match[2] * 1000 * 60
      msg.send "#{msg.match[2]}分後にお知らせします〜"

    else
      # 時間計算
      time = msg.match[2].match /^(\d+):(\d+)$/
      if ! time
        return
      now = new Date()
      alarm = new Date(now.getFullYear(), now.getMonth(), now.getDate(), time[1], time[2])
      if now > alarm
        msg.send "今より先の時間をいれてください"
        return

      timer = alarm - now
      msg.send "#{msg.match[2]} にお知らせします〜 (約#{Math.round(timer/1000/60)}分後)"

    setTimeout ->
      msg.send text
    , timer
