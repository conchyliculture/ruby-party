CONFIG={
    :dsn => "DBI:SQLite3:#{File.join(File.dirname(__FILE__),"..",'party.sqlite')}",
    :ytdlcmd => "youtube-dl",
    :ytdldestdir => "./public/videos/",
    :extraytdlargs => "--no-cache-dir",
    :ssl_server_key => "./ssl/my_ca/keys/party.key",
    :ssl_server_certificate => "./ssl/my_ca/keys/party.crt",
    :ssl_CA_certificate => "./ssl/my_ca/keys/ca.crt",
    :ssl_verify_client => false,
    :https_host => "0.0.0.0",
    :https_port => 8443,
}
