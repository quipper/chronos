module Chronos
  class User
    def self.find(id)
      id = BSON::ObjectId.from_string(id)
      $mongo[:users].find(_id: id).first
    end
  end
end
