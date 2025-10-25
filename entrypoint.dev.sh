#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Install Ruby gems if not installed yet
if [ ! -f /usr/local/bundle/config ]; then
  echo "Installing Ruby gems..."
  bundle check || bundle install
fi


# Run pending migrations
if [ "$RAILS_ENV" = "development" ]; then
  echo "Running migrations..."
  bundle exec rails db:migrate 2>/dev/null || echo "No pending migrations."
fi

# Start the main process
exec "$@"
