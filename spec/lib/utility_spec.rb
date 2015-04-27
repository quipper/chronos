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

  describe '.group_consecutive' do
    let(:input) do
      [
        {name: 'bob', id: 1  },
        {name: 'bob', id: 2 },
        {name: 'jane', id: 3},
        {name: 'bob', id: 4}
      ]
    end

    it 'returns array with consecutives grouped' do
      opts = { add_consecutive_to: :related, comparison_key: :name }
      result = subject.group_consecutive(input, opts)

      expect(result).to eq([
        {name: 'bob', id: 1, related: [{name: 'bob', id: 2, related: [] }]},
        {name: 'jane', id: 3, related: [] },
        {name: 'bob', id: 4, related: []}
      ])
    end
  end

end
