FROM alpine
ADD script.sh /bin/
RUN chmod +x /bin/script.sh
RUN apk add bash yq patch colordiff --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
ENTRYPOINT /bin/script.sh

