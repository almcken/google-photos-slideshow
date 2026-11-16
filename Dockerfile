# Google Photos Slideshow – multi-album + admin portal
# Build:  docker build -t google-photos-slideshow .
# Run:    docker run -d -p 8080:8080 -p 6789:6789 -v gpss-config:/config google-photos-slideshow

FROM python:3.12-slim

LABEL org.opencontainers.image.title="Google Photos Slideshow"
LABEL org.opencontainers.image.description="Live communal slideshow for one or more Google Photos shared albums, with admin portal"
LABEL org.opencontainers.image.source="https://github.com/modularizer/google-photos-slideshow"
LABEL org.opencontainers.image.licenses="MIT"

# Avoid interactive prompts and keep image small
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Default ports (override with -e)
    GPSS_PORT=8080 \
    GPSS_WEBSOCKET_PORT=6789 \
    # Config lives on a volume so albums survive restarts
    GPSS_CONFIG=/config/config.yaml \
    # Skip opening a browser (no display in containers)
    GPSS_NO_BROWSER=1

WORKDIR /app

# System deps (none required beyond slim base for this pure-Python app)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first (better layer caching)
COPY requirements.txt pyproject.toml README.md LICENSE MANIFEST.in ./
COPY src/ ./src/

RUN pip install --no-cache-dir -e .

# Non-root user
RUN useradd --create-home --uid 1000 gpss \
    && mkdir -p /config \
    && chown -R gpss:gpss /app /config

USER gpss

EXPOSE 8080 6789

# Healthcheck hits the main page
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:${GPSS_PORT}/', timeout=3)" || exit 1

# Entrypoint script handles env → CLI flags
COPY --chown=gpss:gpss docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["gpss"]
