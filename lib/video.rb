#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__))
$: << File.join(File.dirname(__FILE__),"taglib")
module Video
    require "uri" 
    require "base64"
    require "open-uri"
    require "taglib"
    require "db.rb"
    require "json"

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
        if f=~/-([a-zA-Z0-9_-]{4,})\.mp4/
            infos[:yid] = $1
        end
        TagLib::MP4::File.open(f) do |mp4|
            break unless mp4.tag
            infos[:title]=mp4.tag.title 
            if (mp4.tag.item_list_map["\xC2\xA9cmt"])
                begin
                    lol = JSON.parse(mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0])
                    infos[:description] = lol["description"] 
                    infos[:comment] = lol["comment"] 
                    infos[:url] = lol["url"] 
                rescue JSON::ParserError => e
                    infos[:description] = mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0] 
                end
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
        return count.to_s
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

    def Video.set_url(dbh,fmp4,url)
        TagLib::MP4::File.open(fmp4) do |mp4|
            cur_infos={}
            begin
                cur_infos = JSON.parse(mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0])
            rescue JSON::ParserError => e
                cur_infos[:description]=mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0]
            end

            cur_infos["url"]=url
            mp4.tag.item_list_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(cur_infos)]))
            mp4.save
        end
    end

    def Video.set_comment(dbh,vid,cmt)
        fmp4 = File.join(CONFIG[:ytdldestdir],dbh.get_file_from_id(vid))
        TagLib::MP4::File.open(fmp4) do |mp4|
            cur_infos={}
            begin
                cur_infos = JSON.parse(mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0])
            rescue JSON::ParserError => e
                cur_infos[:description]=mp4.tag.item_list_map["\xC2\xA9cmt"].to_string_list[0]
            end
            cur_infos["comment"]=cmt
            mp4.tag.item_list_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(cur_infos)]))
            mp4.save
        end
        dbh.set_comment(vid,cmt)
    end

    def Video.add_cmt(f,infos)
        TagLib::MP4::File.open(fmp4) do |mp4|
            mp4.tag.item_list_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(infos)]))
            mp4.save
        end
    end

    def Video.download_url(dbh,url)
        uri=URI.parse(url)
        extra_args=""
        res={}
        unless dbh.already_in_db?(url)
            cmd = "#{CONFIG[:ytdlcmd]} #{CONFIG[:extraytdlargs]} --write-thumbnail --no-mtime --add-metadata --recode-video mp4 --audio-quality 0  \"#{URI.decode(url)}\" -o \"#{CONFIG[:ytdldestdir]}/%(title)s-%(id)s.%(ext)s\" 2>&1"
            prev=Dir.pwd()
            res[:message]=`#{cmd}`.gsub(/\n/,"<br/>")
            res[:status] = $?.exitstatus
            mp4_file=Dir.glob(File.join(CONFIG[:ytdldestdir],"*.mp4"))[0]
            jpg_file=mp4_file.sub(/\.mp4\z/, ".jpg"  )
            $stderr.puts "#{mp4_file} #{jpg_file}"
            unless File.exist?(jpg_file)
                cmd="ffmpeg -i \"#{mp4_file}\" -vframes 1 -f image2 \"#{jpg_file}\""
                $stderr.puts cmd
                res[:message]+=`#{cmd}`.gsub(/\n/,"<br/>")
                res[:status] += $?.exitstatus 
                jpg_file=Dir.glob(File.join(CONFIG[:ytdldestdir],"*.jpg"))[0]
            end
            if File.exist?(jpg_file)
                res[:file] =jpg_file.sub(".jpg",".mp4")
                Video.add_covers(jpg_file)
                Video.set_url(dbh,res[:file],url)
                Video.add(dbh,res[:file])
            else
                $stderr.puts "Can't find #{jpg_file}"
            end
        else
            res[:message]="URL #{url} is already in database"
            res[:status]=-1
        end
        return res

    end
end
