# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.8
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

ENV PORT=80

FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# 🔥 GENERATE CREDENTIALS OTOMATIS TANPA NANO 🔥
RUN RAILS_MASTER_KEY=$(openssl rand -hex 16) && \
    echo $RAILS_MASTER_KEY > config/master.key && \
    chmod 600 config/master.key && \
    SECRET_KEY_BASE=$(openssl rand -hex 64) && \
    echo "production:" > config/credentials.yml.enc && \
    echo "  secret_key_base: $SECRET_KEY_BASE" >> config/credentials.yml.enc && \
    echo "  rails_master_key: $RAILS_MASTER_KEY" >> config/credentials.yml.enc && \
    # Encrypt credentials
    rails credentials:encrypt RAILS_MASTER_KEY=$RAILS_MASTER_KEY && \
    # Save key untuk digunakan nanti
    echo $RAILS_MASTER_KEY > /tmp/RAILS_MASTER_KEY

FROM base

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

# Copy gems and app
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

# 🔥 COPY MASTER KEY KE ENVIRONMENT 🔥
RUN echo "export RAILS_MASTER_KEY=$(cat /tmp/RAILS_MASTER_KEY)" >> /home/rails/.profile
ENV RAILS_MASTER_KEY=$(cat /tmp/RAILS_MASTER_KEY)

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
