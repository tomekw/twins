# Twins

Static files [Gemini](https://geminiprotocol.net) server in Ada.

## Status

This is alpha software. I'm actively working it. YMMV.

Tested on Linux x86_64 and aarch64 (Raspberry Pi), MacOS aarch64, OpenBSD x86_64 and Windows x86_64.

## Installation

See [Releases](https://github.com/tomekw/twins/releases).

``` shell
curl -L https://github.com/tomekw/twins/releases/download/VERSION/twins-VERSION-PLATFORM -o twins && chmod +x twins
```

Copy it somewhere on your `PATH`:

``` shell
cp twins ~/bin/twins
```

## Building from source

Install [tada](https://github.com/tomekw/tada).

Run:

``` shell
tada build --profile release
cp target/release/bin/twins ~/bin/twins
```

## Usage

``` shell
Usage: twins [options]

Options:
  --hostname, -H <hostname>   Server hostname (default: localhost)
  --port, -p <port>           Server port (default: 1965)
  --root, -r <root>           Content root (default: "content" in the current directory)
  --cert, -c <cert>           TLS certificate path (default: "cert.pem" in the current directory)
  --key, -k <key>             TLS key path (default: "key.pem" in the current directory)
  --workers, -w <workers>     Workers count (default: 8)
  --help, -h                  Print this message
```

or use an example systemd `twins.service` at `resources/systemd`.

You can create a self-signed certificate for `localhost` like so:

``` shell
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
                  -keyout key.pem -out cert.pem -days 3650 -nodes \
                  -subj "/CN=localhost" \
                  -addext "subjectAltName=DNS:localhost"
```

## Disclaimer

This codebase is written by hand. Claude Code is used for Socratic design exploration and code review.

## License

[EUPL](LICENSE)
