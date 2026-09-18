// Copies the founding paper into public/ so the site can serve it. paper/ stays canonical.
import { cpSync, rmSync } from 'node:fs';

const target = new URL('../public/paper/', import.meta.url);
rmSync(target, { recursive: true, force: true });
cpSync(new URL('../../paper/', import.meta.url), target, { recursive: true });
