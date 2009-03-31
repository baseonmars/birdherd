# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_newbird_session',
  :secret      => '421be2749140a3026a1c26123bf99aa029accab84545366aa289adfd0be882e872b08fbf4ea57f8f0924f882d894ef8dbe5e8e8797a3f6cff427af4ae88da1b1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
