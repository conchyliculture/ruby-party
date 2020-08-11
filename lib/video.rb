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
    require "fileutils"

    def Video.has_cover?(file)
        TagLib::MP4::File.open(File.join(CONFIG[:ytdldestdir],file)) do |mp4|
            break unless mp4.tag
            c = mp4.tag.item_map['covr']
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
            c = mp4.tag.item_map['covr']
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

    def Video.set_title(f,title)
        TagLib::MP4::File.open(f) do |mp4|
            mp4.tag.item_map.insert("\xC2\xA9nam", TagLib::MP4::Item.from_string_list([title]))
            mp4.save
        end
    end

    def Video.add(f)
        $stderr.puts "adding #{f}"
        infos={}
        infos[:file]=File.basename(f)
        if f=~/-([a-zA-Z0-9_-]{4,})\.mp4/
            infos[:yid] = $1
        end
        TagLib::MP4::File.open(f) do |mp4|
            break unless mp4.tag
            infos[:title]=mp4.tag.title 
            if (mp4.tag.item_map["\xC2\xA9cmt"])
                begin
                    lol = JSON.parse(mp4.tag.item_map["\xC2\xA9cmt"].to_string_list[0])
                    infos[:description] = lol["description"] 
                    infos[:comment] = lol["comment"] 
                    infos[:url] = lol["url"] 
                rescue JSON::ParserError => e
                    infos[:description] = mp4.tag.item_map["\xC2\xA9cmt"].to_string_list[0] 
                end
            end
        end
       PartyDB.add_video(infos)
    end

    def Video.reindex()
        PartyDB.truncate()
        count=0
        Dir.glob(File.join(CONFIG[:ytdldestdir],"*.mp4")).each do |f|
            count+=1
            Video.add(f)
        end
        return count.to_s
    end

    def Video.add_cover(fmp4,image_data)
        cover_art = TagLib::MP4::CoverArt.new(TagLib::MP4::CoverArt::JPEG, image_data)
        item = TagLib::MP4::Item.from_cover_art_list([cover_art])
        TagLib::MP4::File.open(fmp4) do |mp4|
            mp4.tag.item_map.insert('covr', item)
            mp4.save
        end
    end

    def Video.set_url(fmp4,url)
        TagLib::MP4::File.open(fmp4) do |mp4|
            cur_infos={}
            begin
                cmt_tag = mp4.tag.item_map["\xC2\xA9cmt"]
                if cmt_tag
                    cur_infos = JSON.parse(cmt_tag.to_string_list[0])
                end
            rescue JSON::ParserError => e
                cur_infos[:description]=mp4.tag.item_map["\xC2\xA9cmt"].to_string_list[0]
            end

            cur_infos["url"]=url
            mp4.tag.item_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(cur_infos)]))
            mp4.save
        end
    end

    def Video.set_comment(vid,cmt)
        fmp4 = File.join(CONFIG[:ytdldestdir],PartyDB.get_file_from_id(vid))
        TagLib::MP4::File.open(fmp4) do |mp4|
            cur_infos={}
            begin
                cur_infos = JSON.parse(mp4.tag.item_map["\xC2\xA9cmt"].to_string_list[0])
            rescue JSON::ParserError => e
                cur_infos[:description]=mp4.tag.item_map["\xC2\xA9cmt"].to_string_list[0]
            end
            cur_infos["comment"]=cmt
            mp4.tag.item_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(cur_infos)]))
            mp4.save
        end
        PartyDB.set_comment(vid,cmt)
    end

    def Video.add_cmt(fmp4,infos)
        TagLib::MP4::File.open(fmp4) do |mp4|
            mp4.tag.item_map.insert("\xC2\xA9cmt", TagLib::MP4::Item.from_string_list([JSON.dump(infos)]))
            mp4.save
        end
    end

    def Video.download_url(url)
        uri=URI.parse(url)
        extra_args=""
        res={}
        unless PartyDB.already_in_db?(url)
            FileUtils.mkdir_p(CONFIG[:tmpdir])
            cmd = "#{CONFIG[:ytdlcmd]} #{CONFIG[:extraytdlargs]} --write-thumbnail --no-mtime --add-metadata --recode-video mp4 --audio-quality 0  \"#{URI.decode(url)}\" -o \"#{CONFIG[:tmpdir]}/%(title)s-%(id)s.%(ext)s\" 2>&1"
            $stderr.puts cmd
            prev=Dir.pwd()
            res[:message]=`#{cmd}`.gsub(/\n/,"<br/>")
            res[:status] = $?.exitstatus
            mp4_file=Dir.glob(File.join(CONFIG[:tmpdir],"*.mp4"))[0]
            jpg_file=mp4_file.sub(/\.mp4\z/, ".jpg"  )
            unless File.exist?(jpg_file)
                cmd="ffmpeg -i \"#{mp4_file}\" -vframes 1 -f image2 \"#{jpg_file}\""
                $stderr.puts cmd
                res[:message]+=`#{cmd}`.gsub(/\n/,"<br/>")
                res[:status] += $?.exitstatus 
                jpg_file=Dir.glob(File.join(CONFIG[:tmpdir],"*.jpg"))[0]
            end
            if File.exist?(jpg_file)
                res[:file] =jpg_file.sub(".jpg",".mp4")
                Video.add_cover(mp4_file,File.read(jpg_file))
                File.delete(jpg_file)
                Video.set_url(res[:file],url)
                Video.add(res[:file])
                FileUtils.mv(mp4_file,CONFIG[:ytdldestdir]+"/")
                FileUtils.rm Dir.glob(File.join(CONFIG[:tmpdir],'*'))
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
