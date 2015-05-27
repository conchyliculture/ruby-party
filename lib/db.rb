# encoding: UTF-8
class PartyDB
    require "dbi"

    def initialize(config) # config is a hash
        @dbh = DBI.connect(config[:dsn])
        @dbh.do("set option charset utf8;")
        @dbh.do("CREATE TABLE IF NOT EXISTS infos (
                    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
                    `yid` VARCHAR( 11 ),
                    `title` VARCHAR( 255 )  CHARACTER SET utf8 ,
                    `file`   varchar(255) CHARACTER SET utf8 ,
                    `description` varchar(255) CHARACTER SET utf8,
                    `comment` varchar(255) CHARACTER SET utf8,

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

#    def import_from_ytfacts(dsn)
#        dbh = Sequel.connect("mysql://ytdluser:ytdlpass@10.0.3.10/youtube_dl")
#        dbh.fetch("SELECT yid, description, title,  file FROM infos WHERE bien = 1") do  |row|
#            tags=dbh.fetch("SELECT tag_name FROM tags WHERE yid  =? ",row[:yid])
#            @dbh["INSERT INTO infos (id,yid,title,description,comment) VALUES (NULL,?,?,description,NULL)",row[:yid],row[:title],row[:description]]
#        end
#
#    end

end
