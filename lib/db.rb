# encoding: UTF-8
class PartyDB
    require "sequel"

    def initialize(config) # config is a hash
        @dbh = Sequel.connect(config[:dsn])
        @dbh.create_table?(:infos) {
            primary_key :id
            String :yid, :size=>11
            String :title
            String :description
            String :comment
        }
    end

    def scan_and_import_from_dir(dir)
        Dir.glob("*/*").each do |f|
        end
    end

    def import_from_ytfacts(dsn)
        dbh = Sequel.connect("mysql://ytdluser:ytdlpass@10.0.3.10/youtube_dl")
        dbh.fetch("SELECT yid, description, title,  file FROM infos WHERE bien = 1") do  |row|
            tags=dbh.fetch("SELECT tag_name FROM tags WHERE yid  =? ",row[:yid])
            @dbh["INSERT INTO infos (id,yid,title,description,comment) VALUES (NULL,?,?,description,NULL)",row[:yid],row[:title],row[:description]]
        end

    end

end
