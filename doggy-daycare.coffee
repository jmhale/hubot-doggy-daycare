# Description:
#   Keeps track of daycare dropoff and pickup
#
# Commands:
#   hubot daycare - Check if Ollie is at daycare
#   hubot dropoff - Set dropoff time for daycare
#   hubot pickup - Set pickup time for daycare
#
# Author:
#   jmhale

class Format
  forceTwoDigits: (val) ->
    if val < 10
      return "0#{val}"
    return val

  formatDay: (day) ->
    todaysDate = new Date
    todaysDay = todaysDate.getDay()
    if day == todaysDay
      "Today"
    else
      "Not today"

  formatDate: (date) ->
    day = this.formatDay(date.getDay())
    hour = this.forceTwoDigits(date.getHours())
    minute = this.forceTwoDigits(date.getMinutes())
    "#{day} at #{hour}:#{minute}"

module.exports = (robot) ->
  format = new Format

  robot.respond /daycare/i, (res) ->
    atDaycare = robot.brain.get('daycare.atDaycare')
    time = robot.brain.get('daycare.time')
    user = robot.brain.get('daycare.user')
    if atDaycare?
      formattedTime = format.formatDate(time)
      if atDaycare
        res.send "Ollie is at daycare. Dropped off by #{user}, \
#{formattedTime}"
      else
        res.send "Ollie is not at daycare. Picked up by #{user}, \
#{formattedTime}"
    else
      res.send "I don't know when Ollie was last at daycare."
      res.send "Please set pickup or dropoff first."

  robot.respond /dropoff/i, (res) ->
    name = res.message.user.profile.display_name
    time = new Date
    formattedTime = format.formatDate(time)
    robot.brain.set("daycare.atDaycare", true)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been dropped off at daycare by #{name} at \
#{formattedTime}."

  robot.respond /pickup/i, (res) ->
    name = res.message.user.profile.display_name
    time = new Date
    formattedTime = format.formatDate(time)
    robot.brain.set("daycare.atDaycare", false)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been picked up from daycare by #{name} at \
#{formattedTime}."
