#!/usr/bin/ruby
# encoding: utf-8
module Video
    require "uri" 
    require "config.rb"

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
