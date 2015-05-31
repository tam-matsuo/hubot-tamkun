# Description:
#   heroku deploy hooks
#
# Commands:
#   None

module.exports = (robot) ->

  # http post
  # https://tamkun.herokuapp.com/hubot/heroku_hook
  #   array (
  #     'app' => 'test-app',
  #     'user' => 'test_user@heroku.com',
  #     'url' => 'http://test-app.herokuapp.com',
  #     'head' => '0b5fb19',
  #     'head_long' => '0b5fb19f982713183e27abb3a7231018169a150d',
  #     'git_log' => '*Sample commit message',
  #   )
  robot.router.post '/hubot/heroku_hook', (req, res) ->

    body = req.body
    if ! body.app || ! body.user
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'no message\n'
      return

    data =
      text: "<#{body.url}|#{body.user}> deployed version #{body.head} of <#{body.url}|#{body.app}>"
      username: 'Heroku'
      icon_url: 'https://slack.global.ssl.fastly.net/20653/img/services/heroku_48.png'
      channel: '#notify'

    robot
      .http("https://hooks.slack.com/services/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")
      .post(JSON.stringify data) (err, res, body) ->
        console.log body
