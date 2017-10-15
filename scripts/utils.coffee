module.exports = (robot) ->

  admins = if process.env.ADMINS?
      process.env.ADMINS.split ','
    else
      []

  robot.respond /echo (.+)/, (res) ->
    res.send res.match[1] if res.match? and res.message.user.id in admins

  robot.on 'roomPlaylistUpdate', ->
    robot.dubtrack.updub()
