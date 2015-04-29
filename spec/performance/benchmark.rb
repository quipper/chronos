require 'benchmark'
require './lib/chronos'
require 'mongo'

$mongo[:users].find.delete_many
$mongo[:users].insert_one({ name: 'babakun' })
$user = $mongo[:users].find.first

def log(opts = {})
  memo = {
    key: "activity.topic.attempted",
    user_id: $user['_id'].to_s,
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

  Chronos::Store.log(memo)
end

$redis.flushdb

10000.times do |i|
  log(created_ts: Time.now.to_i + i)
end

puts "START"

Benchmark.measure{
  puts 1000.times { Chronos::Timeline::StudentGroups.fetch(["123"], limit: 50) }
}
