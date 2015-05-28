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
            v.merge({:cover => "data:image/jpeg;base64,"+cover})
        else
            v
        end
    }
end

set :bind, '0.0.0.0'

before  do
    @dbh = PartyDB.new(CONFIG) 
end

get '/' do
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
    res=Video.download_url(@dbh,url)
    time=0
    if res[:status]!=0
        status 500
    else
        status 200
    end
    res[:message]
end

get '/reindex' do
    Video.reindex(@dbh)
end

get '/pushpl' do
    f = @dbh.get_file_from_id(@params[:id])
    file=File.join(CONFIG[:ytdldestdir],f)
    if File.exist?(file)
        cmd="DISPLAY=:0 vlc --one-instance --playlist-enqueue \"#{file}\" 2>&1 > /dev/null"
        $stderr.puts cmd
        `#{cmd}`
    end
end
