$: << File.join(File.dirname(__FILE__),'lib')

require 'webrick/https'

require "config.rb"

def check_ssl_env(dir)
    unless Dir.exist?(dir)
        puts "Can't find #{dir}"
        `which make-cadir`
        unless $?.success?
            puts "You haven't installed easy-rsa. You're on your own to build your PKI"
            exit
        else
            `make-cadir "#{dir}"`
            File.new("make_pki.sh","w").write( <<EOF
. vars
./clean-all
echo "Making a CA (you may want to import `pwd`/ca.crt in your browser)"
./build-ca
echo "Making a server certificate"
./build-key-server party
echo "Making a client certificate (you may want to import ̀̀`pwd`/local-party.p12 in your browser)"
./build-key-pkcs12 local-party
EOF
            Dir.chdir(dir)
            `sh make_pki.sh`
        end
    end
end

# Thx to http://stackoverflow.com/a/8952137
module Sinatra
  class Application
    def self.run!
        check_ssl_env(CONFIG[:ssh_config_dir] || "ssl")
      certificate_content = File.open(CONFIG[:ssl_server_certificate]).read
      key_content = File.open(CONFIG[:ssl_server_key]).read

      server_options = {
        :Host => CONFIG[:https_host] || "127.0.0.1",
        :Port => CONFIG[:https_port] || 8443,
        :SSLEnable => true,
        :SSLCertificate => OpenSSL::X509::Certificate.new(certificate_content),
        :SSLPrivateKey => OpenSSL::PKey::RSA.new(key_content),
        :SSLVerifyClient => CONFIG[:ssl_verify_client] ? OpenSSL::SSL::VERIFY_PEER|OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT : OpenSSL::SSL::VERIFY_NONE,
        :SSLCACertificateFile => CONFIG[:ssl_CA_certificate], 
      }

      Rack::Handler::WEBrick.run self, server_options do |server|
        [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
        server.threaded = settings.threaded if server.respond_to? :threaded=
        set :running, true
      end
    end
  end
end
