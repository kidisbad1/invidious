FROM crystallang/crystal:1.20.1-alpine AS builder

RUN apk add --no-cache \
  git \
  curl \
  sqlite-static \
  yaml-static \
  libxml2-dev \
  libxslt-dev \
  openssl-dev \
  build-base

WORKDIR /invidious

COPY . .

# 🔥 IMPORTANT: prevent git requirement crash
RUN rm -rf .git || true

# Install deps
RUN shards install --production

# Build (safe mode)
RUN crystal build ./src/invidious.cr -o invidious --release --static

FROM alpine:3.23

RUN apk add --no-cache \
  sqlite \
  tzdata \
  rsvg-convert \
  tini

WORKDIR /invidious

RUN addgroup -g 1000 -S invidious && \
    adduser -u 1000 -S invidious -G invidious

COPY --from=builder /invidious/invidious .
COPY --from=builder /invidious/assets ./assets
COPY --from=builder /invidious/config ./config
COPY --from=builder /invidious/locales ./locales

RUN mv -n config/config.example.yml config/config.yml

EXPOSE 3000

USER invidious

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./invidious"]
