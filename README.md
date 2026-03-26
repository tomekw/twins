# Twins

Static files [Gemini](https://geminiprotocol.net) server in Ada.

## Status

This is alpha software. I'm actively working it. YMMV.

Tested on Linux x86_64, MacOS ARM and Windows x86_64.

## Installation

Download a binary from [releases](https://github.com/tomekw/twins/releases)
or build from source with [tada](https://github.com/tomekw/tada).

``` shell
tada build --profile release
cp target/release/bin/twins ~/bin/twins
```

## Usage

``` shell
twins --hostname example.com --port 1965 --content-root /var/gemini --cert-file /etc/ssl/certs/cert.pem --key-file /etc/ssl/certs/key.pem
```

or use an example systemd `twins.service` at `resources/systemd`.

Twins is simple. It only supports static files and these extensions:

* `gif`
* `gmi`
* `jpeg`
* `jpg`
* `md`
* `png`
* `txt`

but this may change in the future.

## Disclaimer

This codebase is written by hand. Claude Code is used for Socratic design exploration and code review.

## License

[EUPL](LICENSE)
