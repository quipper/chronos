require 'spec_helper'
require './lib/chronos'

describe "User" do
  let(:user) { $mongo[:users].find.first }

  before do
    $mongo[:users].find.delete_many
    $mongo[:users].insert_one({ name: 'babakun' })
  end

  it "queries the database" do
    expect(Chronos::User.find(user['_id'])).to eq(user)
  end
end

describe "Timeline" do

  def user_attributes(name)
    {
      username: name,
      first_name: "firstname_#{name}",
      last_name:  "lastname_#{name}",
      profile_image_url: "http://example.com/foo.png"
    }
  end

  def create_user(name)
    $mongo[:users].insert_one( user_attributes(name) )
    $mongo[:users].find(username: name ).first
  end

  before do
    $mongo[:users].find.delete_many
  end


  let!(:bob)    { create_user('bob') }
  let!(:jane)   { create_user('jane') }
  let!(:alfred) { create_user('alfred') }

  def user(user)
    {
      "first_name" => user["first_name"],
      "last_name" => user["last_name"],
      "profile_image_url" => "http://example.com/foo.png"
    }
  end

  def expected_item(time, user, opt = {})
    {
      key: "activity.topic.attempted",
      created_ts: time,
      owner_id: user['_id'].to_s,
      trackable: {
        type: "Topic",
        name: "Balls",
        course_id: "1234",
        bundle_id: "5678"
      },
      owner: {
        first_name: user['first_name'],
        last_name: user['last_name'],
        profile_image_url: "http://example.com/foo.png"
      }
    }.merge(opt)
  end

  def expected_item_with_related(time, user_id)
    expected_item(time, user_id).merge!(related: [])
  end

  def log(opts = {})

    if opts[:user_id]
      opts[:user_id] = opts[:user_id]["_id"].to_s
    end

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
      data = Chronos::Timeline.fetch_for_students([bob['_id'], jane['_id']])
      expect(data).to eql expected
    end
  end

end
