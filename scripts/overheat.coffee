module.exports = (robot) ->
  return if not process.env.OVERHEAT_OPERATIONS_PER_MINUTE?

  admins = if process.env.ADMINS?
      process.env.ADMINS.split ','
    else
      []

  maxOperations = parseInt process.env.OVERHEAT_OPERATIONS_PER_MINUTE
  overheat = { operations: 0, firstMinuteOperationAt: Date.now() }

  robot.receiveMiddleware (context, next, done) ->
    user = context.response.message.user

    if (overheat.firstMinuteOperationAt + 60000) < Date.now()
      overheat.firstMinuteOperationAt = Date.now()
      overheat.operations = 0

    overheat.operations++
    if overheat.operations > maxOperations and user.id not in admins
      done()
    else
      next(done)
