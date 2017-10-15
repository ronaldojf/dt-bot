module.exports = (robot) ->
  isDisabled = true
  admins = if process.env.ADMINS?
      process.env.ADMINS.split ','
    else
      []

  robot.receiveMiddleware (context, next, done) ->
    if isDisabled and context.response.message.user.id not in admins
      done()
    else
      next(done)

  robot.respond /enable/, (res) ->
    if isDisabled and res.message.user.id in admins
      isDisabled = false
      res.reply "OK, I'll try to listen to other people's problems."

  robot.respond /disable/, (res) ->
    if not isDisabled and res.message.user.id in admins
      isDisabled = true
      res.reply "OK, I'm only answering to you right now."
