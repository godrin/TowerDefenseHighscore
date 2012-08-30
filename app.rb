require 'sinatra'
require 'pp'
require 'json'
require 'data_mapper'

DataMapper.setup(:default, (ENV["DATABASE_URL"]|| 'sqlite://'+File.expand_path('../highscore.db',__FILE__)))

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
  if params["score"]=~/^[1-9][0-9]*$/ and params["name"]=~/[a-zA-Z0-9_]*/
    list<<{"value"=>params["score"].to_i,"name"=>params["name"]}
    list=list.sort {|a,b|
      a["value"]<=>b["value"]}.reverse[0..9]
  end
  content_type :json
  json=list.to_json
  config.update(:data=>json)
  json
end
get '/' do
  content_type :json
  getConfig.data
end

