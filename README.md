GNU Guix Workflow Language extension
====================================

This project provides two subcommands to GNU Guix and introduces two record
types that provide a workflow management extension built on top of GNU Guix's
package manager.

## Installation

1. [Install GNU Guix](https://www.gnu.org/software/guix/manual/html_node/Binary-Installation.html)

2. Install GWL:

```bash
guix package -i gwl
```

## Getting started

GWL has a built-in getting-started guide.  To use it, run:

```bash
guix workflow --web-interface
```

Then point your web browser to the following location:

```bash
http://localhost:5000
```
