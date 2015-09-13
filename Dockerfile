FROM ubuntu:14.04

# get a good mirror and install the stuff we care about

RUN echo deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse >> /etc/apt/sources.list && \
    echo deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse >> /etc/apt/sources.list && \
    echo deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse >> /etc/apt/sources.list && \
    echo deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y git lsb-release sudo python curl wget

# setup gnuradio in such a way that it can be sanely installed using my version

RUN cd / && git clone --recursive https://github.com/abramhindle/pybombs && cd pybombs/recipes && \
    git remote add ah https://github.com/abramhindle/recipes && git pull ah master

# fix the version of gnuradio we want

RUN cd /pybombs && wget -O config.dat http://softwareprocess.es/2015/gnuradio-config.dat && \
    echo gitrev: tags/v3.7.8>>recipes/gnuradio.lwr && \
    ./pybombs install gqrx

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/ubuntu && \
    echo "ubuntu:x:${uid}:${gid}:Ubuntu,,,:/home/ubuntu:/bin/bash" >> /etc/passwd && \
    echo "ubuntu:x:${uid}:" >> /etc/group && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    chown ${uid}:${gid} -R /home/ubuntu && \
    adduser ubuntu adm

RUN apt-get install -y tmux screen

# pulse audio
RUN echo enable-shm=no >> /etc/pulse/client.conf
ENV PULSE_SERVER /run/pulse/native

USER ubuntu
ENV HOME /home/ubuntu
RUN cd /home/ubuntu && \
    echo export QT_X11_NO_MITSHM=1>>.bashrc
