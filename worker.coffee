require('./inc/logger.js')();

md5 = require 'md5'
util = require 'util'
http = require 'http'
https = require 'https'
moment = require 'moment'
yamljs = require 'yamljs'
Influx = require('influx')
cronjob = require('cron').CronJob

REDIS_PORT = process.env.REDIS_PORT || 6379
REDIS_HOST = process.env.REDIS_HOST || 'localhost'
INFLUX_HOST = process.env.INFLUX_HOST || 'localhost'
INFLUX_DB = process.env.INFLUX_DB || 'restping'

influx = new Influx.InfluxDB host: INFLUX_HOST, database: INFLUX_DB
redis = require('redis').createClient(REDIS_PORT, REDIS_HOST);

influx.getDatabaseNames()
  .then (names) ->
    if !names.includes INFLUX_DB
      influx.createDatabase INFLUX_DB
      logger "Database #{INFLUX_DB} created"
  .then () ->
    logger "Influx connected"
  .catch (err) ->
    logger "Influx error"

redis.on 'connect', ->
  logger "Redis connected"

settings = yamljs.load 'settings.yml'

logger "Worker started"

new cronjob '0 * * * * *', ->
  settings.categories.forEach (category, i) ->
    category.targets.forEach (target, j) ->
      target.md5 = md5 target.name+target.proto+target.port+target.success

      if target.proto == 'http'
        start = Date.now()
        http.get
          hostname: target.host,
          port: target.port,
          path: target.path,
          agent: target.agent
          , (res) =>
            data = { status: res.statusCode, duration: Date.now() - start }
            influx.writePoints([{ measurement: "#{target.md5}_#{target.name}", fields: data }])
            data.timestamp = moment().unix()
            redis.set target.md5, JSON.stringify(data), (err, reply) ->
        .on 'error', (err) ->
          data = { error: err.code, duration: Date.now() - start }
          influx.writePoints([{ measurement: "#{target.md5}_#{target.name}", fields: data }])
          data.timestamp = moment().unix()
          redis.set target.md5, JSON.stringify(data), (err, reply) ->

      if target.proto == 'https'
        start = Date.now()
        https.get
          hostname: target.host,
          port: target.port,
          path: target.path,
          agent: target.agent
          , (res) =>
            data = { status: res.statusCode, duration: Date.now() - start }
            influx.writePoints([{ measurement: "#{target.md5}_#{target.name}", fields: data }])
            data.timestamp = moment().unix()
            redis.set target.md5, JSON.stringify(data), (err, reply) ->
        .on 'error', (err) ->
          data = { error: err.code, duration: Date.now() - start }
          influx.writePoints([{ measurement: "#{target.md5}_#{target.name}", fields: data }])
          data.timestamp = moment().unix()
          redis.set target.md5, JSON.stringify(data), (err, reply) ->
, null, true
