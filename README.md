# dot-http mode

A simple convenience mode that wraps around [dot-http](https://github.com/bayne/dot-http) and makes working with files that comply with the [HTTP Request in Editor Specification](https://github.com/JetBrains/http-request-in-editor-spec) defined by JetBrains possible from within Emacs.

*Hint: I primarily built this mode in order to familiarize myself with Elisp development. Pull Requests that extend the mode, improve my code or teach me new things are highly welcome.*

## Installation

tbd 

dot-http mode is not yet published to MELPA or any other repository.

## Usage

### Prerequisites

In order to use this mode [dot-http](https://github.com/bayne/dot-http) needs to be installed and available in your `$PATH`.

### Commands

Whithin a HTTP file you can run a request either by calling `M-x dot-http-run-request-at-point` or `M-x dot-http-list-requests`.

1. Move point to a request (any line that starts with a HTTP method like GET, POST, etc.) and execute by running `dot-http-run-request-at-point`.
2. Running `dot-http-list-requests` gives you a list of all requests found in the file. Pick one and run the request (you need Ivy for this).

## Todos and Ideas

- Recognize HTTP files and activate mode automatically
- Make Ivy optional/configurable
- Improve output buffer handling
- Custom faces (colors etc)
- Auto completion (compare with [restclient.el](https://github.com/pashky/restclient.el))

## Acknowledgment and Inspiration

There are several modes that do similar things like dot-http and, probably, do it way better. 

- [restclient.el](https://github.com/pashky/restclient.el)
- [Verb](https://github.com/federicotdn/verb)
- and others
