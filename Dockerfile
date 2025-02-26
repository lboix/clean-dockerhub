FROM --platform=linux/amd64 alpine:latest

RUN apk add --no-cache bash curl jq coreutils

COPY main.sh /
RUN chmod +x /main.sh

CMD ["/bin/bash", "/main.sh"]
