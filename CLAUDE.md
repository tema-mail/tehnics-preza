# Техникс – презентация на Astro

Перенос презентации из Figma (файл 9XHc18yyVKVe0ki1HUFf5w) в одну страницу: десктоп и мобилка, планшет не делаем, полноценный сайт не делаем.
- Слайды в Figma – растровые картинки с впечатанным текстом: текст набран HTML, из слайдов вырезаны только фото (public/img, WebP).
- Исходники из Figma – `_figma/` (в git не идут).
- Контакты (замена 13.11.2026): +7 960 794-76-07, t.tehnics@tehnics.bizml.ru – константы вверху src/pages/index.astro.
- Основной адрес: https://tehnics-group.github.io/ (организация GitHub tehnics-group, репо tehnics-group.github.io – только сборка). Выкладка: `bash deploy/github-io.sh`.
- Запасной: push в main → tema-mail.github.io/tehnics-preza/.
- Домен техникс.com в бою с 16.11.2026: сервер FirstVDS Москва, выкладка `bash deploy/deploy.sh`. В reg.ru (fond_04@mail.ru) у домена только DNS: ns1/ns2.reg.ru, A @ и www → 168.113.179.49. Хостинг заказчика не трогаем. Ход работ – docs/sostoyanie.md.
- Страница закрыта от индекса (noindex).
