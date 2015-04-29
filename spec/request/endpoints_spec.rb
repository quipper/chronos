require 'spec_helper'
require 'sinatra'
require './chronos_app'
require 'rspec'
require 'rack/test'

describe 'The Chronos App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "timeline/student_groups" do
    before do
      allow(Chronos::Timeline::StudentGroups).to receive(:fetch)
    end

    it "works" do
      get '/timeline/student_groups', student_group_ids: ["1","2", "3"] 
      expect(last_response).to be_ok
    end

    it "gets activities for student groups" do
      expect(Chronos::Timeline::StudentGroups).to receive(:fetch).with(["1", "2", "3"], limit: 40)
      get '/timeline/student_groups', student_group_ids: ["1","2", "3"] 
    end
  end

  describe "timeline/student" do
    before do
      allow(Chronos::Timeline::Students).to receive(:fetch)
    end

    it "works" do
      get '/timeline/students', student_ids: ["1","2", "3"] 
      expect(last_response).to be_ok
    end

    it "gets activities for student groups" do
      expect(Chronos::Timeline::Students).to receive(:fetch).with(["1", "2", "3"], limit: 40)
      get '/timeline/students', student_ids: ["1","2", "3"] 
    end
  end

  describe "POST timelines" do
    before do
      allow(Chronos::Store).to receive(:log)
    end

    let(:params) do
      {"foo" => "bar"}
    end
    
    before do
      post '/timelines', params
    end

    it "gets activities for student groups" do
      expect(Chronos::Store).to have_received(:log).with(params)
    end
  end

end