#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"taglib")
module Video
    require "uri" 
    require "config.rb"
    require "taglib"
    require "db.rb"

    def Video.reindex()
        Dir.glob(FIle.join(CONFIG[:ytdldestdir],"*.mp4")).each do |f|
            infos={}
            infos[:file]=f
            if f=~/-([a-zA-Z0-9_-]{11})\.mp4/
                infos[:yid] = $1
            end
            TagLib::MP4::File.open(f) do |mp4|
                break unless mp4.tag
                infos[:title]=mp4.tag.title 
                infos[:description] = mp4.item_list_map["\xC2\xA9cmt"]
            end
            add_video(infos)
        end
    end


    def Video.download_url(url)
        uri=URI.parse(url)
        extra_args=""
        if CONFIG[:ytdluser]
            extra_args << " -u #{CONFIG[:ytdluser]} "
        end
        if CONFIG[:ytdluser]
            extra_args << " -u #{CONFIG[:ytdlpass]} "
        end

        cmd = "#{CONFIG[:ytdlcmd]} #{CONFIG[:extraytdlargs]} --no-mtime  -t --add-metadata --recode-video mp4 --audio-quality 0  \"#{URI.decode(url)}\""
        prev=Dir.pwd()
        Dir.chdir(CONFIG[:ytdldestdir])
        res={}
        res[:message]=`#{cmd}`.gsub(/\n/,"<br/>")
        res[:status] = $?
        Dir.chdir(prev)
        return res
    end
end
