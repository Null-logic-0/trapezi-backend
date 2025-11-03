require "openssl"

# Set OpenSSL default certs for Homebrew on macOS
homebrew_cert = "/opt/homebrew/etc/openssl@3/cert.pem"
homebrew_cert_dir = "/opt/homebrew/etc/openssl@3/certs"

if File.exist?(homebrew_cert)
  OpenSSL::SSL::DEFAULT_CERT_FILE = homebrew_cert
  OpenSSL::SSL::DEFAULT_CERT_DIR = homebrew_cert_dir
end
