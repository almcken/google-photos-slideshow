# google-photos-slideshow

NOTE: this project is in no way affiliated with or sponsored by Google Photos.

A **simple**, **live**, **communal** slideshow.

* **auto-updates** as photos are added to the album(s)
* **multiple Google Photos albums** – add 2+ shared albums; the app cycles through all of them
* **Admin portal** at `/admin` to add / remove albums and set default speed
* **Fullscreen / kiosk URLs** for TVs and displays
* **live communal controls** (play/pause, next/previous, speed)
* easy to **cast** to a Chromecast
* **dark mode** for viewing in a dimmed room

---

## Quick start (Docker – recommended)

The image is published on Docker Hub:

**[almcken/google-photos-slideshow](https://hub.docker.com/repository/docker/almcken/google-photos-slideshow/general)**

### Sample `docker-compose.yml`

```yaml
services:
  slideshow:
    image: almcken/google-photos-slideshow:latest
    container_name: google-photos-slideshow
    restart: unless-stopped
    ports:
      - "8080:8080"   # HTTP – slideshow + admin
      - "6789:6789"   # WebSocket – live controls
    volumes:
      - gpss-config:/config   # persists album list + default speed
    environment:
      GPSS_PORT: "8080"
      GPSS_WEBSOCKET_PORT: "6789"
      GPSS_CONFIG: /config/config.yaml
      GPSS_NO_BROWSER: "1"
      # Optional: seed albums on first start (comma-separated share URLs)
      # GPSS_URLS: "https://photos.google.com/share/ALBUM1?key=...,https://photos.google.com/share/ALBUM2?key=..."
      # GPSS_TITLE: "Family Slideshow"

volumes:
  gpss-config:
```

### Run it

```bash
docker compose up -d
```

Then open:

| Page | URL |
|------|-----|
| Slideshow | http://localhost:8080/ |
| Admin (add albums, set speed) | http://localhost:8080/admin |
| Auto fullscreen | http://localhost:8080/?fullscreen=1 |
| Kiosk (fullscreen + hide controls) | http://localhost:8080/?kiosk=1 |

From another device on your network, replace `localhost` with the host’s IP.

### Portainer

1. **Stacks** → **Add stack** → **Web editor**
2. Paste the compose file above
3. Deploy

No Git build required — Portainer will pull `almcken/google-photos-slideshow:latest`.

### Plain Docker (no compose)

```bash
docker run -d --name gpss --restart unless-stopped \
  -p 8080:8080 -p 6789:6789 \
  -v gpss-config:/config \
  -e GPSS_NO_BROWSER=1 \
  almcken/google-photos-slideshow:latest
```

---

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GPSS_PORT` | `8080` | HTTP port (slideshow + admin) |
| `GPSS_WEBSOCKET_PORT` | `6789` | WebSocket port for live controls |
| `GPSS_CONFIG` | `/config/config.yaml` | Path to persisted config |
| `GPSS_URLS` | _(empty)_ | Comma-separated shared album URLs to seed on start |
| `GPSS_TITLE` | — | Slideshow title |
| `GPSS_IMAGE_DURATION` | `4` | Seconds per image (alternative to speed) |
| `GPSS_REFRESH_INTERVAL` | `5` | Seconds between album re-fetches |
| `GPSS_FRESH` | — | Set to `1` to ignore saved config |
| `GPSS_NO_BROWSER` | `1` (in image) | Skip opening a browser |

---

## Using the app

### Add albums

1. Open Google Photos → Albums → open an album → **Share** → create a link (URL must include `key=`).
2. Open **http://YOUR_HOST:8080/admin**
3. Paste the URL (optional name) → **Add**
4. Add as many albums as you like. Photos from all enabled albums are pooled and cycled; new photos appear automatically.

### Default speed

On the Admin page, set **Default speed** (0.25x–4x) and click **Save speed**.  
1x ≈ 4 seconds per photo. The setting is saved and applied to all viewers.

### Fullscreen / kiosk

| URL | Behavior |
|-----|----------|
| `/?fullscreen=1` or `/?fs=1` | Request fullscreen on load |
| `/?kiosk=1` | Fullscreen + hide on-screen controls (good for TVs) |

Browsers often require one click before fullscreen is allowed. If auto-enter is blocked, a “Tap to enter fullscreen” screen appears once.

---

## Install without Docker (pip)

```bash
pip install google-photos-slideshow
gpss
```

Or from this repo:

```bash
pip install -e .
gpss
```

* First run prompts for a shared album URL (or use Admin after start).
* Later runs reuse the saved album list.
* `gpss --urls URL1 URL2` or `gpss --fresh` to reset.

---

## Other modes

### Folder slideshow

```bash
folder-slideshow /path/to/folder
```

### Features (summary)

* Play / pause, next / previous, speed control (communal over WebSocket)
* Live reload when albums change
* Multiple Google Photos shared albums + Admin UI
* Fullscreen / kiosk URL params
* Chromecast support (best on `localhost`)
* Config persisted in YAML (`/config` volume in Docker)

---

## Updating the image

```bash
docker pull almcken/google-photos-slideshow:latest
docker compose up -d
```

Or in Portainer: stack → **Pull and redeploy**.

Album list and default speed stay in the `gpss-config` volume across updates.

---

## Publishing / building yourself

```bash
docker build -t YOUR_USER/google-photos-slideshow:latest .
docker push YOUR_USER/google-photos-slideshow:latest
```

A GitHub Actions workflow (`.github/workflows/docker-publish.yml`) can also build and push to GHCR on push/tag.

---

## License

See [LICENSE](LICENSE).
```
