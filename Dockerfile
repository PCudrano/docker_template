# FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu18.04
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

ARG USERNAME
ARG USER_UID
ARG USER_GID=$USER_UID
ARG USER_GNAMES
ARG USER_GADD_ARGS
ARG PIP_REQ_FILE
ARG APT_REQ_FILE

SHELL ["/bin/bash", "-c"] 

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
	build-essential ca-certificates python3.9 python3.9-dev python3.9-distutils git vim wget cmake python3-pip
RUN ln -sv /usr/bin/python3.9 /usr/bin/python
RUN ln -svf /usr/bin/python3.9 /usr/bin/python3

# Add user with its groups
USER 0
RUN IFS=";" read -a myarr <<< "$USER_GADD_ARGS" && \
    unset 'myarr[${#arr[@]}-1]' && \
    for i in ${!myarr[@]}; do \
        if [[ ${myarr[$i]} != "sudo"* ]]; then \
            groupadd -f -g ${myarr[$i]}; \
        fi \
    done
RUN  useradd -u $USER_UID -g $USER_GID -m $USERNAME
RUN for g in $USER_GNAMES; do \
        usermod -a -G $g $USERNAME; \
    done
# Allow sudo
RUN     apt-get install -y sudo \
        && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
        && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
RUN wget https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py && \
	rm get-pip.py

# -- Create folders under root for following services
USER 0

# Enable jupyter
RUN mkdir -p /.local
RUN chmod -R 777 /.local

# Enable avalanche
RUN mkdir -p /.avalanche
RUN chmod -R 777 /.avalanche

# Enable wandb
RUN mkdir -p /.config
RUN chmod -R 777 /.config
RUN touch /.netrc
RUN chmod 777 /.netrc
RUN mkdir -p /.cache
RUN chmod -R 777 /.cache

USER $USERNAME

# -- Create folders under root for following services

# install dependencies
USER 0
#ADD apt_requirements.txt /apt_requirements.txt
ADD $APT_REQ_FILE /apt_requirements.txt
RUN apt-get update && cat /apt_requirements.txt | xargs apt-get install -y 
    #apt-get install -y ffmpeg libsm6 libxext6
USER $USERNAME 

#ADD requirements.txt /requirements.txt
ADD $PIP_REQ_FILE /requirements.txt
RUN pip install -r /requirements.txt

CMD ["bash"]
WORKDIR ~/exp
