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
      robot.logger.info "tz_offset from Slack is: #{tz_offset}"
    else
      tz_offset = 0
    robot.logger.info "Set tz_offset is: #{tz_offset}"
    atDaycare = robot.brain.get('daycare.atDaycare')
    time = robot.brain.get('daycare.time')
    user = robot.brain.get('daycare.user')
    if atDaycare?
      formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
      robot.logger.info "System time: #{time}"
      robot.logger.info "Localized time: #{formattedTime}"
      if atDaycare
        res.send "Ollie is at daycare. Dropped off by #{user} at \
#{formattedTime}"
      else
        res.send "Ollie is not at daycare. Picked up by #{user} at \
#{formattedTime}"
    else
      res.send "I don't know when Ollie was last at daycare."
      res.send "Please set pickup or dropoff first."

  robot.respond /dropoff/i, (res) ->
    if res.message.user.profile?.display_name?
      name = res.message.user.profile.display_name
    else
      name = res.message.user.name
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
      robot.logger.info "tz_offset from Slack is: #{tz_offset}"
    else
      tz_offset = 0
    time = new Date
    robot.logger.info "Set tz_offset is: #{tz_offset}"
    formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
    robot.logger.info "System time: #{time}"
    robot.logger.info "Localized time: #{formattedTime}"
    robot.brain.set("daycare.atDaycare", true)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been dropped off at daycare by #{name} at \
#{formattedTime}."

  robot.respond /pickup/i, (res) ->
    if res.message.user.profile?.display_name?
      name = res.message.user.profile.display_name
    else
      name = res.message.user.name
    if res.message.user.tz_offset?
      tz_offset = res.message.user.tz_offset
      robot.logger.info "tz_offset from Slack is: #{tz_offset}"
    else
      tz_offset = 0
    time = new Date
    robot.logger.info "Set tz_offset is: #{tz_offset}"
    formattedTime = format.localizeDate(time, tz_offset).toLocaleString()
    robot.logger.info "System time: #{time}"
    robot.logger.info "Localized time: #{formattedTime}"
    robot.brain.set("daycare.atDaycare", false)
    robot.brain.set("daycare.time", time)
    robot.brain.set("daycare.user", name)
    res.send "Ollie has been picked up from daycare by #{name} at \
#{formattedTime}."
