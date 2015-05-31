# Description:
#   tamkun
#
# Commands:
#   hubot random 100 - 1から100までのどれかの数字を選びます
#   hubot random A B C ... - A B C をランダムに並び替えます
#   hubot choice A B C ... - A B C のどれか1つを選びます

module.exports = (robot) ->
  #
  # ランダムを返す
  #
  robot.respond /(shuffle|random) (.+)/i, (msg) ->
    shuffle = (array) ->
      i = array.length
      while i
        j = Math.floor Math.random() * i
        t = array[--i]
        array[i] = array[j]
        array[j] = t
      array

    ary = msg.match[2].split ' '

    if ary.length > 1
      # 文字列をシャッフル
      shuffle ary

      msg.send ary.join ', '

    else if msg.match[2] > 1
      # 指定された数字の乱数を返す
      ary = [ 1..msg.match[2] ]
      msg.send msg.random ary

  robot.respond /(choice|select) (.+)/i, (msg) ->
    ary = msg.match[2].split ' '

    if ary.length > 1
      setTimeout ->
        msg.send (msg.random ary) + ' に決定〜！'
      , 2000
