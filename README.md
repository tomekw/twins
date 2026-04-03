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
Usage: twins [options]

Options:
    -H  hostname             default: localhost
    -p  port                 default: 1965
    -r  content root         default: "content" in the current directory
    -c  certificate file     default: "cert.pem" in the current directory
    -k  certificate key      default: "key.pem" in the current directory
    -h  print this message
```

or use an example systemd `twins.service` at `resources/systemd`.

## Roadmap

* [ ] implement config options validation. Just don't make mistakes, okay?

## Disclaimer

This codebase is written by hand. Claude Code is used for Socratic design exploration and code review.

## License

[EUPL](LICENSE)
