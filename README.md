# server-infra

How my VPS is set up: base hardening and the shared Caddy reverse proxy. Each app lives in its
own repo; this one holds only what they share.

```
/root/work/
├── server-infra/     this repo — caddy/ runs from here
├── nzfineprint/      github.com/giddypergrid/nzfineprint-backend
└── bird/             github.com/giddypergrid/NZBirdSoundDatabase-Backend + its data folders
```

## New server

```bash
# after your SSH key is installed
git clone https://github.com/giddypergrid/server-infra.git /root/work/server-infra
sh /root/work/server-infra/setup.sh      # tools, Docker, firewall, key-only SSH, `web` network
cd /root/work/server-infra/caddy && docker compose up -d
```

## Add a site

1. In the app's compose file: a fixed `container_name`, `expose` the port (no `ports`), and join the
   external `web` network.
2. Add a block to `caddy/Caddyfile`, commit, `git pull` on the server, then reload without downtime:
   ```bash
   docker exec caddy caddy validate --config /etc/caddy/Caddyfile
   docker exec caddy caddy reload --config /etc/caddy/Caddyfile
   ```
3. DNS: point the record at the server with Cloudflare's proxy **off**, wait for
   `certificate obtained successfully` in `docker logs caddy`, then turn the proxy on
   (SSL mode Full (strict)).

## Client IPs

Sites behind Cloudflare receive the visitor's real IP as `X-Real-IP`. Caddy trusts
`CF-Connecting-IP` only from Cloudflare's ranges in the Caddyfile — keep that list current with
https://www.cloudflare.com/ips.
