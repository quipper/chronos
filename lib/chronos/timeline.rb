module Chronos
  class Timeline

    @student_group_key = -> (id) { "student_group:#{id}:activities" }
    @student_key       = -> (id) { "student:#{id}:activities"       }

    class << self
      def log(data)
        student_group_key = @student_group_key.call(data[:student_group_id])
        student_key = @student_key.call(data[:user_id])

        $redis.zadd student_group_key, data[:created_ts], member(data)
        $redis.zadd student_key, data[:created_ts], member(data)
        $redis.hset "activities", member(data), data.to_json
      end


      def fetch(ids, key)
        keys = Utility.make_keys_from_ids(ids, key)
        data = fetch_activities( keys )

        Utility.sort_by_array_item(data, 1)
      end


      def fetch_for_student_groups(ids)
        data = fetch(ids, @student_group_key)
        data = get_activities(data)
        group_consecutive data
      end

      def fetch_for_students(ids)
        data = fetch(ids, @student_key)
        get_activities(data)
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


      private

      def fetch_activities(keys)
        keys.inject([]) do |memo, key|
          memo += $redis.zrevrange key, 0, -1, with_scores: true
        end
      end

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

