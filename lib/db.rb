# encoding: UTF-8
class PartyDB
    require "sequel"
    require "logger"

    if not Object.const_defined?(:DB)
        DB = Sequel.sqlite 'party.sqlite', :loggers => [Logger.new($stderr)]
    end
    Sequel::Model.plugin(:schema)

    class Infos < Sequel::Model(:infos)
        set_schema do
            primary_key :id
            String  :yid, :unique => true, :empty => false
            String  :title, :unique => false, :empty => true
            String  :file, :unique => false, :empty => true
            String  :description, :unique => false, :empty => true
            String  :comment, :unique => false
            String  :url, :unique => false
        end
        create_table unless table_exists?
    end

    def PartyDB.truncate()
        Infos.truncate()
    end

    def PartyDB.add_video(infos)
        Infos.insert("INSERT INTO infos  VALUES (null,?,?,?,?,?,?)",
                :yid =>infos[:yid],
                :title => infos[:title],
                :file => infos[:file],
                :description => infos[:description],
                :comment => infos[:comment],
                :url => infos[:url],
        )
    end

    def PartyDB.get_rand(count=10)
        res=[]
        Infos.order(Sequel.lit('RANDOM()')).limit(count).each{|rs|  res << rs.to_hash}
#        @dbh.select_all("SELECT id,yid,title,file,description,comment,url FROM infos ORDER BY RANDOM() LIMIT ?",count).each do |row|
#            res << {
#                :id => row[0],
#                :yid => row[1],
#                :title => row[2],
#                :file => row[3],
#                :description => row[4],
#                :comment => row[5],
#                :url => row[6],
#            }
#        end
        res
    end

    def PartyDB.get_from_id(id)
        Infos.where(:id => id).to_hash
#        row=@dbh.select_one("SELECT id,yid,title,file,description,comment,url FROM infos WHERE id = ?",id)
#        res = {
#            :id => row[0],
#            :yid => row[1],
#            :title => row[2],
#            :file => row[3],
#            :description => row[4],
#            :comment => row[5],
#            :url => row[6],
#        }
#        res
    end

    def PartyDB.search(q)
        res=[]
        Infos.where{(Sequel.like(:title,  q)) | (Sequel.like(:comment,  q))}.each {|rs| res << rs.to_hash}
#        @dbh.select_all("SELECT id,yid,title,file,description,comment,url FROM infos WHERE title LIKE ? or comment LIKE ?","%#{q}%","%#{q}%").each do |row|
#            res << {
#                :id => row[0],
#                :yid => row[1],
#                :title => row[2],
#                :file => row[3],
#                :description => row[4],
#                :comment => row[5],
#                :url => row[5],
#            }
#        end
#        res
    end

    def PartyDB.get_file_from_id(id)
        return "lol?" unless id=~/^\d+$/
#        res=@dbh.select_one("SELECT file FROM infos WHERE id = ?",id)
        Infos.select(:file).where(:id => id).first
        return res
    end

    def PartyDB.already_in_db?(url)
        #res=@dbh.select_one("SELECT id FROM infos WHERE url=?",url)
        return ! Infos.where(:url=>url).empty?
        #return res != nil
    end

    def PartyDB.set_comment(id,t)
        #@dbh.do("UPDATE infos SET comment=? WHERE id =?",t,id)
        Infos.where(:id => id).update(:comment => t)
    end


#    def PartyDB.import_from_ytfacts(dsn)
#        dbh = Sequel.connect("mysql://ytdluser:ytdlpass@10.0.3.10/youtube_dl")
#        dbh.fetch("SELECT yid, description, title,  file FROM infos WHERE bien = 1") do  |row|
#            tags=dbh.fetch("SELECT tag_name FROM tags WHERE yid  =? ",row[:yid])
#            @dbh["INSERT INTO infos (id,yid,title,description,comment) VALUES (NULL,?,?,description,NULL)",row[:yid],row[:title],row[:description]]
#        end
#
#    end

end
