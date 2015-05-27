CONFIG={
    :dsn => "DBI:SQLite3:#{File.join(File.dirname(__FILE__),"..",'party.sqlite')}",
    :ytdlcmd => "youtube-dl",
    :ytdldestdir => "/home/fete/www/party/public/videos/",
    :extraytdlargs => "--no-cache-dir",
}
