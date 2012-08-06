require 'sinatra'
require 'pp'
require 'json'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite://'+File.expand_path('../highscore.db',__FILE__))

class HighscoreList
  include DataMapper::Resource
  property :id, Serial  
  property :data,String
end

DataMapper.auto_upgrade!

def getConfig
  HighscoreList.first||HighscoreList.create(:data=>[].to_json)
end

get '/save' do
  config=getConfig
  list=JSON.parse(config.data)
  list<<{"value"=>params["score"].to_i,"name"=>params["name"]}
  list=list.sort {|a,b|
    a["value"]<=>b["value"]}.reverse[0..9]
  headers 'Content-Type'=>'application/json'
  json=list.to_json
  config.update!(:data=>json)
  json
end
get '/' do
  headers 'Content-Type'=>'application/json'
  getConfig.data.to_json
end
