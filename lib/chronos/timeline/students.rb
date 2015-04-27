module Chronos
  class Timeline
    class Students
      include Keys
      include Utility

      class << self
        def fetch(ids)
          new(ids).fetch
        end
      end

      def initialize(ids)
        @ids = ids
      end

      def fetch
        activities
      end

      private

      def key(id)
        student_key(id)
      end
    end
  end
end
