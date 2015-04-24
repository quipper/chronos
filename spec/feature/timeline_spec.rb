require 'spec_helper'
require 'byebug'

describe "User", :focus do
  let(:user) { $mongo[:users].find.first }

  before do
    $mongo[:users].find.delete_many
    $mongo[:users].insert_one({ name: 'babakun' })
  end

  it "queries the database", :focus do
    expect(Chronos::User.find(user['_id'])).to eq(user)
  end
end

describe "Timeline" do
  before do
    allow(Chronos::User).to receive(:find).with('bob_123'){ user('bob_123') }
    allow(Chronos::User).to receive(:find).with('jane_123'){ user('jane_123') }
  end

  let(:bob)    { 'bob_123'     }
  let(:jane)   { 'jane_123'    }
  let(:alfred) { "alimony_321" }

  def user(user_id)
    {
      "first_name" => "firstname_#{user_id}",
      "last_name" => "lastname_#{user_id}",
      "profile_image_url" => "http://example.com/foo.png"
    }
  end

  def expected_item(time, user_id, opt = {})
    {
      key: "activity.topic.attempted",
      created_ts: time,
      owner_id: user_id,
      trackable: {
        type: "Topic", 
        name: "Balls",
        course_id: "1234",
        bundle_id: "5678"
      },
      owner: {
        first_name: "firstname_#{user_id}",
        last_name: "lastname_#{user_id}",
        profile_image_url: "http://example.com/foo.png"
      }
    }.merge(opt)
  end

  def expected_item_with_related(time, user_id)
    expected_item(time, user_id).merge!(related: [])
  end

  def log(opts = {})
    memo = {
      key: "activity.topic.attempted",
      user_id: '1234',
      type: "Topic", 
      name: "Balls",
      course_id: "1234",
      bundle_id: "5678",
      trackable_id: '123',
      student_group_id: '123',
      created_ts: Time.now.to_i,
      data: {
        score: 50,
        attempt: 1
      }
    }.merge!(opts)

    Chronos::Timeline.log(memo)
  end

  before :each do
    Redis.new.flushdb
  end


  describe '.sort_by_score' do
    it 'sorts by score' do
      input = [["a", 4],["b", 3],["c", 1],["d", 32]]
      output = [["d", 32], ["a", 4], ["b", 3], ["c", 1]]

      expect(Chronos::Timeline.sort_by_score(input)).to eq(output)
    end
  end

  it "has activities" do
    log(created_ts: 4000, user_id: jane)
    log(created_ts: 3000, user_id: bob)

    expected = [
      expected_item(4000, jane, related: []),
      expected_item(3000, bob, related: [])
    ]


    expect(Chronos::Timeline.fetch_for_student_groups(['123'])).to eql(expected)
  end

  it "has nested activities" do
    log(created_ts: 1000, user_id: jane)
    log(created_ts: 2000, user_id: bob)
    log(created_ts: 3000, user_id: bob)
    log(created_ts: 4000, user_id: jane)

    expected = [
      expected_item(4000, jane, related: []),
      expected_item(3000, bob,
        related: [
          expected_item(2000, bob, related: [])
        ]
      ),
      expected_item(1000, jane, related: []),
    ]

    expect(Chronos::Timeline.fetch_for_student_groups(['123'])).to eql(expected)
  end

  describe "several student groups" do
    let(:expected) do
      [
        expected_item(4000, jane, related: []),
        expected_item(3000, bob,
          related: [
            expected_item(2000, bob, related: [])
          ]
        ),
        expected_item(1000, jane, related: [])
      ]
    end

    before do
      log(created_ts: 1000, user_id: jane, student_group_id: "a" )
      log(created_ts: 2000, user_id: bob,  student_group_id: "b" )
      log(created_ts: 3000, user_id: bob,  student_group_id: "a" )
      log(created_ts: 4000, user_id: jane, student_group_id: "a" )
      log(created_ts: 4000, user_id: alfred, student_group_id: "c" )
    end

    it "returns activities for multiple student groups" do
      data = Chronos::Timeline.fetch_for_student_groups(["a", "b"])
      expect(data).to eql expected
    end
  end

  describe "several students" do
    let(:expected) do
        [
          expected_item(4000, jane),
          expected_item(3000, bob),
          expected_item(2000, bob),
          expected_item(1000, jane)
        ]
    end

    before do
      log(created_ts: 1000, user_id: jane, student_group_id: "a" )
      log(created_ts: 2000, user_id: bob,  student_group_id: "b" )
      log(created_ts: 3000, user_id: bob,  student_group_id: "a" )
      log(created_ts: 4000, user_id: jane, student_group_id: "a" )
      log(created_ts: 4000, user_id: alfred, student_group_id: "c" )
    end

    it "returns activities for multiple student groups" do
      data = Chronos::Timeline.fetch_for_students([bob, jane])
      expect(data).to eql expected
    end
  end

end
