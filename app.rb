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
  REDIS.set(:acounts, default_json)
  redirect '/'
end

get '/' do
  json = REDIS.get(:acounts) || default_json
  @accounts = JSON.parse(json)
  @keys = @accounts.keys.sort
  erb :index
end

post '/add' do
  json = REDIS.get(:acounts) || default_json
  accounts = JSON.parse(json)
  account = params[:account]
  amount = params[:amount].to_i
  balance = accounts[account].to_i
  balance = balance + amount
  accounts[account] = balance
  new_json = JSON.generate accounts
  REDIS.set(:acounts, new_json)
  redirect '/'
end

post '/transfer' do
end

post '/subtract' do
end

get '/list' do
  json = REDIS.get("things_to_do") || "[]"
  @things_to_do = JSON.parse(json)
  erb :list
end