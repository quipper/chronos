require 'spec_helper'
require './lib/chronos/utility'

describe Chronos::Utility do
  subject { Chronos::Utility }

  describe '.make_keys_from_ids' do

    it "returns array of made keys" do
      key = ->(id){ "foo:#{id}" }
      ids = [1,2,3]

      expect( subject.make_keys_from_ids(ids, key) ).
        to eq(["foo:1", "foo:2", "foo:3"])
    end
  end

  describe '.sort_by_array_item' do

    it "returns array of arrays sorted" do
      input = [["a", 4],["b", 3],["c", 1],["d", 32]]
      sorted = [["d", 32], ["a", 4], ["b", 3], ["c", 1]]

      expect( subject.sort_by_array_item(input, 1) ).to eq( sorted )
    end
  end

end
