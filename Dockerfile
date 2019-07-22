FROM alpine:3.10

LABEL maintainer="Kiritzai"

RUN apk add --no-cache \
		tzdata \
		build-base \
		boost-dev \
		boost-date_time \
		boost-system \
		boost-thread \
		coreutils \
		curl \
		curl-dev \
		eudev \
		eudev-dev \
		git \
		gcc \
		g++ \
		libcurl \
		libssl1.1 \
		libmicrohttpd \
		libressl-dev \
		libusb \
		libusb-dev \
		libusb-compat \
		libusb-compat-dev \
		lua5.2-dev \
		make \
		minizip-dev \
		mosquitto-dev \
		musl-dev \
		python3-dev \
		sqlite \
		sqlite-dev \
		tzdata \
		zlib \
		zlib-dev \
		linux-headers && \
	export TZ='Europe/Amsterdam' && \
	apk add cmake --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main && \
	# Build OpenZwave
	git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
	# git clone -b 1.4 --single-branch https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
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
	 	-DCMAKE_BUILD_TYPE=Release CMakeLists.txt \
		-DCMAKE_INSTALL_PREFIX=/opt/domoticz \
		-DOpenZWave=/usr/lib/libopenzwave.so \
		-DUSE_BUILTIN_LUA=OFF \
		-DUSE_BUILTIN_MINIZIP=OFF \
		-DUSE_BUILTIN_MQTT=OFF \
		-DUSE_BUILTIN_SQLITE=OFF \
		-DUSE_STATIC_OPENZWAVE=OFF \
		-DUSE_STATIC_LIBSTDCXX=OFF \
		-DUSE_STATIC_BOOST=OFF \
		-DUSE_OPENSSL_STATIC=OFF \
		-Wno-dev && \
	make && \
	make install && \
	rm -rf /src/domoticz/ && \
	# Cleanup
	apk del --purge \
		git \
		build-base \
		cmake \
		boost-dev \
		sqlite-dev \
		curl-dev \
		libressl-dev \
		libusb-dev \
		libusb-compat-dev \
		coreutils \
		zlib-dev \
		eudev-dev \
		linux-headers

VOLUME /config

EXPOSE 8080

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
CMD ["-www", "8080"]