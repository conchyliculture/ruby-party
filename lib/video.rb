#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"taglib")
module Video
    require "uri" 
    require "base64"
    require "config.rb"
    require "taglib"
    require "db.rb"

    def Video.cover_to_b64(file)
        $stderr.puts File.join(CONFIG[:ytdldestdir],file)
        res=""
        TagLib::MP4::File.open(File.join(CONFIG[:ytdldestdir],file)) do |mp4|
            break unless mp4.tag
            c = mp4.tag.item_list_map['covr']
            if c
                cover_art_list=c.to_cover_art_list
                cover_art = cover_art_list.first
                cover_art.format
                cover_art.format == TagLib::MP4::CoverArt::JPEG
                res << Base64.encode64(cover_art.data)
            end
        end
        return res
    end

    def Video.reindex(dbh)
        dbh.truncate()
        count=0
        Dir.glob(File.join(CONFIG[:ytdldestdir],"*.mp4")).each do |f|
            infos={}
            infos[:file]=File.basename(f)
            if f=~/-([a-zA-Z0-9_-]{11})\.mp4/
                infos[:yid] = $1
            end
            TagLib::MP4::File.open(f) do |mp4|
                break unless mp4.tag
                infos[:title]=mp4.tag.title 
                infos[:description] = mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0]
            end
            count+=1
            dbh.add_video(infos)
        end
        return "Reindexed <#{count}> videos"
    end

    def Video.add_covers()
        Dir.glob(File.join(CONFIG[:ytdldestdir],"*.jpg")).each do |f|
            fmp4 = f.gsub(File.extname(f),".mp4")
            image_data = File.open(f, 'rb') { |f| f.read }
            cover_art = TagLib::MP4::CoverArt.new(TagLib::MP4::CoverArt::JPEG, image_data)
            item = TagLib::MP4::Item.from_cover_art_list([cover_art])
            TagLib::MP4::File.open(fmp4) do |mp4|
                mp4.tag.item_list_map.insert('covr', item)
                mp4.save
            end
            File.delete(f)
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

        cmd = "#{CONFIG[:ytdlcmd]} #{CONFIG[:extraytdlargs]} --write-thumbnail --no-mtime  -t --add-metadata --recode-video mp4 --audio-quality 0  \"#{URI.decode(url)}\""
        prev=Dir.pwd()
        Dir.chdir(CONFIG[:ytdldestdir])
        res={}
        res[:message]=`#{cmd}`.gsub(/\n/,"<br/>")
        res[:status] = $?
        Video.add_covers()
        Dir.chdir(prev)

        return res

    end
end
