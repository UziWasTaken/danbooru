#!/bin/bash

# Create and set permissions for bundle directory
mkdir -p vendor/bundle
chmod -R 777 vendor/bundle

# Update bundler
gem update --system
gem install bundler -v 2.5.5

# Set bundle config
bundle config set --local path 'vendor/bundle'
bundle config set --local deployment 'true'
bundle config set --local without 'development test'

# Install Ruby dependencies
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