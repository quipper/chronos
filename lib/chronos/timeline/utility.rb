module Chronos
  class Timeline
    module Utility
      def activities
        $redis.hmget("activities", *activity_ids).inject([]) do |memo, item|
          memo << view(JSON.parse(item))
        end
      end


      def activity_ids
        @ids.inject([]) do |memo, id|
          memo += $redis.zrevrange key(id), 0, -1, with_scores: true
        end.
        sort { |x,y| y[1] <=> x[1] }.
        map { |item| item[0] }
      end

      def view(data)
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

      def group_consecutive(items)
        items.inject([]) do |memo, document|
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
    end
  end
end
