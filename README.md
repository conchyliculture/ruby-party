# ruby-party

Simple single video archiver/searcher for noob VJs!

Creates a website from where you can quickly search for the videos you want to
watch.

Currently only works with Youtube Videos.

## Run it

    git clone https://github.com/conchyliculture/ruby-party
    cd ruby-party
    ruby party.rb

Then load `http://localhost:4567̀` with a Javascript enabled webrowser.

It's possible to re-generate the .sqlite file from the MP4 (for example, if you move videos by hand on the filesystem) with a GET on `/reindex`.

## Features 

* If VLC is running, you can directly add a video to the current playlist
* SSL (with client cert authent if you wish)
* Metadata (comments, cover) stored in the MP4 video
* DWTFYW public license (see COPYING)

## Requirements

### Commons

First install some stuff :

    apt-get install ruby-sinatra ruby-slim ruby-sqlite3
    apt-get install ruby-dev g++ libtag1-dev
    apt-get install youtube-dl ffmpeg

Then, either:

* install `ruby-taglib` system-wide:

    `gem install taglib-ruby`

* install `ruby-taglib` in the `lib` folder only :

    `gem install taglib-ruby -I /tmp/ `

    `mkdir lib/taglib`

    `mv /tmp/gems/taglib-ruby-0.*/lib/taglib* lib/taglib/`


### For SSL

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

### YouKeePass

This project can also be used as a local password manager.


    apt-get install encfs git
    wget https://raw.githubusercontent.com/conchyliculture/ruby-party/master/youkeepass.sh
    bash youkeepass.sh

Then go to `https://localhost:8443` and start adding videos. The video ID displayed are your passwords !
You can also add to the description of each video to easily store which passwords is used on which website.

