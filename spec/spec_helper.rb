require_relative '../chronos_app'

ENV['MONGO_URL'] = "mongodb://127.0.0.1:27017,127.0.0.1:27017/chronos_test"

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end
