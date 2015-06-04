# ruby-party

Simple single video archiver/searcher for noob VJs!

Creates a website from where you can quickly search for the videos you want to
watch.

## Features :

* SSL (with client cert authent if you wish)
* Metadata (comments, cover) stored in the MP4 video

## Requirements :

    gem install taglib-ruby 
    apt-get install ruby-sinatra ruby-slim ruby-sqlite3
    apt-get install ruby-dev g++ taglib-dev
    apt-get install youtube-dl ffmpeg


For SSL :

    apt-get install easy-rsa

And then run the script like so :
    
    ruby party.rb ssl

It will build a simple PKI for you. But you can also do it by hand: 

    mkdir ssl
    make-cadir my_ca
    cd my_ca
    vi vars
    source ./vars
    clean-all
    ./build-ca
    ./build-key-server party
    ./build-key-pkcs12 local-party


