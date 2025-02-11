#!/bin/bash

# Create and set permissions for bundle directory
mkdir -p vendor/bundle
chmod -R 777 vendor/bundle

# Update bundler
gem update --system
gem install bundler -v 2.5.5

# Update dtext_rb in Gemfile.lock
if [ -f "Gemfile.lock" ]; then
  sed -i 's/dtext_rb (1.13.0)/dtext_rb (1.14.2)/g' Gemfile.lock
  # Remove the Gemfile.lock if sed fails
  if [ $? -ne 0 ]; then
    rm -f Gemfile.lock
  fi
fi

# Set bundle config
bundle config set --local path 'vendor/bundle'
bundle config set --local deployment 'false'
bundle config set --local without 'development test'

# Install Ruby dependencies with updated gems
bundle update dtext_rb
bundle install

# Install Node dependencies
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