FROM golang:1.14-alpine3.12 AS build

# Webhook Compile with Go
# Source: panubo @ https://github.com/panubo/docker-webhook/blob/master/Dockerfile
ENV WEBHOOK_VERSION=2.8.0 WEBHOOK_CHECKSUM=c521558083f96bcefef16575a6f3f98ac79c0160fd0073be5e76d6645e068398
WORKDIR /go/src/github.com/adnanh/webhook
RUN apk add --no-cache --update -t build-deps curl go git gcc libc-dev libgcc \
  && curl -sSf -L https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz -o webhook.tgz \
  && printf "%s  %s\n" "${WEBHOOK_CHECKSUM}" "webhook.tgz" > CHECKSUM \
  && sha256sum webhook.tgz \
  && ( sha256sum -c CHECKSUM; ) \
  && tar --strip 1 -xzf webhook.tgz \
  && go get -d \
  && go build -o /usr/local/bin/webhook \
  && apk del --purge build-deps \
  && rm -rf /var/cache/apk/* \
  && rm -rf /go

FROM alpine:3.12
MAINTAINER Steffen Blake <steffen@technically.fun>

# WebHook Install
# Source: panubo @ https://github.com/panubo/docker-webhook/blob/master/Dockerfile
EXPOSE 9000
COPY --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN apk --no-cache --update add bash curl git wget jq ca-certificates py-pygments openssh \
  && addgroup -g 1000 webhook \
  && adduser -D -u 1000 -G webhook webhook \
  && rm -rf /var/cache/apk/*

# Hugo Install
# Source: jonathanbp @ https://github.com/jonathanbp/docker-alpine-hugo/blob/master/Dockerfile
ARG HUGO_VERSION
ARG HUGO_ARCH
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz

RUN mkdir /usr/local/hugo
ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} /usr/local/hugo/
RUN tar xzf /usr/local/hugo/${HUGO_BINARY} -C /usr/local/hugo/ \
	&& ln -s /usr/local/hugo/hugo /usr/local/bin/hugo \
	&& rm /usr/local/hugo/${HUGO_BINARY}

# Install hook.json
ADD ./build.json /hooks/build.json
run chown webhook:webhook -R /hooks

# Install startup.sh
ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh
run chown webhook:webhook -R /startup.sh

# Install deploy.sh
ADD ./deploy.sh /deploy.sh
RUN chmod +x /deploy.sh
run chown webhook:webhook -R /deploy.sh

# Install after-deploy.sh
ADD ./after-deploy.sh /after-deploy.sh
RUN chmod +x /after-deploy.sh
run chown webhook:webhook -R /after-deploy.sh

# Prep /www for mount
RUN mkdir /www
run chown webhook:webhook -R /www

# Prep /temp for working in
RUN mkdir /temp
run chown webhook:webhook -R /temp

# Prep ssh dir for working in
RUN mkdir /home/webhook/.ssh
run chown webhook:webhook -R /home/webhook/.ssh
run chmod -R 700 /home/webhook/.ssh
USER webhook
CMD ["/bin/sh", "/startup.sh"]