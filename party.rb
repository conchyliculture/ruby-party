#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"lib")

require "pp"
require "cgi"
require 'sinatra'
require "slim"
require "config.rb"
require "db.rb"
require "video.rb"

case ARGV[0]
when "ssl"
    require "ssl.rb"
else
    set :bind, CONFIG[:http_host] || "127.0.0.1"
    set :port, CONFIG[:http_port] || 4567
end

def search(query)

    PartyDB.search(CGI.unescapeHTML(query)).map{ |vv|
        v=vv.to_hash
        puts vv[:yid]+"/"+vv[:title]
        cover = Video.cover_to_b64(v[:file])
        if cover
            v.merge({:cover => "data:image/jpeg;base64,"+cover})
        else
            v
        end
    }
end

def get10()
    PartyDB.get_rand(10).map{ |v|
        cover = Video.cover_to_b64(v[:file])
        if cover
            v.merge({:cover => "data:image/jpeg;base64,"+cover})
        else
            v
        end
    }
end

$vlc = `pgrep vlc` != ""

get '/' do
    slim :main
end

get '/lookup' do
    query=@params[:query]
    if query =~/^(.{1,20})$/
        @results=search($1)
        slim :results
    end
end

get '/insert_http' do
    url=@params[:url]
    res=Video.download_url(url)
    time=0
    if res[:status]!=0
        status 500
    else
        status 200
    end
    res[:message]
end

get '/reindex' do
    Video.reindex()
end

get '/pushpl' do
    f = PartyDB.get_file_from_id(@params[:id])
    file=File.join(CONFIG[:ytdldestdir],f)
    if File.exist?(file)
        cmd="DISPLAY=:0 vlc --one-instance --playlist-enqueue \"#{file}\" 2>&1 > /dev/null"
        `#{cmd}`
    end
end

get '/get10' do
    @results=get10()
    slim :results
end

get '/dialog' do 
    vid = @params['id']
    @res = PartyDB.get_from_id(vid)
    @res[:desription]= CGI.escapeHTML(@res[:description])
    slim :dialog
end

post '/changeinfo' do
    vid = @params[:id]
    text = @params[:data]
    Video.set_comment(vid,text)
    ""
end
