module.exports = (robot) ->

  unless process.env.HUBOT_HEROKU_KEEPALIVE_URL?
    robot.logger.error 'Missing HUBOT_HEROKU_KEEPALIVE_URL, please include it to avoid the application to sleep'
    return

  keepaliveInterval = if process.env.HUBOT_HEROKU_KEEPALIVE_INTERVAL?
      parseFloat process.env.HUBOT_HEROKU_KEEPALIVE_INTERVAL
    else
      5

  setInterval ->
    client = robot.http("#{process.env.HUBOT_HEROKU_KEEPALIVE_URL}/heroku/keepalive")
    client.post() (err, res, body) ->
      if err?
        robot.logger.info "keepalive pong: #{err}"
        robot.emit 'error', err
      else
        robot.logger.info "keepalive pong: #{res.statusCode} #{body}"
  , keepaliveInterval * 60 * 1000

  robot.router.post '/heroku/keepalive', (req, res) ->
    res.set 'Content-Type', 'text/plain'
    res.send 'OK'
