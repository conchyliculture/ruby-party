#!/usr/bin/ruby
# encoding: utf-8
$: << File.join(File.dirname(__FILE__),"lib")
$: << File.join(File.dirname(__FILE__),"lib/taglib")

require "pp"
require "open-uri"
require "config.rb"
require "db.rb"
require "taglib"
require "json"

require "video.rb"

$YTURL="https://www.googleapis.com/youtube/v3/videos?key=AIzaSyDvSNn1y4nxzL-n0EUYTosDRqZAtZ40Oxk&part=snippet,contentDetails&id="


def get_json(f)
    yid=f[/(.{11})\.mp4/,1]
    begin
        url="https://www.googleapis.com/youtube/v3/videos?key=AIzaSyDvSNn1y4nxzL-n0EUYTosDRqZAtZ40Oxk&part=snippet,contentDetails&id=#{yid}"
        puts url
        res = JSON.parse(open(url).read())
    rescue OpenURI::HTTPError => e
        pp e
        puts url
        exit
    end
    if res["pageInfo"]["totalResults"] ==1
        title=res["items"][0]["snippet"]["title"]
        desc=res["items"][0]["snippet"]["description"]
        thumb_url=res["items"][0]["snippet"]["thumbnails"]["default"]["url"]
        return {"title"=>title,
                "desc" => desc,
                "yid" => yid,
                "thumb"=> thumb_url}
    else 
        puts "Title : "
        title = $stdin.gets().strip
        puts "Desc : "
        desc = $stdin.gets().strip()
        cmd="ffmpeg -y -i \"#{f}\" -vframes 1 -f image2 \"/tmp/lol.jpg\""
        pute=`#{cmd}`
        return {"title"=>title,
                "desc" => desc,
                "yid" => yid,
                "thumb"=> "/tmp/lol.jpg"}
    end
    return nil

end

def update_meta(f)
    puts f
    infos = get_json(f)
    Video.add_cmt(f,{"description"=> infos["desc"],
                    "url"=>"https://www.youtube.com/watch?v=#{infos['yid']}",
                    })
    Video.set_title(f,infos["title"])
    if infos.has_key?("thumb")
        begin
            Video.add_cover(f,open(infos["thumb"]).read())
        rescue OpenURI::HTTPError => e
            pp e
        end
    end
end

def get_meta(f)
    res={}
    TagLib::MP4::File.open(f) do |mp4|
        unless mp4.tag
            break
        else
            if mp4.tag.title
                res["title"] = mp4.tag.title
            end
            mp4.tag.item_list_map.to_a.each do |i|
                k = i[0]
                if ['covr',"\xC2\xA9cmt"].include?(k)
                    res[k] = i[1].to_string_list
                end
            end
        end
    end
    return res
end


Dir.glob(File.join(ARGV[0],"*.mp4")).each do |f|
    res=get_meta(f)
    if res.size<3
        update_meta(f)
    end
end
