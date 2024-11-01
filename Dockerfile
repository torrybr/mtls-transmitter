ARG DOCKER_REPO=docker.io/library
FROM ${DOCKER_REPO}/golang:1.22.3-alpine as builder

ARG DOCK_PKG_DIR=/go/src/mtls-transmitter

WORKDIR ${DOCK_PKG_DIR}
COPY . ${DOCK_PKG_DIR}

RUN CGO_ENABLED=0 GOOS=linux go build -o mtls-transmitter ./cmd/transmitter

FROM ${DOCKER_REPO}/alpine:3.12 as certs

RUN apk add -U --no-cache ca-certificates \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup

FROM scratch

ARG DOCK_PKG_DIR=/go/src/mtls-transmitter

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder ${DOCK_PKG_DIR}/mtls-transmitter .

USER appuser

EXPOSE 8080

ENTRYPOINT ["/mtls-transmitter"]