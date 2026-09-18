# Contributing

Thank you for your interest in the Unified Path of Light. This page explains how to propose a
change to the teachings, the website, or the repository.

## 1. What kind of change

- **The teachings (`content/`).** Open an issue first so the change can be discussed before
  any text is written. Keep a wording change in its own pull request, separate from
  structural or site changes.
- **The website (`site/`) and everything else.** A pull request is welcome directly.

## 2. Setup

```bash
npm --prefix site install
npm --prefix site run dev
```

Node.js 22.19 or later is required. See
[docs/features-and-usage.md](docs/features-and-usage.md) for how to add a page or a section.

### Signed commits required

Commits to `main` must carry a verified signature. Set up once:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Then add the key to your GitHub account as a signing key: <https://github.com/settings/keys>.

## 3. Workflow

1. Branch off `main`. Naming: `feat/<short>`, `fix/<short>`, `docs/<short>`,
   `chore/<short>`. Nothing is committed directly to `main`.
2. Use conventional commits: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`,
   `perf`, `build`, `ci`, `revert`.
3. Before pushing, run the same checks CI runs:

   ```bash
   bash scripts/check.sh
   ```

4. Open a pull request using the [template](.github/pull_request_template.md).
5. All CI checks must be green. Pull requests are squash-merged.

## 4. Conventions

Naming, front matter, and writing conventions are in
[docs/conventions.md](docs/conventions.md).

## 5. Security

Never commit a secret. To report a vulnerability, follow [SECURITY.md](SECURITY.md).
