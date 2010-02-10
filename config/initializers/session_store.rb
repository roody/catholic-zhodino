# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_catholic-zhodino_session',
  :secret      => '7935bdee2046989b69ea941673e314c76179fc278f576988c9d887866cf72bc2de7f780b77e485d12ac83147d49aed68d8bf9e637b6e2ef506be549077cda3f4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
