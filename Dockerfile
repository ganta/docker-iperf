#
# Build the iperf
#
FROM debian:13-slim as builder

RUN apt-get update
RUN apt-get install -y curl build-essential

WORKDIR /iperf

ENV IPERF_VERSION 3.17.1
ENV IPERF_DOWNLOAD_URL https://github.com/esnet/iperf/releases/download/${IPERF_VERSION}/iperf-${IPERF_VERSION}.tar.gz
ENV IPERF_SHA256 84404ca8431b595e86c473d8f23d8bb102810001f15feaf610effd3b318788aa

RUN curl --location --output iperf.tar.gz "${IPERF_DOWNLOAD_URL}"
RUN echo "${IPERF_SHA256} iperf.tar.gz" > iperf.tar.gz.sha256
RUN sha256sum -c iperf.tar.gz.sha256
RUN tar xf iperf.tar.gz --strip-components 1
RUN ./configure --enable-static "LDFLAGS=--static" --disable-shared --without-openssl
RUN make

#
# Copy the executable binary to the distroless image
#
FROM gcr.io/distroless/base-debian12

COPY --from=builder /iperf/src/iperf3 /usr/bin/iperf

USER nonroot

ENTRYPOINT ["/usr/bin/iperf"]
EXPOSE 5201
CMD ["-s"]
