import { defineConfig } from 'astro/config';

// Презентация живёт на GitHub Pages: tema-mail.github.io/tehnics-preza/
export default defineConfig({
  site: 'https://tema-mail.github.io',
  base: '/tehnics-preza',
  trailingSlash: 'ignore',
});
