IMAGE=gnuradio
uid=$(shell id -u)
dockerUsername=ubuntu
#	       -v /run/user/$(uid)/pulse:/run/user/$(uid)/pulse
# ok so we need the rtl_sdr in there
# we need the pulse audio stuff
# we are privileged so you're not safe in this docker
# we need to export USB stuff :(
# we need to export X11 stuff
basedocker=docker run -ti --rm \
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
	       $(IMAGE) 

build:	.built

.built:	Dockerfile
	docker build -t $(IMAGE) .
	touch .built

shell:	.built
	$(basedocker) /bin/bash
gqrx:	Dockerfile .built
	$(basedocker) /bin/bash /home/ubuntu/gqrx
