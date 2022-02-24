FROM golang:1 AS builder

ARG TAG_PATTERN='v2*'

RUN git clone https://github.com/drone/drone src/github.com/drone/drone/cmd/drone-server \
  && cd src/github.com/drone/drone/cmd/drone-server \
  && git checkout `git tag -l $TAG_PATTERN|grep -E '^v[0-9\.]+$'|sort -r|head -n1` \
  && go install -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM debian:stable
CMD ["/opt/drone-server/bin/drone-server"]

RUN apt update -y && apt install -y ca-certificates && rm -rf /var/cache/apt/*
COPY --from=builder /go/bin/drone-server /opt/drone-server/bin/
RUN chown -R 1001:1001 /opt/drone-server/ \
  && chgrp -R 0 /opt/drone-server/ \
  && chmod -R g=u /opt/drone-server/ \
  && chmod +x /opt/drone-server/
