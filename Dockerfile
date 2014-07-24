FROM base/archlinux

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN pacman --sync --refresh --sysupgrade --ignore filesystem --noconfirm --noprogressbar --quiet
RUN pacman --sync --noconfirm --noprogressbar --quiet php git openssh

ADD basedir.ini /etc/php/conf.d/basedir.ini
ADD timezone.ini /etc/php/conf.d/timezone.ini
ADD composer-dependencies.ini /etc/php/conf.d/composer-dependencies.ini

RUN useradd --create-home --comment "Composer Build User" build
USER build
ENV HOME /home/build
ENV COMPOSER_HOME $HOME/.composer

RUN mkdir -p $COMPOSER_HOME/vendor/bin
RUN curl -sS -o $COMPOSER_HOME/cacert.pem http://curl.haxx.se/ca/cacert.pem
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=$COMPOSER_HOME/vendor/bin --filename=composer --cafile=$COMPOSER_HOME/cacert.pem

ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH

VOLUME ["/code"]
WORKDIR /code

CMD ["composer", "install"]
