#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__),"lib")

require "pp"
require 'sinatra'
require "slim"
require "config.rb"
require "db.rb"
require "video.rb"


def search(query)
    @dbh.search(query).map{ |v|
        cover = Video.cover_to_b64(v[:file])
        if cover
            $stderr.puts v[:file]+" has cover"
            v.merge({:cover => "data:image/jpeg;base64,"+cover})
        else
            $stderr.puts v[:file]+" has no cover"
            v
        end
    }
end

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
        @results=search($1)
        slim :results
    end
end

get '/insert_http' do
    url=@params[:url]
    res=Video.download_url(url)
    if res[:status]!=0
        status 500
    else
        Video.reindex(@dbh)
        status 200
    end
    res[:message]
end

get '/reindex' do
    Video.reindex(@dbh)
end

