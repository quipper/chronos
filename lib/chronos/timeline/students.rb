module Chronos
  class Timeline
    class Students
      include Keys
      include Utility

      def fetch
        activities[0...@limit]
      end

      private

      def key(id)
        student_key(id)
      end
    end
  end
end
