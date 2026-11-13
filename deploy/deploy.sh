#!/usr/bin/env bash
# Выкладка презентации на техникс.com (xn--e1aggkwbw.com), сервер FirstVDS Москва (ssh-алиас firstvds-msk).
# Статику отдаёт контейнер tehnics-preza-web (образ caddy:2-alpine, file-server) в сети caddy;
# общий Caddy держит 443 и сертификат Let's Encrypt (TLS-ALPN), nginx ispmanager на :80 даёт 301 на https.
set -euo pipefail
cd "$(dirname "$0")/.."

HOST=firstvds-msk
DOMAIN=xn--e1aggkwbw.com
DIR=/opt/tehnics-preza

export PATH="$HOME/.local/node/bin:$PATH"
SITE_BASE=/ SITE_URL="https://$DOMAIN" npx astro build --outDir dist-domain
test -s dist-domain/index.html
grep -q 'src="/img/hero-m.webp"' dist-domain/index.html || { echo "сборка не с корнем /"; exit 1; }

ssh "$HOST" "mkdir -p $DIR/site"
rsync -az --delete dist-domain/ "$HOST:$DIR/site/"
scp -q deploy/compose.yml "$HOST:$DIR/compose.yml"

ssh "$HOST" bash -s <<EOF
set -euo pipefail
cd $DIR && docker compose up -d

# Блок в общем Caddyfile: заменяется целиком между метками
CF=/opt/caddy/Caddyfile
cp \$CF /opt/deploy-backups/Caddyfile.\$(date +%Y%m%d-%H%M%S).tehnics 2>/dev/null || cp \$CF \$CF.bak-tehnics
sed -i '/^# >>> tehnics-preza/,/^# <<< tehnics-preza/d' \$CF
cat >> \$CF <<'CADDY'
# >>> tehnics-preza: техникс.com – презентация «Техникс» (строительство горных объектов). Блок ставит deploy/deploy.sh репо tema-mail/tehnics-preza.
# Порт 80 у nginx ispmanager – проверка http-01 отключена, остаётся TLS-ALPN.
$DOMAIN, www.$DOMAIN {
	encode gzip zstd
	header -Server
	header X-Robots-Tag "noindex, nofollow"
	tls {
		issuer acme {
			disable_http_challenge
		}
	}
	@www host www.$DOMAIN
	redir @www https://$DOMAIN{uri} permanent
	reverse_proxy tehnics-preza-web:8080
}
# <<< tehnics-preza
CADDY
docker exec caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null
docker exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile

# http → https кодом 301 (не 308: Яндекс не склеивает зеркала по 308)
cat > /etc/nginx/conf.d/tehnics-preza.conf <<'NGINX'
# техникс.com: http → https 301; ставит deploy/deploy.sh репо tema-mail/tehnics-preza
server {
  listen 80;
  listen [::]:80;
  server_name $DOMAIN www.$DOMAIN;
  location /.well-known/acme-challenge/ { return 404; }
  location / { return 301 https://$DOMAIN\$request_uri; }
}
NGINX
nginx -t && systemctl reload nginx
EOF

echo "Выложено. Проверка: curl -sI https://$DOMAIN"
