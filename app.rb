require 'sinatra'
require 'erb'
require 'json'

default_json = '{"Daniel":100,"Rachel":100,"Aaron":100,"David":100}'

configure do
  require 'redis'
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/clear' do
  erb :clearconfirm
end

post '/clear' do
  REDIS.set(:acounts, default_json) if params[:password] == "yesclear"
  redirect '/'
end

get '/' do
  json = REDIS.get(:acounts) || default_json
  @accounts = JSON.parse(json)
  @names = @accounts.keys.sort
  erb :index
end

post '/add' do
  json = REDIS.get(:acounts) || default_json
  accounts = JSON.parse(json)
  account = params[:account]
  amount = params[:amount].to_i  
  balance = accounts[account].to_i  
  balance = balance + amount
  if( balance < 0 ) then 
    balance = 0
  end
  accounts[account] = balance
  new_json = JSON.generate accounts
  REDIS.set(:acounts, new_json)
  redirect '/'
end

post '/transfer' do
  json = REDIS.get(:acounts) || default_json
  accounts = JSON.parse(json)
  from_account = params[:from]
  to_account = params[:to]
  
  unless (from_account == to_account) then  
    amount = params[:amount].to_i
    from_balance = accounts[from_account].to_i
    to_balance = accounts[to_account].to_i
    
    amount = from_balance if from_balance < amount
    
    from_balance -= amount
    to_balance += amount
      
    accounts[from_account] = from_balance
    accounts[to_account] = to_balance
    
    new_json = JSON.generate accounts
    REDIS.set(:acounts, new_json)
  end
  
  redirect '/'
  
end

post '/subtract' do
end

get '/list' do
  json = REDIS.get("things_to_do") || "[]"
  @things_to_do = JSON.parse(json)
  erb :list
end