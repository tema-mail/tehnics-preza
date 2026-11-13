#!/usr/bin/env bash
# Выкладка на https://tehnics-group.github.io/ – организация tehnics-group, репо tehnics-group.github.io.
# В репо уходит только готовая сборка (без исходников), Pages берёт ветку main из корня.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO=tehnics-group/tehnics-group.github.io
URL=https://tehnics-group.github.io
OUT=dist-gh

export PATH="$HOME/.local/node/bin:$PATH"
rm -rf "$OUT"
SITE_BASE=/ SITE_URL="$URL" npx astro build --outDir "$OUT"
grep -q 'src="/img/hero-m.webp"' "$OUT/index.html" || { echo "сборка не с корнем /"; exit 1; }
touch "$OUT/.nojekyll"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone -q "https://github.com/$REPO.git" "$TMP/repo" 2>/dev/null || { mkdir -p "$TMP/repo"; git -C "$TMP/repo" init -q -b main; git -C "$TMP/repo" remote add origin "https://github.com/$REPO.git"; }
find "$TMP/repo" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$OUT"/. "$TMP/repo/"
cd "$TMP/repo"
git add -A
if git diff --cached --quiet; then echo "Без изменений"; exit 0; fi
git -c user.name="tehnics-group" -c user.email="tehnics-group@users.noreply.github.com" \
  commit -qm "Презентация Техникс: обновление $(date +%d.%m.%Y)"
git push -q -u origin main
echo "Выложено: $URL"
