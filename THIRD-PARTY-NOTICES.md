# Third-party notices

Parts of this repository are adapted from the Salvador Cloud website repository, whose code
is licensed under the MIT licence. Only code and configuration were taken; no content, brand
assets, or documentation.

The folder `.claude/toolkit/` is a vendored, unmodified copy of part of the
salvadorcloud-ai-toolkit, licensed under Apache-2.0. The exact version is recorded in
`.claude/toolkit.lock`.

## Adapted files

- `site/src/components/seo/Meta.astro`
- `site/src/components/seo/JsonLd.astro`
- `site/src/lib/structured-data.ts`
- `site/public/_headers` (header values)
- `site/scripts/check-mobile.mjs` (the checks and their thresholds)
- `.github/workflows/ci.yml`, `.github/workflows/security.yml`,
  `.github/workflows/scorecard.yml`
- `infra/providers.tf`, `infra/backend.tf`, `infra/pages.tf`, `.github/workflows/iac.yml`,
  `.github/workflows/deploy.yml`
- `.editorconfig`, `.gitattributes`

## Licence

MIT licence

Copyright (c) 2026 Salvador Cloud Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
