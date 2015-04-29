module Chronos
  class Timeline
    class StudentGroups
      include Keys
      include Utility

      def fetch
        fetched = group_consecutive(activities)
        fetched[0...@limit]
      end

      private

      def key(id)
        student_group_key(id)
      end
    end
  end
end
