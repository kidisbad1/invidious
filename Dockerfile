FROM crystallang/crystal:latest

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libsqlite3-dev \
    libxml2-dev \
    libyaml-dev \
    libgmp-dev \
    git

COPY . .

RUN shards install
RUN crystal build src/invidious.cr -o invidious

EXPOSE 3000

CMD ["./invidious"]
