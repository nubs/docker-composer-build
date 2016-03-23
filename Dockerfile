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

# Configure the base system.  basedir restricts builds to only have sane
# filesystem access.  Timezone is there to silence php's silly warnings.
ADD basedir.ini /etc/php/conf.d/basedir.ini
ADD timezone.ini /etc/php/conf.d/timezone.ini
ADD composer-dependencies.ini /etc/php/conf.d/composer-dependencies.ini

# Create a separate user for composer to run as.  Root access shouldn't
# typically be necessary.  We specify the uid so that it is unique.
RUN useradd --uid 55446 --create-home --comment "Composer Build User" build

RUN mkdir /code && chown build:build /code
WORKDIR /code

USER build
ENV HOME /home/build
ENV COMPOSER_HOME $HOME/.composer

# Set the umask to 002 so that the group has write access inside and outside the
# container.
ADD umask.sh $HOME/umask.sh

# Setup and install composer into the composer global location.  The
# certificate is installed manually to get around open_basedir restrictions.
RUN mkdir -p $COMPOSER_HOME/vendor/bin
RUN curl -sS -o $COMPOSER_HOME/cacert.pem http://curl.haxx.se/ca/cacert.pem
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer --cafile=$COMPOSER_HOME/cacert.pem

# Setup PATH to prioritize local composer bin and global composer bin ahead of
# system PATH.
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH

ENTRYPOINT ["/home/build/umask.sh"]
CMD ["composer", "install"]
