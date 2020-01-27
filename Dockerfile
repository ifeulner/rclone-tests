FROM golang:1.13 AS builder

ARG RCLONE_REL=v1.50.2

RUN git clone -b ${RCLONE_REL} --depth 1  https://github.com/rclone/rclone.git /go/src/github.com/rclone/rclone/
WORKDIR /go/src/github.com/rclone/rclone/

# RUN make quicktest
RUN \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  make rclone
RUN ./rclone version

# Begin final image
FROM gcr.io/distroless/base
# FROM alpine:latest

# RUN apk --no-cache add ca-certificates fuse

COPY --from=builder /go/bin/rclone /usr/local/bin/

ENTRYPOINT [ "rclone" ]

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
