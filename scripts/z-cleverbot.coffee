
# Description:
#   "Makes your Hubot even more Clever™"
#
# Dependencies:
#   "cleverbot-node": "0.2.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot c <input>
#
# Author:
#   ajacksified
#   Stephen Price <steeef@gmail.com>

cleverbot = require('cleverbot-node')

module.exports = (robot) ->
  c = new cleverbot()

  robot.respond /(.*)/i, (msg) ->
    listenersToExec = robot.listeners.filter (listener) -> listener.regex.test msg.message.text

    unless listenersToExec.length > 1
      data = msg.match[1].trim()
      cleverbot.prepare(( -> c.write(data, (c) => msg.reply(c.message))))
