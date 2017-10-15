module.exports = (robot) ->
  blacklist = if process.env.HUBOT_BLACKLIST?
      process.env.HUBOT_BLACKLIST.split ','
    else
      []

  robot.receiveMiddleware (context, next, done) ->
    if context.response.message.user.id in blacklist
      done()
    else
      next(done)
