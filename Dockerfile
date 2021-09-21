FROM golang:1 AS builder

ARG TAG_PATTERN='v1*'

RUN git clone https://github.com/natlibfi/drone src/github.com/drone/drone/cmd/drone-server \
  && cd src/github.com/drone/drone/cmd/drone-server \
  && git checkout fix-image-pull-secrets \
  && go install -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM debian:stable
CMD ["/opt/drone-server/bin/drone-server"]

RUN apt update -y && apt install -y ca-certificates && rm -rf /var/cache/apt/*
COPY --from=builder /go/bin/drone-server /opt/drone-server/bin/
RUN chown -R 1001:1001 /opt/drone-server/ \
 && chgrp -R 0 /opt/drone-server/ \
 && chown -R g=u /opt/drone-server/ \
 && chmod +x /opt/drone-server/
