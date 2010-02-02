# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mc_and_dj_session',
  :secret      => 'ddf3fb3285e7067ac004f591c4f9593b5bf76fce0d84964c3fec763ae9bb4139999c07ab023d56b685e601107e45b0250c9c2e57def4541708e7f8f2a8b62f86'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
