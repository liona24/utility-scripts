ARG IMAGE=ubuntu:latest

FROM $IMAGE

ARG DEBIAN_FRONTEND=noninteractive

ARG UUID=1000
ARG UGID=$UUID
ARG USERNAME=pwndbg

RUN apt-get update --fix-missing && apt-get upgrade -y
RUN apt-get install -y gdb gdb-multiarch python3 git tmux wget curl cmake ipython3 vim
RUN git clone https://github.com/pwndbg/pwndbg /pwndbg && \
    cd /pwndbg && \
    ./setup.sh

RUN git clone https://github.com/radareorg/radare2 && \
    radare2/sys/install.sh

RUN pip install r2pipe

RUN mkdir -p /ret-sync/ext_gdb && \
    curl -o /ret-sync/ext_gdb/sync.py https://raw.githubusercontent.com/bootleg/ret-sync/master/ext_gdb/sync.py

RUN git clone https://github.com/jerdna-regeiz/splitmind /splitmind

RUN groupadd --gid $UGID $USERNAME \
    && useradd -s /bin/bash --uid $UUID --gid $UGID -m $USERNAME -d /home/$USERNAME

WORKDIR /home/$USERNAME

RUN cp /root/.gdbinit /home/$USERNAME/.gdbinit

COPY _gdbinit /tmp/_gdbinit
COPY pwndbg_gdbinit /tmp/pwndbg_gdbinit
RUN cat /tmp/pwndbg_gdbinit >> /home/$USERNAME/.gdbinit && \
    rm /tmp/pwndbg_gdbinit
RUN cat /tmp/_gdbinit >> /home/$USERNAME/.gdbinit && \
    rm /tmp/_gdbinit

RUN chown $USERNAME:$USERNAME -R .
USER $USERNAME

RUN r2pm update && \
    r2pm -ci r2ghidra

COPY tmux.conf .tmux.conf

ENV LC_CTYPE C.UTF-8

WORKDIR /home/$USERNAME/workdir
ENTRYPOINT [ "tmux" ]
