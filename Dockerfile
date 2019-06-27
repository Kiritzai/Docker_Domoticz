FROM lsiobase/alpine:3.9

ARG BUILD_DATE
ARG VERSION

LABEL build_version="Kirtzai version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Kiritzai"

RUN apk add --no-cache --virtual=build-dependencies \
		argp-standalone \
		autoconf \
		automake \
		binutils \
		boost \
		boost-system \
		boost-thread \
		curl \
		eudev-libs \
		libressl \
		openssh \
		python3-dev \
		boost-dev \
		confuse-dev \
		curl-dev \
		doxygen \
		eudev-dev \
		g++ \
		gcc \
		git \
		gzip \
		jq \
		libcurl \
		libftdi1-dev \
		libressl-dev \
		libusb-compat-dev \
		libusb-dev \
		linux-headers \
		lua5.2-dev \
		make \
		mosquitto-dev \
		musl-dev \
		pkgconf \
		sqlite-dev \
		tar \
		zlib-dev && \
	apk add cmake --no-cache --virtual=build-dependencies-edge --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main && \
	# Build OpenZwave
	git clone https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
	ln -s /src/open-zwave /src/open-zwave-read-only && \
	cd /src/open-zwave && \
	make && \
 	make \
		instlibdir=usr/lib \
		pkgconfigdir="usr/lib/pkgconfig/" \
		PREFIX=/usr \
		sysconfdir=etc/openzwave \
	install && \
	cd / && \
	rm -rf /src/open-zwave && \
	# Build Domoticz
	git clone https://github.com/domoticz/domoticz.git /src/domoticz && \
	cd /src/domoticz && \
	cmake \
	 	-DBUILD_SHARED_LIBS=True \
	 	-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/opt/domoticz \
		-DOpenZWave=/usr/lib/libopenzwave.so \
		-DUSE_BUILTIN_LUA=OFF \
		-DUSE_BUILTIN_MQTT=OFF \
		-DUSE_BUILTIN_SQLITE=OFF \
		-DUSE_STATIC_BOOST=OFF \
		-DUSE_STATIC_LIBSTDCXX=OFF \
		-DUSE_STATIC_OPENZWAVE=OFF \
		-Wno-dev && \
	make && \
	make install && \
	rm -rf /src/domoticz/ && \
	# Cleanup
	apk del --purge \
		build-dependencies \
		build-dependencies-edge

VOLUME /config

EXPOSE 8080

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
CMD ["-www", "8080"]
