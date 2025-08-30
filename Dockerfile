FROM alpine:latest

RUN apk add --no-cache bash inotify-tools coreutils tzdata

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]