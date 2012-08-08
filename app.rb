require 'sinatra'
require 'pp'
require 'json'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite::memory:')

class HighscoreList
  include DataMapper::Resource
  property :id,         Serial  
  property :data,String
end

DataMapper.finalize

DataMapper.auto_migrate!

def getConfig
  HighscoreList.first||HighscoreList.create(:data=>[].to_json)
end


get '/save' do
  pp params
  list=JSON.parse(getConfig.data)
  pp "READ:",list,getConfig
  list<<{"value"=>params["score"].to_i,"name"=>params["name"]}
  pp list
  list.sort! {|a,b|
    pp "A;",a,b
    a["value"]<=>b["value"]}[0...3]
  list.reverse!
  headers 'Content-Type'=>'application/json'
  c=getConfig
  c.data=list.to_json
  pp "DATA",c
  c.save!
  list.to_json
end
get '/' do
  headers 'Content-Type'=>'application/json'
  getConfig.data
  pp getConfig.data
end
