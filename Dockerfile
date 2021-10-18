FROM raspbian/stretch

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    python3 \
    python3-pip \
    apt-utils \
    apt-transport-https \
    alsa-utils \
    ffmpeg \
    unzip \
    curl jq vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /
COPY ./mic-streamer.py /

CMD python3 mic-streamer.py

