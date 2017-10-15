# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->
  return unless process.env.FOLLOW_BOT_ENABLED?

  robot.on 'setup', ->
    followings = []
    request = require('request').defaults
      baseUrl: 'https://api.dubtrack.fm'
      followRedirect: false
      json: true
      gzip: true

    request "/user/#{robot.selfId}/follows", (error, response) ->
      if error?
        robot.logger.error error
        return

      followings = response.body.data.map (user) -> user.following

      followUsersRecursively = (idsCollection, callback, currentIndex) ->
        currentIndex = currentIndex || 0

        if idsCollection.length > 0 and currentIndex < idsCollection.length
          if process.env.HEROKU_ENV?
            url = "/user/#{idsCollection[currentIndex]}/following"
            robot.dubtrack._.reqHandler.send method: 'POST', url: url, (code) ->
              followings.push idsCollection[currentIndex] if code is 200
              followUsersRecursively idsCollection, callback, currentIndex + 1
          else
            followings.push idsCollection[currentIndex]
            followUsersRecursively idsCollection, callback, currentIndex + 1
        else
          callback()

      recursiveRoomUsers = (roomsIds, currentIndex, usersIds) ->
        currentIndex = currentIndex || 0
        usersIds = usersIds || []

        if roomsIds.length > 0 and currentIndex < roomsIds.length
          request "/room/#{roomsIds[currentIndex]}/users", (error, response) ->
            usersIds = usersIds.concat response.body.data.map (user) -> user._id unless error
            recursiveRoomUsers roomsIds, currentIndex + 1, usersIds
        else if currentIndex > (roomsIds.length - 1)
          totalToFollow = usersIds
            .filter (item, index) ->
              usersIds.indexOf(item) is index
            .filter (userId) ->
              followings.indexOf(userId) is -1

          followUsersRecursively totalToFollow, ->
            robot.logger.info "You followed #{totalToFollow.length} new users. You have now #{followings.length} followings."

      newFollowingsFromRooms = ->
        request '/room', (error, response) ->
          if error
            robot.logger.error error
          else
            recursiveRoomUsers response.body.data.map (room) -> room._id

      newFollowingsFromRooms()
      setInterval ->
        newFollowingsFromRooms()
      , 30 * 60 * 1000

      robot.on 'userJoin', (user) ->
        if followings.indexOf(user.id) is -1
          followUsersRecursively [user.id], ->
            robot.logger.info "The user #{user.name} have been followed. Now you have #{followings.length} followings."
