module Chronos
  class Timeline
    class StudentGroups
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
        group_consecutive activities
      end

      private

      def key(id)
        student_group_key(id)
      end
    end
  end
end
