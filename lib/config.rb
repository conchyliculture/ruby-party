CONFIG={
    :dsn => "DBI:SQLite3:#{File.join(File.dirname(__FILE__),"..",'party.sqlite')}",
    :ytdlcmd => "youtube-dl",
    :ytdldestdir => "/home/fete/www/party/public/videos/",
    :extraytdlargs => "--no-cache-dir",
    :ssl_server_key => "/home/fete/www/party/ssl/my_ca/keys/party.key",
    :ssl_server_certificate => "/home/fete/www/party/ssl/my_ca/keys/party.crt",
    :ssl_CA_certificate => "/home/fete/www/party/ssl/my_ca/keys/ca.crt",
    :ssl_host => "0.0.0.0",
    :ssl_port => 8443,
}
