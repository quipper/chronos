require "sinatra"
require "chronos"

DEFAULT_LIMIT = 40

get '/timeline/student_groups' do
  status 200
  student_group_ids = request["student_group_ids"]
  limit = request["limit"] || DEFAULT_LIMIT

  Chronos::Timeline::StudentGroups.fetch(student_group_ids, limit: limit)
end

get '/timeline/students' do
  status 200
  student_ids = request["student_ids"]
  limit = request["limit"] || DEFAULT_LIMIT

  Chronos::Timeline::Students.fetch(student_ids, limit: limit)
end

post '/timelines' do
  Chronos::Store.log params
end
