ARG RUBY_VERSION=3.4.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Install dependencies sistem
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libvips-dev \
      nodejs \
      npm \
      postgresql-client \
      git \
      && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler dan set up gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install
RUN ./bin/rails secret

# === Runtime Stage ===
FROM ruby:3.2-slim

# Install runtime dependencies only
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      libpq-dev \
      libvips-dev \
      nodejs \
      postgresql-client \
      && rm -rf /var/lib/apt/lists/*

# Buat user non-root
RUN useradd --create-home --shell /bin/bash rails
USER rails
WORKDIR /home/rails/app

# Copy gems dari build stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy aplikasi
COPY --chown=rails:rails . .

# Expose port (default Rails)
EXPOSE 80

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
