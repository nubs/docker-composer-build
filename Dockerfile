FROM base/archlinux

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

# Update system and install php + composer dependencies (git and openssh for
# access to repositories)
RUN pacman --sync --refresh --sysupgrade --ignore filesystem --noconfirm --noprogressbar --quiet && pacman --sync --noconfirm --noprogressbar --quiet php git openssh

# Configure the base system.  basedir restricts builds to only have sane
# filesystem access.  Timezone is there to silence php's silly warnings.
ADD basedir.ini /etc/php/conf.d/basedir.ini
ADD timezone.ini /etc/php/conf.d/timezone.ini
ADD composer-dependencies.ini /etc/php/conf.d/composer-dependencies.ini

# Create a separate user for composer to run as.  Root access shouldn't
# typically be necessary.  We specify the uid so that it is unique.
RUN useradd --uid 55446 --create-home --comment "Composer Build User" build

#Set the umask to 002 so that the group has write access inside and outside the container.
ADD umask.sh /home/build/umask.sh

USER build
ENV HOME /home/build
ENV COMPOSER_HOME $HOME/.composer

# Setup and install composer into the composer global location.  The
# certificate is installed manually to get around open_basedir restrictions.
RUN mkdir -p $COMPOSER_HOME/vendor/bin
RUN curl -sS -o $COMPOSER_HOME/cacert.pem http://curl.haxx.se/ca/cacert.pem
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer --cafile=$COMPOSER_HOME/cacert.pem

# Setup PATH to prioritize local composer bin and global composer bin ahead of
# system PATH.
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH

VOLUME ["/code"]
WORKDIR /code

ENTRYPOINT ["/home/build/umask.sh"]
CMD ["composer", "install"]
