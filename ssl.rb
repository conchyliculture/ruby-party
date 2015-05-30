$: << File.join(File.dirname(__FILE__),'lib')

require 'webrick/https'

require "config.rb"

# Thx to http://stackoverflow.com/a/8952137
module Sinatra
  class Application
    def self.run!
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
