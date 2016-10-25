FROM java:8

ENV STARDOG_VER stardog-4.2
ENV STARDOG_URL http://stardog.s3-website-us-east-1.amazonaws.com/downloads/5a8a1472-fd1c-4426-a582-14bde2ec4ecc/stardog-4.2.zip
ENV STARDOG_HOME /stardog

WORKDIR /

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get update && apt-get update -yy && \
    mkdir -p $STARDOG_HOME && \
    apt-get install -yy wget unzip && \
    wget $STARDOG_URL && \
    unzip ${STARDOG_VER}.zip && \
    rm ${STARDOG_VER}.zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /${STARDOG_VER}

EXPOSE 5820

CMD if [ ! -f $STARDOG_HOME/stardog-license-key.bin ]; then wget -O $STARDOG_HOME/stardog-license-key.bin $STARDOG_LICENSE; fi && \
    trap 'killall java' TERM && \
    ./bin/stardog-admin server start && \
    sleep 1 && \
    (tail -f $STARDOG_HOME/stardog.log &) && \
    while (pidof java > /dev/null); do sleep 1; done
