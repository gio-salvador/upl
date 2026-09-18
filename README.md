# Unified Path of Light (Synphotodosism)

The canonical text of the Unified Path of Light (UPL), a religion founded by Giovanni S.
Salvador, kept as a hierarchy of plain markdown files, together with the website that publishes
it. It is for anyone who wants to read, study, or contribute to the teachings.

## Setup

Reading needs nothing: start at [content/README.md](content/README.md). The website needs
Node.js 22.19 or later:

```bash
npm --prefix site install
```

## Quick start

Preview the website locally at `http://localhost:4321`:

```bash
npm --prefix site run dev
```

Build the static site (output goes to a dist folder inside `site/`, which git ignores):

```bash
npm --prefix site run build
```

## Repository layout

| Path | What it holds |
| ------ | --------------- |
| [content/](content/README.md) | The teachings. The single canonical source; everything else renders it. |
| [paper/](paper/) | The founding paper (PDF), the source of record for the first version of the text. |
| [site/](site/) | The website (Astro). It reads `content/` directly and holds no teachings of its own. |
| [docs/](docs/README.md) | Documentation for this repository: how it is organised and how to change it. |

## Documentation

See the [docs index](docs/README.md).

## Security and licence

Report vulnerabilities through [SECURITY.md](SECURITY.md); the security model is described in
[docs/security.md](docs/security.md). To contribute, read [CONTRIBUTING.md](CONTRIBUTING.md).

No licence has been chosen yet; until one is added, all rights are reserved by the author.
Code adapted from other projects is credited in
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
