module Chronos
  module Store
    extend Keys
    def self.log(data)
      student_group_key = student_group_key(data[:student_group_id])
      student_key = student_key(data[:user_id])

      $redis.zadd student_group_key, data[:created_ts], uuid(data)
      $redis.zadd student_key, data[:created_ts], uuid(data)

      ids = $redis.zrange student_key, 0, -101
      if ids.any?
        $redis.hdel "activities", *ids
      end

      $redis.zremrangebyrank student_key, 0, -101
      $redis.hset "activities", uuid(data), data.to_json
    end

    def self.uuid(data)
      Digest::SHA1.hexdigest "#{data[:user_id]}#{data[:key]}#{data[:created_ts]}"
    end
  end
end
