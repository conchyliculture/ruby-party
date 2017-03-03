# encoding: UTF-8
class PartyDB
    require "sequel"
    require "logger"

    if not Object.const_defined?(:DB)
        DB = Sequel.sqlite 'party.sqlite', :loggers => [Logger.new($stderr)]
    end
    Sequel::Model.plugin :force_encoding, 'UTF-8'
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
        Infos.insert(
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
        res
    end

    def PartyDB.get_from_id(id)
        Infos.where(:id => id).first.to_hash
    end

    def PartyDB.search(qq)
        q="%#{qq}%"
        Infos.where{(Sequel.ilike(:title,  q)) | (Sequel.ilike(:comment,  q))}
    end

    def PartyDB.get_file_from_id(id)
        return "lol?" unless id=~/^\d+$/
        Infos.select(:file).where(:id => id).first[:file]
    end

    def PartyDB.already_in_db?(url)
        if Infos.grep(:url,"%#{url}%").empty?
            return !Infos.where(:yid=>url).empty?
        end
        return true
    end

    def PartyDB.set_comment(id,t)
        Infos.where(:id => id).update(:comment => t)
    end

end
