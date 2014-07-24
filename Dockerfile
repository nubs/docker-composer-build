FROM base/archlinux

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN pacman --sync --refresh --sysupgrade --ignore filesystem --noconfirm --noprogressbar --quiet
RUN pacman --sync --noconfirm --noprogressbar --quiet php git openssh

ADD composer-dependencies.ini /etc/php/conf.d/composer-dependencies.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN useradd --create-home --comment "Composer Build User" build
USER build
ENV HOME /home/build

VOLUME ["/code"]
WORKDIR /code

CMD ["composer", "install"]
