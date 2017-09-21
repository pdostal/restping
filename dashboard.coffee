require('./inc/logger.js')();

md5 = require 'md5'
util = require 'util'
moment = require 'moment'
yamljs = require 'yamljs'
cronjob = require('cron').CronJob

REDIS_PORT = process.env.REDIS_PORT || 6379
REDIS_HOST = process.env.REDIS_HOST || 'localhost'

redis = require('redis').createClient(REDIS_PORT, REDIS_HOST);

redis.on 'connect', ->
  logger "Redis connected"

settings = yamljs.load 'settings.yml'

logger "Dashboard started"

settings.categories.forEach (category, i) ->
  category.targets.forEach (target, j) ->
    target.md5 = md5 target.name+target.proto+target.port+target.success

    redis.get target.md5, (err, reply) ->
      logger "#{target.name} got #{JSON.parse(reply).status} in #{JSON.parse(reply).duration}ms"

