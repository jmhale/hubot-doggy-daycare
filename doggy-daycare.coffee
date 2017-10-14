module.exports = (robot) ->
  robot.hear /pupper/i, (res) ->
    res.send "Woof!"
