ARG OPENSSL_VERSION='3.5.2'
ARG OPENSSL_SHA256='c53a47e5e441c930c3928cf7bf6fb00e5d129b630e0aa873b08258656e7345ec'

FROM crystallang/crystal:1.20.1-alpine AS builder

RUN apk add --no-cache \
    curl \
    perl \
    git \
    sqlite-static \
    yaml-static \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    zlib-dev \
    build-base

WORKDIR /invidious

# Copy project (IMPORTANT: no .git copy)
COPY . .

# Install shards
RUN shards install --production

# Build Invidious
RUN crystal build ./src/invidious.cr -o invidious --release --static

FROM alpine:3.23

RUN apk add --no-cache \
    sqlite \
    tzdata \
    rsvg-convert \
    tini

WORKDIR /invidious

# Create user
RUN addgroup -g 1000 -S invidious && \
    adduser -u 1000 -S invidious -G invidious

# Copy built binary + assets
COPY --from=builder /invidious/invidious .
COPY --from=builder /invidious/assets ./assets
COPY --from=builder /invidious/config ./config
COPY --from=builder /invidious/locales ./locales
COPY --from=builder /invidious/videojs-dependencies.yml ./

# Ensure config exists
RUN mv -n config/config.example.yml config/config.yml

# Fix DB host for Render (optional override safety)
RUN sed -i 's/localhost/invidious-db/g' config/config.yml || true

EXPOSE 3000

USER invidious

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./invidious"]
