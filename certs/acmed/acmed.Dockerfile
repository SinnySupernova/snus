ARG TARGET=bookworm

FROM rust:1-$TARGET AS builder
WORKDIR /code
COPY . .
RUN cargo build --release

FROM debian:$TARGET-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl ca-certificates \
    curl dnsutils jq  # required to use cloudlflare scripts \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /code/target/release/acmed /usr/local/bin/acmed
COPY --from=builder /code/target/release/tacd  /usr/local/bin/tacd
CMD ["/usr/local/bin/acmed", "-f", "--log-stderr"]
