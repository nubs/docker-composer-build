# Contribution Guidelines
This project is wide open to contributions.  You can use GitHub to [report
issues][issues] or [submit pull requests][pull-requests].  When opening pull
requests, it is recommended to follow these guidelines in order to grease the
wheels, so to speak.

Please include as many details as you can in any issues and pull requests.
Understanding how you are using the library and exactly what problems you are
having can also help make things move quickly.

## Building
This project is built using the standard [Docker][docker] build process.
Please ensure that all modifications build without a cache.

```bash
docker build --no-cache .
```

## Automated builds
Merged code will be automatically built on docker hub at
[nubs/composer-build][docker-hub-repository].

[issues]: https://github.com/nubs/docker-composer-build/issues
[pull-requests]: https://github.com/nubs/docker-composer-build/pulls
[docker]: https://docker.com/ "Docker - Build, Ship, and Run Any App, Anywhere"
[docker-hub-repository]: https://registry.hub.docker.com/u/nubs/composer-build/
