# docker-composer-build
This is a base image for building [PHP][PHP] [composer] packages.

## Purpose
This docker image builds on top of Arch Linux's base/archlinux image for the
purpose of building PHP composer packages.  It provides several key features:

* A non-root user (`build`) for executing the image build.  This is important
  for security purposes and to ensure that the package doesn't require root
  permissions to be built.
* Access to the build location will be in the volume located at `/code`.  This
  directory will be the default working directory.
* PHP limited access using `open_basedir`.  By default, access is only granted
  to `/code`, `/tmp`, and `$COMPOSER_HOME`.  For general builds this should
  likely be sufficient, but should you need to override the settings you can do
  so by updating `/etc/php/conf.d/basedir.ini`.
* Composer bin directories are automatically included in `PATH`.  Both a
  relative `vendor/bin` directory, and the global `$COMPOSER_HOME/vendor/bin`
  directory are included in the `PATH`.
* Timezone set to `UTC` by default to remove the warnings with PHP's date and
  time functions.  This can be overridden by updating
  `/etc/php/conf.d/timezone.ini`.

## Usage
This library is useful with simple `composer.json`'s from the command line.
For example:

```bash
docker run --interactive --tty --rm --volume /tmp/my-code:/code nubs/composer-build

# Using short-options:
# docker run -i -t --rm -v /tmp/my-code:/code nubs/composer-build
```

This will execute the default command (`composer install`) and update your code
directory with the result (i.e., `vendor` and `composer.lock`).

Other commands can also be executed.  For example, to update dependencies:

```bash
docker run -i -t --rm -v /tmp/my-code:/code nubs/composer-build composer update
```

## Permissions
This image uses a build user to run composer.  This means that your file
permissions must allow this user to write to certain folders like `vendor`.
The easiest way to do this is to create a group and give that group write
access to the necessary folders.

```bash
groupadd --gid 55446 composer-build
chmod -R g+w vendor
chgrp -R composer-build vendor
```

You may also want to give your user access to files created by the build user.

```bash
usermod -a -G 55446 "$(whoami)"
```

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM nubs/composer-build

USER root

RUN pacman --sync --noconfirm --noprogressbar --quiet xdebug

USER build
```

You can then build this docker image and run it against your `composer.json`
volume like normal (this example assumes the `composer.json` and `Dockerfile`
are in your current directory):

```bash
docker build --tag my-code .
docker run -i -t --rm -v "$(pwd):/code" my-code
docker run -i -t --rm -v "$(pwd):/code" my-code composer update
```

[PHP]: http://php.net/ "PHP: Hypertext Preprocessor"
[composer]: https://getcomposer.org/
