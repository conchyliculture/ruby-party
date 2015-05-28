#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"taglib")
module Video
    require "uri" 
    require "base64"
    require "open-uri"
    require "config.rb"
    require "taglib"
    require "db.rb"

    def Video.has_cover?(file)
        TagLib::MP4::File.open(File.join(CONFIG[:ytdldestdir],file)) do |mp4|
            break unless mp4.tag
            c = mp4.tag.item_list_map['covr']
            if c
                cover_art_list=c.to_cover_art_list
                cover_art = cover_art_list.first
                if cover_art.format
                    return true
                end
                cover_art.format == TagLib::MP4::CoverArt::JPEG
                res = Base64.encode64(cover_art.data)
            end
        end
        return false
    end

    def Video.cover_to_b64(file)
        res=nil
        TagLib::MP4::File.open(File.join(CONFIG[:ytdldestdir],file)) do |mp4|
            break unless mp4.tag
            c = mp4.tag.item_list_map['covr']
            if c
                cover_art_list=c.to_cover_art_list
                cover_art = cover_art_list.first
                cover_art.format
                cover_art.format == TagLib::MP4::CoverArt::JPEG
                res = Base64.encode64(cover_art.data)
            end
        end
        unless res
            res=Base64.encode64(File.open(File.join(File.dirname(__FILE__),"..","public","pic","no-thumb.jpg")).read())
        end
        return res
    end

    def Video.add(dbh,f)
        $stderr.puts "adding #{f}"
        infos={}
        infos[:file]=File.basename(f)
        if f=~/-([a-zA-Z0-9_-]{11})\.mp4/
            infos[:yid] = $1
        end
        $stderr.puts "opening #{Dir.pwd}/#{f}"
        TagLib::MP4::File.open(f) do |mp4|
            $stderr.puts "title : #{mp4.tag.title}"
            break unless mp4.tag
            infos[:title]=mp4.tag.title 
            if (mp4.tag.item_list_map["\xC2\xA9cmt"])
                infos[:description] = mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0]
            end
        end
        dbh.add_video(infos)
    end

    def Video.reindex(dbh)
        dbh.truncate()
        count=0
        Dir.glob(File.join(CONFIG[:ytdldestdir],"*.mp4")).each do |f|
            count+=1
            Video.add(dbh,f)
        end
        return "Reindexed <#{count}> videos"
    end

    def Video.add_covers(f)
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

    def Video.download_url(dbh,url)
        uri=URI.parse(url)
        extra_args=""

        cmd = "#{CONFIG[:ytdlcmd]} #{CONFIG[:extraytdlargs]} --write-thumbnail --no-mtime --add-metadata --recode-video mp4 --audio-quality 0  \"#{URI.decode(url)}\" -o \"#{CONFIG[:ytdldestdir]}/%(title)s-%(id)s.%(ext)s\" 2>&1"
        prev=Dir.pwd()
        res={}
        res[:message]=`#{cmd}`.gsub(/\n/,"<br/>")
        res[:status] = $?
        jpg_file=Dir.glob(File.join(CONFIG[:ytdldestdir],"*.jpg"))[0]
        if jpg_file
            if File.exist?(jpg_file)
                res[:file] =jpg_file.sub(".jpg",".mp4")
                $stderr.puts "file : "+res[:file]
                Video.add_covers(jpg_file)
                Video.add(dbh,res[:file])
            end
        end
        return res

    end
end
