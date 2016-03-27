FROM base/archlinux:latest

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=6&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

# Update system and install php + composer dependencies (git and openssh for
# access to repositories)
RUN pacman-key --refresh-keys && \
    pacman --sync --refresh --noconfirm --noprogressbar --quiet && \
    pacman --sync --noconfirm --noprogressbar --quiet archlinux-keyring openssl pacman && \
    pacman-db-upgrade && \
    pacman --sync --sysupgrade --noconfirm --noprogressbar --quiet && \
    pacman --sync --noconfirm --noprogressbar --quiet php git openssh

# Configure the base system.  Timezone is there to silence php's silly
# warnings.
COPY timezone.ini /etc/php/conf.d/

RUN mkdir /code
WORKDIR /code

ENV HOME /root
ENV COMPOSER_HOME $HOME/.composer

# Setup and install composer into the composer global location.  The
# certificate is installed manually to get around open_basedir restrictions.
RUN mkdir -p $COMPOSER_HOME/vendor/bin
RUN curl -sSLo $COMPOSER_HOME/cacert.pem http://curl.haxx.se/ca/cacert.pem
RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer --cafile=$COMPOSER_HOME/cacert.pem

# Setup PATH to prioritize local composer bin and global composer bin ahead of
# system PATH.
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH

CMD ["composer", "install"]
