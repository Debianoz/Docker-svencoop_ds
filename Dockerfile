FROM i386/debian:stretch-slim

RUN echo "deb http://ftp.de.debian.org/debian stretch main" >> /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install --no-install-recommends -y \
    wget curl ca-certificates libgcc1 libstdc++6 libssl1.1:i386 libstdc++6:i386 locales locales-all zlib1g:i386 libc6 libstdc++6 ca-certificates libgcc1 libstdc++6:i386 zlib1g:i386 curl file bzip2 gzip unzip libssl1.1:i386 libxrandr-dev:i386 libxi-dev:i386 libgl1-mesa-glx:i386 libxtst6:i386 libusb-1.0.0:i386 libxxf86vm1:i386 libglu1-mesa:i386 libopenal1:i386 libgtk2.0-0:i386 libsm6:i386 libdbus-glib-1-2:i386 libudev-dev:i386 libudev-dev libpulse0 libnm-glib4
RUN apt-get clean
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN ln -s /lib/i386-linux-gnu/libudev.so.1 /lib/i386-linux-gnu/libudev.so.0

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="$DATA_DIR/steamcmd"
ENV SERVER_DIR="$DATA_DIR/serverfiles"
ENV GAME_ID="276060"

RUN mkdir $DATA_DIR
RUN mkdir $STEAMCMD_DIR
RUN mkdir $SERVER_DIR
RUN ulimit -n 2048

RUN groupadd steam
RUN useradd -d $DATA_DIR -s /bin/bash -g steam steam
RUN chown -R steam:steam $DATA_DIR

USER steam

RUN wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
RUN tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
RUN rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz

RUN $STEAMCMD_DIR/steamcmd.sh +login anonymous +quit

RUN mkdir $DATA_DIR/.steam/.sdk32
ADD steamclient.so $DATA_DIR/.steam/.sdk32

WORKDIR $SERVER_DIR

ENV PORT 27015
ENV MAXPLAYERS 12
ENV MAP osprey

ENTRYPOINT ./svends_run -console -norestart +map $MAP +maxplayers $MAXPLAYERS -port $PORT
