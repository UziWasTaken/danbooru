#!/bin/bash

# Create and set permissions for bundle directory
mkdir -p vendor/bundle
chmod -R 777 vendor/bundle

# Update bundler
gem update --system
gem install bundler -v 2.5.5

# Remove both Gemfile.lock and backup the original Gemfile
rm -f Gemfile.lock
cp Gemfile Gemfile.backup

# Update dtext_rb version in Gemfile
sed -i 's/gem "dtext_rb".*$/gem "dtext_rb", "~> 1.14.2"/' Gemfile
if [ $? -ne 0 ]; then
    # If sed fails, restore from backup and try different approach
    cp Gemfile.backup Gemfile
    # Remove the old dtext_rb line if it exists
    sed -i '/gem "dtext_rb"/d' Gemfile
    # Add the new version
    echo 'gem "dtext_rb", "~> 1.14.2"' >> Gemfile
fi

# Set bundle config
bundle config set --local path 'vendor/bundle'
bundle config set --local deployment 'false'
bundle config set --local without 'development test'

# Clean any existing gems
rm -rf vendor/bundle/*

# Install Ruby dependencies with clean slate
bundle install --clean

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

# Cleanup
rm -f Gemfile.backup 