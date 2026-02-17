ARG BUILD_FROM

FROM alpine AS builder
COPY builder.sh builder.sh
RUN mkdir /files && \
    wget https://repo.e-hentai.org/hath/HentaiAtHome_1.6.4.zip -O hath.zip && \
    apk add unzip && unzip hath.zip HentaiAtHome.jar -d /files && \
    sh builder.sh

FROM ${BUILD_FROM}
COPY --from=builder /files /files
COPY /files /files
COPY rootfs/ /
ENV PATH="$PATH:/files:/files/jre/bin" \
    BUILD=176
RUN chmod +x /files/* && \
    find /etc -type f \( -name "*.sh" -o -name "run" -o -name "finish" \) -exec chmod +x {} + && \
    apk add --update curl jq miniupnpc && \
    sh -c "[[ $(cat etc/apk/arch) =~ '^(x86|armhf|armv7)$' ]] && apk add openjdk8-jre-base || return 0" && \
    rm -rf /var/cache/apk/*