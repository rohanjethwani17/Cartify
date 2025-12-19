FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev libyaml-dev nodejs npm git curl postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler:2.4.22

# Copy Gemfile first for caching
COPY Gemfile ./
COPY Gemfile.lock* ./
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Make scripts executable
RUN chmod +x bin/*

# Expose port
EXPOSE 3000

# Default command
CMD ["./bin/docker-entrypoint.sh"]
