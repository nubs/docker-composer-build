# docker-composer-build
This is a base image for building [PHP][PHP] [composer] packages.

## Purpose
This docker image builds on top of the official PHP 7.0-alpine image with the
purpose of building PHP composer packages.  It provides several key features:

* Access to the build location will be in the volume located at `/code`.  This
  directory will be the default working directory.
* Composer bin directories are automatically included in `PATH`.  Both a
  relative `vendor/bin` directory, and the global `$COMPOSER_HOME/vendor/bin`
  directory are included in the `PATH`.

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
This image runs as root (PID 0), but for security purposes it is recommended to
use Docker's [user namespace functionality][docker-user-namespaces] to map that
to a non-privileged user on your host system.

If you use volume mounting of your project (e.g., to run `composer install`
inside the container but want to modify the host `vendor` directory), then you
may run into permission issues.

Without Docker's user namespaces, the container will create files/directories
with root ownership on your host which may cause issues when trying to access
them as a non-root user.

When using Docker's user namespaces, the container will be running under a
different user.  You may have to adjust permissions on the directory to allow
the user to create/modify files.  For example, giving an `/etc/setuid` and
`/etc/subgid` that contains `dockremap:165536:65536` and a docker daemon
running using this default mapping: `docker daemon --userns-remap=default`,
you would need to run the following to give the container access to run
`composer install` and yourself access to do so on the host:

```bash
groupadd --gid 165536 subgid-root
chmod -R g+w vendor
chgrp -R subgid-root node_modules
usermod -a -G subgid-root "$(whoami)"
```

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM nubs/composer-build

RUN apk add --no-cache xdebug && \
    docker-php-ext-enable xdebug
```

You can then build this docker image and run it against your `composer.json`
volume like normal (this example assumes the `composer.json` and `Dockerfile`
are in your current directory):

```bash
docker build --tag my-code .
docker run -i -t --rm -v "$(pwd):/code" my-code
docker run -i -t --rm -v "$(pwd):/code" my-code composer update
```

## License
docker-composer-build is licensed under the MIT license.  See [LICENSE] for
the full license text.

[PHP]: http://php.net/ "PHP: Hypertext Preprocessor"
[composer]: https://getcomposer.org/
[docker-use-namespaces]: https://docs.docker.com/engine/reference/commandline/daemon/#daemon-user-namespace-options
[LICENSE]: https://github.com/nubs/docker-composer-build/blob/master/LICENSE
