import { defineConfig } from 'astro/config';

// По умолчанию – GitHub Pages: tema-mail.github.io/tehnics-preza/
// Для домена техникс.com (сервер FirstVDS Москва) deploy/deploy.sh собирает с SITE_BASE=/ и SITE_URL=https://xn--e1aggkwbw.com
export default defineConfig({
  site: process.env.SITE_URL ?? 'https://tema-mail.github.io',
  base: process.env.SITE_BASE ?? '/tehnics-preza',
  trailingSlash: 'ignore',
});
