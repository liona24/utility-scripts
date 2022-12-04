ARG IMAGE=ubuntu:latest

FROM $IMAGE

ARG DEBIAN_FRONTEND=noninteractive

ARG UUID=1000
ARG UGID=$UUID
ARG USERNAME=gef

RUN apt-get update --fix-missing && apt-get upgrade -y
RUN apt-get install -y gdb gdb-multiarch python3 python3-pip git tmux wget curl cmake ipython3 vim strace ltrace build-essential ruby unzip netcat python3-dev file

RUN mkdir -p /ret-sync/ext_gdb && \
    curl -o /ret-sync/ext_gdb/sync.py https://raw.githubusercontent.com/bootleg/ret-sync/master/ext_gdb/sync.py

RUN groupadd --gid $UGID $USERNAME \
    && useradd -s /bin/bash --uid $UUID --gid $UGID -m $USERNAME -d /home/$USERNAME

WORKDIR /home/$USERNAME

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pwntools cryptography unicorn ropper keystone-engine

RUN gem install one_gadget

RUN wget -O .gdbinit-gef.py -q http://gef.blah.cat/py
RUN echo "source /home/$USERNAME/.gdbinit-gef.py" >> /root/.gdbinit

RUN cp /root/.gdbinit /home/$USERNAME/.gdbinit

RUN chown -R $USERNAME:$USERNAME .
USER $USERNAME

COPY tmux.conf .tmux.conf

COPY _gdbinit /tmp/_gdbinit
COPY gef_gdbinit /tmp/gef_gdbinit

RUN cat /tmp/_gdbinit >> /home/$USERNAME/.gdbinit
RUN cat /tmp/gef_gdbinit >> /home/$USERNAME/.gdbinit

ENV LC_CTYPE C.UTF-8

RUN python3 /home/$USERNAME/.gdbinit-gef.py --update --dev

WORKDIR /home/$USERNAME/workdir
ENTRYPOINT [ "tmux" ]
