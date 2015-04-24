require 'digest/sha1'
require 'redis'
require 'json'
require 'mongo'

Mongo::Logger.logger.level = Logger::WARN
$redis = Redis.new
$mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'chronos_test')

module Chronos
  class User
    def self.find(id)
      $mongo[:users].find(_id: id).first
    end
  end

  class Timeline

    @student_group_key = -> (id) { "student_group:#{id}:activities" }
    @student_key       = -> (id) { "student:#{id}:activities"       }

    class << self
      def log(data)

        student_group_key = "student_group:#{data[:student_group_id]}:activities"
        student_key = "student:#{data[:user_id]}:activities"

        $redis.zadd student_group_key, data[:created_ts], member(data)
        $redis.zadd student_key, data[:created_ts], member(data)
        $redis.hset "activities", member(data), data.to_json
      end


      def fetch_for_student_groups(ids)
        data = fetch_data_by_key ids, @student_group_key
        data = sort_by_score(data)
        data = get_activities(data)

        group_consecutive data
      end

      def fetch_for_students(ids)
        data = fetch_data_by_key ids, @student_key
        data = sort_by_score(data)

        get_activities(data)
      end

      def fetch_data_by_key(ids, key)
        ids.inject([]) do |memo, id|
          values = $redis.zrevrange key.call(id), 0, -1, with_scores: true
          memo += values
        end
      end

      def get_activities(data)
        data.map do |arr|
          activity_data_key = arr.first
          json = JSON.parse $redis.hget("activities", activity_data_key)
          data_for_activity json
        end
      end

      def group_consecutive(documents)
        documents.inject([]) do |memo, document|
          last = memo.last
          document[:related] = []

          if last && last[:owner_id] == document[:owner_id]
            memo.last[:related] << document
          else
            memo << document
          end
          memo
        end
      end

      def sort_by_score(data)
        data.sort {|x,y| y[1] <=> x[1]}
      end

      private
      def data_for_activity(data)
        user = Chronos::User.find(data['user_id'])

        {
          key: data["key"],
          created_ts: data["created_ts"],
          owner_id: data["user_id"],
          trackable: {
            type: data["type"],
            name: data["name"],
            course_id: data["course_id"],
            bundle_id: data["bundle_id"]
          },

          owner: {
            first_name: user['first_name'],
            last_name: user['last_name'],
            profile_image_url: user['profile_image_url']
          }
        }
      end

      def member(data)
        Digest::SHA1.hexdigest "#{data[:user_id]}#{data[:key]}#{data[:created_ts]}"
      end
    end

  end
end

require "sinatra"

get "/hi" do
  "Hello again"
end
