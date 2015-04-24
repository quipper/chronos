require 'digest/sha1'
require 'redis'
require 'json'
require 'mongo'

require_relative 'chronos/timeline'
require_relative 'chronos/user'
require_relative 'chronos/utility'

module Chronos
  Mongo::Logger.logger.level = Logger::WARN

  $redis = Redis.new
  $mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'chronos_test')
end
