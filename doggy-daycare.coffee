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

  formatDate: (date, tz_offset) ->
    localizedTime = this.localizeDate(date, tz_offset)
    day = this.formatDay(localizedTime.getDay())
    hour = this.forceTwoDigits(localizedTime.getHours())
    minute = this.forceTwoDigits(localizedTime.getMinutes())
    "#{day} at #{hour}:#{minute}"

  localizeDate: (date, tz_offset) ->
    date = new Date date
    new Date date.getTime() + (tz_offset * 1000)

module.exports = (robot) ->
  format = new Format

  robot.respond /daycare/i, (res) ->
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
    else
      tz_offset = 0
    atDaycare = robot.brain.get('daycare.atDaycare')
    time = robot.brain.get('daycare.time')
    user = robot.brain.get('daycare.user')
    days = robot.brain.get('daycare.pkgDays') ## Get current number of days
    if atDaycare?
      formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
      if atDaycare
        res.send "Ollie is at daycare. Dropped off by #{user} at \
#{formattedTime}"
      else
        res.send "Ollie is not at daycare. Picked up by #{user} at \
#{formattedTime}"
    else
      res.send "I don't know when Ollie was last at daycare."
      res.send "Please set pickup or dropoff first."
    res.send "Ollie has #{days} days left at daycare."

  robot.respond /(dropoff|drop off|dropped off)/i, (res) ->
    if res.message.user.profile?.display_name?
      name = res.message.user.profile.display_name
    else
      name = res.message.user.name
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
    else
      tz_offset = 0
    time = new Date
    formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
    robot.brain.set("daycare.atDaycare", true)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been dropped off at daycare by #{name} at \
#{formattedTime}."
    days = robot.brain.get("daycare.pkgDays")
    if days > 0
      daysLeft = days - 1
      res.send "Ollie will have #{daysLeft} days left after today."
    else
      res.send "Ollie has no days on his package. You'll need to pay today \
or buy a package!"


  robot.respond /(pickup|pick up|picked up)/i, (res) ->
    if res.message.user.profile?.display_name?
      name = res.message.user.profile.display_name
    else
      name = res.message.user.name
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
    else
      tz_offset = 0
    time = new Date
    formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
    robot.brain.set("daycare.atDaycare", false)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been picked up from daycare by #{name} at \
#{formattedTime}."
    days = robot.brain.get("daycare.pkgDays")
    if days > 0
      daysLeft = days - 1
      robot.brain.set("daycare.pkgDays", daysLeft)
      res.send "Ollie has #{daysLeft} days left at daycare."
    else
      res.send "Ollie has no days on his package at daycare."

  robot.respond /buy( (\d+))?/i, (res) ->
    if res.message.user.profile?.display_name?
      name = res.message.user.profile.display_name
    else
      name = res.message.user.name
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
    else
      tz_offset = 0
    time = new Date
    count = parseInt(res.match[2], 10)
    if not count
      res.send "You need to include the number of days bought!"
    else
      days = robot.brain.get('daycare.pkgDays') ## Get current number of days
      days = count + days
      formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
      robot.brain.set("daycare.pkgDays", days)
      robot.brain.set("daycare.pkgTime", time)
      robot.brain.set("daycare.user", name)
      res.send "Daycare package bought by #{name}. Ollie now has #{days} days \
left."

  robot.respond /days/i, (res) ->
    days = robot.brain.get('daycare.pkgDays') ## Get current number of days
    res.send "Ollie has #{days} days left at daycare."

  robot.respond /(fixdays|fix days)( (\d+))?/i, (res) ->
    days = parseInt(res.match[2], 10)

    if not days
      res.send "You need to include the number of days bought!"
    else
      robot.brain.set("daycare.pkgDays", days)
      res.send "Re-syncing daycare days. Ollie now has #{days} days left."
