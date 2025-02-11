#!/bin/bash

# Update bundler
gem update --system
gem install bundler -v 2.5.5

# Update Gemfile.lock for dtext_rb
sed -i 's/dtext_rb (1.13.0)/dtext_rb (1.14.0)/' Gemfile.lock

# Install Ruby dependencies
BUNDLE_WITHOUT="development test" bundle install

# Install Node dependencies
npm install

# Build the application
npm run build

# Create public directory if it doesn't exist
mkdir -p public

# Copy built files to public directory
cp -r dist/* public/

# Copy static assets
cp -r static/* public/ 2>/dev/null || :

# Ensure database migrations are in place
if [ -d "db/migrations" ]; then
  cp -r db/migrations public/
fi 