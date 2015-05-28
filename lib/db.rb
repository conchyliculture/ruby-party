# encoding: UTF-8
class PartyDB
    require "dbi"

    def initialize(config) # config is a hash
        @dbh = DBI.connect(config[:dsn])
#        @dbh.do("set option charset utf8;")
        @dbh.do("CREATE TABLE IF NOT EXISTS infos (
                    `id` INTEGER PRIMARY KEY ,
                    `yid` VARCHAR( 11 ),
                    `title` VARCHAR( 255 ) ,
                    `file`   varchar(255) ,
                    `description` varchar(255) ,
                    `comment` varchar(255)
                    )
        ")
    end

    def add_video(infos)
        @dbh.do("INSERT INTO infos  VALUES (null,?,?,?,?,?)",
                infos[:yid],
                infos[:title],
                infos[:file],
                infos[:description],
                infos[:comment],
        )
    end

    def truncate()
        @dbh.do("DELETE FROM infos")
    end

    def get_rand(count=10)
        res=[]
        @dbh.select_all("SELECT id,yid,title,file,description,comment FROM infos ORDER BY RANDOM() LIMIT ?",count).each do |row|
            res << {
                :id => row[0],
                :yid => row[1],
                :title => row[2],
                :file => row[3],
                :description => row[4],
                :comment => row[5],
            }
        end
        res
    end

    def search(q)
        res=[]
        @dbh.select_all("SELECT id,yid,title,file,description,comment FROM infos WHERE title LIKE ?","%#{q}%").each do |row|
            res << {
                :id => row[0],
                :yid => row[1],
                :title => row[2],
                :file => row[3],
                :description => row[4],
                :comment => row[5],
            }
        end
        res
    end

    def get_file_from_id(id)
        res=@dbh.select_one("SELECT file FROM infos WHERE id = ?",id)
        return res[0]
    end


#    def import_from_ytfacts(dsn)
#        dbh = Sequel.connect("mysql://ytdluser:ytdlpass@10.0.3.10/youtube_dl")
#        dbh.fetch("SELECT yid, description, title,  file FROM infos WHERE bien = 1") do  |row|
#            tags=dbh.fetch("SELECT tag_name FROM tags WHERE yid  =? ",row[:yid])
#            @dbh["INSERT INTO infos (id,yid,title,description,comment) VALUES (NULL,?,?,description,NULL)",row[:yid],row[:title],row[:description]]
#        end
#
#    end

end
