require 'sinatra'
require 'pp'
require 'json'
require 'data_mapper'

DataMapper.setup(:default, (ENV["DATABASE_URL"]|| 'sqlite://'+File.expand_path('../highscore.db',__FILE__)))
DataMapper::Model.raise_on_save_failure=true
class HighscoreList
  include DataMapper::Resource
  property :id, Serial  
  property :data,Text
end

DataMapper.auto_upgrade!

def getConfig
  HighscoreList.first||HighscoreList.create(:data=>[].to_json)
end

get '/save' do
  hconfig=getConfig
  list=JSON.parse(hconfig.data)
  if params["score"]=~/^[1-9][0-9]*$/ and params["name"]=~/[a-zA-Z0-9_]*/
    list<<{"value"=>params["score"].to_i,"name"=>params["name"]}
    list=list.sort {|a,b|
      a["value"]<=>b["value"]}.reverse[0..9]
  end
  content_type :json
  json=list.to_json
#  hconfig.update(:data=>json)
  
#config.destroy
#  HighscoreList.create(:data=>json)
hconfig.data=json
hconfig.save
  json
end
get '/' do
  content_type :json
  getConfig.data
end

