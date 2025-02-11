#!/bin/bash

# Create and set permissions for bundle directory
mkdir -p vendor/bundle
chmod -R 777 vendor/bundle

# Update bundler and install required gems directly
gem update --system
gem install bundler -v 2.5.5
gem install dtext_rb -v 1.14.2

# Clean existing files
rm -f Gemfile.lock
rm -rf vendor/bundle/*

# Create a fresh Gemfile
mv Gemfile Gemfile.original
cat > Gemfile << EOL
source 'https://rubygems.org'

gem 'dtext_rb', '1.14.2'
EOL

cat Gemfile.original >> Gemfile
rm Gemfile.original

# Set bundle config
bundle config set --local path 'vendor/bundle'
bundle config set --local deployment 'false'
bundle config set --local without 'development test'

# Install dependencies with clean slate
bundle install --clean --jobs 4 --retry 3

# Install Node dependencies
export NODE_OPTIONS="--max_old_space_size=4096"
npm install

# Build the application
npm run build

# Create public directory if it doesn't exist
mkdir -p public

# Copy built files to public directory
cp -r dist/* public/ 2>/dev/null || :

# Copy static assets
cp -r static/* public/ 2>/dev/null || :

# Ensure database migrations are in place
if [ -d "db/migrations" ]; then
  cp -r db/migrations public/
fi 