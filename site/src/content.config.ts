import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';
import { routeFor } from './lib/routes.mjs';

const teachings = defineCollection({
  loader: glob({
    pattern: '**/*.md',
    base: '../content',
    generateId: ({ entry }) => routeFor(entry) || 'index',
  }),
  schema: z.object({ title: z.string(), order: z.number(), description: z.string().optional() }),
});

export const collections = { teachings };
