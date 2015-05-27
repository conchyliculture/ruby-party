#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__),"lib")

require "pp"
require 'sinatra'
require "slim"
require "config.rb"
require "db.rb"
require "video.rb"

set :bind, '0.0.0.0'

before  do
    @dbh = PartyDB.new(CONFIG) 
end

get '/' do
    $stderr.puts CONFIG[:dsn]
    slim :main
end

get '/lookup' do
    query=@params[:query]
    if query =~/^([a-zA-Z0-9\-_]{1,20})$/
        ytresults = get_yts_by_search($1,@page)
    end
end

get '/insert_http' do
    url=@params[:url]
    res=Video.download_url(url)
    if res[:status]!=0
        status 500
    else
        status 200
    end
    res[:message]
end


