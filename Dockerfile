#
# Build the iperf
#
FROM debian:12-slim as builder

RUN apt-get update
RUN apt-get install -y curl build-essential

WORKDIR /iperf

ENV IPERF_VERSION 3.15
ENV IPERF_DOWNLOAD_URL https://github.com/esnet/iperf/releases/download/${IPERF_VERSION}/iperf-${IPERF_VERSION}.tar.gz
ENV IPERF_SHA256 bdb77c11f72bce90214883159577fa24412013e62b2083cf5f54391d79b1d8ff

RUN curl --location --output iperf.tar.gz "${IPERF_DOWNLOAD_URL}"
RUN echo "${IPERF_SHA256} iperf.tar.gz" > iperf.tar.gz.sha256
RUN sha256sum -c iperf.tar.gz.sha256
RUN tar xf iperf.tar.gz --strip-components 1
RUN ./configure --enable-static "LDFLAGS=--static" --disable-shared --without-openssl
RUN make

#
# Copy the executable binary to the distroless image
#
FROM gcr.io/distroless/static

COPY --from=builder /iperf/src/iperf3 /usr/bin/iperf

USER nonroot

ENTRYPOINT ["/usr/bin/iperf"]
EXPOSE 5201
CMD ["-s"]
