ARG DOCKER_REPO=docker.io/library
FROM ${DOCKER_REPO}/golang:1.23.2-alpine AS builder

ARG DOCK_PKG_DIR=/go/src/mtls-transmitter

WORKDIR ${DOCK_PKG_DIR}
COPY . ${DOCK_PKG_DIR}

# Build the application binary for Linux with CGO disabled
RUN CGO_ENABLED=0 GOOS=linux go build -o mtls-transmitter ./cmd/transmitter

FROM ${DOCKER_REPO}/alpine:3.20.3 AS certs

# Install CA certificates and create non-root user and group for application
RUN apk add -U --no-cache ca-certificates \
  && addgroup -S appgroup \
  && adduser -S appuser -G appgroup

# Final minimal stage using scratch
FROM scratch

ARG DOCK_PKG_DIR=/go/src/mtls-transmitter

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder ${DOCK_PKG_DIR}/mtls-transmitter .

# Re-create the user and group in scratch
COPY --from=certs /etc/passwd /etc/passwd
COPY --from=certs /etc/group /etc/group

# Switch to the non-root user for improved security
USER appuser

EXPOSE 8080

ENTRYPOINT ["/mtls-transmitter"]
