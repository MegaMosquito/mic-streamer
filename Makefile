# A simple service that streams audio from a mic attached to the host

DOCKERHUB_ID:=ibmosquito
NAME:="mic-streamer"
VERSION:="1.0.0"
 
# You will need to setup two variables to properly configure this container.
# This guide assumes `alsa-utils` is installed on your host as it normally is
# on the standard Raspberry Pi OS image. If not, Google how to, and install it.
# The `alsa` tools include ``arecord, `aplay`, and `amixer`, all of which are
# are used on the host in the instructions below.
#
# 1). Audio Input Device (for `arecord`):
# Audio can be tricky on Linux, but fortunately the alsa tools make it easier.
# Use `arecord -l` to find all of the devices suitable for recording audio,
# then select the one you want to use. Example output:
#     $ arecord -l
#    **** List of CAPTURE Hardware Devices ****
#    card 1: Device [USB PnP Sound Device], device 0: USB Audio [USB Audio]
#       Subdevices: 1/1
#       Subdevice #0: subdevice #0
#     $ 
# I only have one device for input. It's on card #1, on the only subdevice, #0.
# Test your selected device (device "1,0" for me above) with a command like:
#   arecord --device=hw:1,0 --format S16_LE --rate 32000 -c1 -V mono -d 5 x.wav
# Then play it back with a command like:
#   aplay x.wav -v -V mono
# If the volume is low, adjust the microphone gain (on the host):
#   amixer sset 'Capture' '100%'
# That will configure `alsa` to capture at the absolute maximum input volume.
# (That setting is what I use). If you run the above command, then re-record.
# If playback sounds good, put the device reference in the variable below
# (e.g., I used "1,0" based on my input device shown above):
ARECORD_DEVICE="1,0"
#
# 2). Streaming Target URL
# This container can only stream audio to an active listener somewhere. You
# must provide its URL in the variable below. If you wish, you can use the
# partner container to be your listener:
#    https://github.com/MegaMosquito/audio-stream-receiver.git
# The listener must be running before you can stream to it or streaming
# will fail. This container will try forever to stream to this target.
RECEIVER_URL="tcp://192.168.123.23:4567"


default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(NAME):$(VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
          --name ${NAME} \
          --device /dev/snd \
          --net=host \
          -e ARECORD_DEVICE=$(ARECORD_DEVICE) \
          -e RECEIVER_URL=$(RECEIVER_URL) \
          $(DOCKERHUB_ID)/$(NAME):$(VERSION) /bin/bash

run: stop
	docker run -d \
          --name ${NAME} \
          --restart unless-stopped \
          --device /dev/snd \
          --net=host \
          -e ARECORD_DEVICE=$(ARECORD_DEVICE) \
          -e RECEIVER_URL=$(RECEIVER_URL) \
          $(DOCKERHUB_ID)/$(NAME):$(VERSION)

# This test target must be run on the host in the RECEIVER_URL. E.g., when
# RECEIVER_URL="tcp://192.168.123.23:4567", then run it on 192.168.123.23.
# Note, this test requires `ffmpeg` (standard on Raspberry Pi OS images).
# If you don't have it, then Google how to install it on your machine.
test:
	ffplay -i "${RECEIVER_URL}"?listen -hide_banner

push:
	docker push $(DOCKERHUB_ID)/$(NAME):$(VERSION) 

stop:
	@docker rm -f ${NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(NAME):$(VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push test stop clean
