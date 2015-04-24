module Chronos
  module Utility
   module_function

    def fetch_data_by_key(ids, key)
      ids.inject([]) do |memo, id|
        values = $redis.zrevrange key.call(id), 0, -1, with_scores: true
        memo += values
      end
    end

    def make_keys_from_ids(ids, key)
      ids.map do |id|
        key.call(id)
      end
    end

    def sort_by_array_item(data, index)
      data.sort {|x,y| y[index] <=> x[index]}
    end
  end
end
