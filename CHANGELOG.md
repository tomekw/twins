## unreleased

* make workers count configurable via `--workers, -w`, 8 by default
* change the tasks termination logic from ATC to poison pills

## 0.3.1

* fix: option values can be "one letter long" now

## 0.3.0

* move logger to a separate task backed up by an internal queue
* rework arguments parsing
* validate config options

## 0.2.0

* fix: maximum request length is 1024 bytes without, not with, CRLF
* fix: return 53 Proxy Request Refused for schemes other than gemini://
* fix: accept the request when port is explicitly provided and matches the configured port

## 0.1.0

* initial release
