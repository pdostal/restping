moment = require 'moment'

module.exports = ->
  @logger = (msg) ->
    console.log moment().format('DD. MM. YYYY, hh:mm:ss') + ' ' + msg
    true
