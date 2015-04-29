module Chronos
  module Keys
    def student_group_key(id)
      "student_group:#{id}:activities"
    end

    def student_key(id)
      "student:#{id}:activities"
    end
  end
end
