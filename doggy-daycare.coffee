# Description:
#   Keeps track of daycare dropoff and pickup
#
# Commands:
#   dogbot daycare - Check if Ollie is at daycare
#   dogbot dropoff - Set dropoff time for daycare
#   dogbot pickup - Set pickup time for daycare
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
    day = formatDay(date.getDay())
    hour = forceTwoDigits(date.getHours())
    minute = forceTwoDigits(date.getMinutes())
    "#{day} at #{hour}:#{minute}"

module.exports = (robot) ->
  # format = new Format

  robot.respond /daycare/i, (res) ->
    atDaycare = robot.brain.get('daycare.atDaycare')
    time = robot.brain.get('daycare.time')
    user = robot.brain.get('daycare.user')
    if atDaycare?
      if atDaycare
        res.send "Ollie is at daycare. Dropped off by #{user}, #{time}"
      else
        res.send "Ollie is not at daycare. Picked up by #{user}, #{time}"
    else
      res.send "I don't know when Ollie was last at daycare."
      res.send "Please set pickup or dropoff first."

  robot.respond /dropoff/i, (res) ->
    name = res.message.user.name
    time = new Date
    robot.brain.set("daycare.atDaycare", true)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been dropped off at daycare by #{name} at #{time}."

  robot.respond /pickup/i, (res) ->
    name = res.message.user.name
    time = new Date
    robot.brain.set("daycare.atDaycare", false)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been picked up from daycare by #{name} at #{time}."
