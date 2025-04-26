FROM rust@sha256:7b65306dd21304f48c22be08d6a3e41001eef738b3bd3a5da51119c802321883 AS builder
WORKDIR /code
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /code/target/release/acmed /usr/local/bin/acmed
COPY --from=builder /code/target/release/tacd  /usr/local/bin/tacd
CMD ["/usr/local/bin/acmed", "-f", "--log-stderr"]
