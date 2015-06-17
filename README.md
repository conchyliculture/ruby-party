# ruby-party

Simple single video archiver/searcher for noob VJs!

Creates a website from where you can quickly search for the videos you want to
watch.

Currently only works with Youtube Videos.

## Video providers compatibility

[Any video website](https://rg3.github.io/youtube-dl/supportedsites.html) which is supported by ̀`youtube-dl` should work.

`ruby-party` has been tested against:

* youtube
* Xtube

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

    apt-get install encfs git

