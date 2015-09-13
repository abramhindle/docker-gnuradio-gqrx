IMAGE=gnuradio
uid=$(shell id -u)
dockerUsername=ubuntu

build:	.built

.built:	Dockerfile
	docker build -t $(IMAGE) .
	touch .built

shell:	.built
	docker run -ti --rm \
	       -e DISPLAY=$(DISPLAY) \
	       -v /tmp/.X11-unix:/tmp/.X11-unix \
	       $(IMAGE)
	       /bih/bash
gqrx:	Dockerfile .built
	docker run -ti --rm \
	       -v /dev/snd:/dev/snd \
	       --privileged=true \
	       --lxc-conf='lxc.cgroup.devices.allow = c 116:* rwm' \
	       -e DISPLAY=$(DISPLAY) \
	       -v /dev/shm:/dev/shm \
	       -v /dev/rtl_sdr:/dev/rtl_sdr \
	       -v /etc/machine-id:/etc/machine-id \
	       -v /run/user/$(uid)/pulse:/run/pulse:ro \
	       -v /var/lib/dbus:/var/lib/dbus \
	       -v ~/.pulse:/home/$(dockerUsername)/.pulse \
	       -v /tmp/.X11-unix:/tmp/.X11-unix \
	       -v /dev/bus/usb:/dev/bus/usb \
	       $(IMAGE) \
	       /bin/bash

#	       -v /run/user/$(uid)/pulse:/run/user/$(uid)/pulse \
