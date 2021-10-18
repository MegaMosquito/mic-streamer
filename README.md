# mic-streamer

Stream audio from a microphone on a Raspberry Pi over the network to any receiving host that has `ffmpeg` installed.

### Background info you will need

You will need to setup two variables to properly configure this container.

This guide assumes `alsa-utils` is installed *on your host* as it normally is
on the standard Raspberry Pi OS image. If not, Google how to, and install it.
The `alsa` tools include ``arecord, `aplay`, and `amixer`, all of which are
are used *on the host* in the instructions below.

### Determining the audio input device

Audio can be tricky on Linux, but fortunately the `alsa` tools make it easier.

Use `arecord -l` to find all of the locally installed devices suitable for recording audio, then select the one you want to use. Example output:

```
 $ arecord -l
**** List of CAPTURE Hardware Devices ****
card 1: Device [USB PnP Sound Device], device 0: USB Audio [USB Audio]
   Subdevices: 1/1
   Subdevice #0: subdevice #0
 $ 
```

Above I only have one device for input. It's on card #1, and its the only subdevice on that card, #0. The short name of this audio input device is therefore "1,0" (card, subdevice).

Test your selected device (device "1,0" for me above) with a command like:

```
 $ arecord --device=hw:1,0 --format S16_LE --rate 32000 -c1 -V mono -d 5 test.wav
```

Then play it back with a command like:

```
aplay test.wav -v -V mono
```

If the volume is low (or high), adjust the microphone gain (on the host), e.g.:

```
amixer sset 'Capture' '100%'
```

The example above will configure `alsa` to capture at the absolute maximum input volume (i.e., "100%"). This is the setting I am using with my very cheap microphone and USB audio dongle.

If you decide to run the above command, then re-record, and play again to make sure it is set the way you want it.

Once the playback sounds good, put your selected device reference in the variable `ARECORD_DEVICE` near the top of the `Makefile` (e.g., I used "1,0" based on my input device shown above):

### Configuring a network audio receiver

This container can only stream audio to an active listener somewhere. You
must therefore provide the URL of an active listener in the `RECEIVER_URL` variable near the top of the `Makefile`. If you wish, you can use this container's partner container to be your listener:

[https://github.com/MegaMosquito/audio-stream-receiver.git](https://github.com/MegaMosquito/audio-stream-receiver.git)

The listener should normally be running before you run `mic-streamer` or it will fail. But `mic-streamer` is nothign if not persistent. It will try forever to stream to the `RECEIVER_URL` you have specified, pausing briefly after each failure before trying again.

### Usage and basic testing

To start up this container, just run `make` in this directory.

To test it, you can start a network audio receiver on this same computer (assuming you configured the `RECEIVER_URL` using this host's IP address) by just running, `make test`. That will start the listener. Kill the listener with `Ctrl-C` when you wish to stop it. Note that it may take several seconds for the streaming audio to start.

Of course you will need to make some nose for your microphone to capture, and you will need to have an audio output device attached so you can hear the streamed output. If you need to set the output volume with the CLI, you can use:

```
amixer sset 'Master' '100%'
```

The above example sets the output volume to maximum ("100%").


