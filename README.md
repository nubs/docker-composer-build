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

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM nubs/arch-build

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
