FROM rust@sha256:7b65306dd21304f48c22be08d6a3e41001eef738b3bd3a5da51119c802321883 AS builder
WORKDIR /workspace
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install --target=x86_64-unknown-linux-musl tomlq

FROM alpine:latest AS jqbuilder
RUN wget -O /bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 && chmod +x /bin/jq

FROM busybox:musl

COPY --from=builder /usr/local/cargo/bin/tq /usr/local/bin/tq
COPY --from=jqbuilder /bin/jq /usr/local/bin/jq
