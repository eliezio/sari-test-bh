FROM alpine:3.11
LABEL maintainer="Eliezio Oliveira <eliezio@pm.me>"

RUN set -eux; \
    apk add --no-cache \
        openssh \
        openssh-server-pam \
        sudo; \
    ssh-keygen -A; \
    echo "Set disable_coredump false" >> /etc/sudo.conf; \
    sed -i -e 's/^\# \(%wheel.*NOPASSWD\)/\1/' /etc/sudoers; \
    adduser --disabled-password --ingroup wheel --gecos Administrator admin; \
    adduser --disabled-password --shell /bin/false --gecos "Proxy User" acme

COPY sshd_config /etc/ssh/

COPY --chown=admin:wheel admin_id_rsa.pub /home/admin/.ssh/authorized_keys
COPY --chown=acme:acme   admin_id_rsa.pub /home/acme/.ssh/authorized_keys

RUN set -eux; \
    chmod 400 \
        /home/admin/.ssh/authorized_keys \
        /home/acme/.ssh/authorized_keys

EXPOSE 22

ENTRYPOINT [ "/usr/sbin/sshd", "-D", "-e" ]
