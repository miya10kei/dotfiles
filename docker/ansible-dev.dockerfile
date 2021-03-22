FROM miya10kei/base-dev:latest

RUN apt-get update \
    && apt-get -y install \
          openssh-server \
          python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible

RUN cat /etc/ssh/sshd_config \
      | sed -r \
            -e 's/#(PasswordAuthentication) yes/\1 no/' \
            -e 's/#(PermitRootLogin) prohibit-password/\1 no/' \
            -e 's/#(PermitEmptyPasswords) no/\1 no/' \
            -e 's/#(PubkeyAuthentication) yes/\1 yes/' \
      | tee /etc/ssh/sshd_config > /dev/null

COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/bin/fish"]
