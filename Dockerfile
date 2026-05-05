FROM node:18-bullseye
WORKDIR /usr/src/app

# Create non-root user for app
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install mysql client and gosu
RUN apt-get update \
    && apt-get install -y --no-install-recommends default-mysql-client gosu \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/src/app/scripts/*.sh && \
    chown -R appuser:appuser /usr/src/app && \
    mkdir -p /usr/src/app/public/uploads && \
    chmod 777 /usr/src/app/public/uploads

# ── Railway hardening (replaces docker-compose.lab.yml restrictions) ──────────

# Replaces `:ro` volume mounts — make source, scripts and SQL snapshot
# read-only so a student with RCE cannot permanently alter lab logic.
# uploads/ and uploads-seed/ are intentionally left writable (healer needs them).
RUN chmod -R a-w /usr/src/app/src && \
    chmod -R a-w /usr/src/app/scripts && \
    chmod    a-w /usr/src/app/pwnshop.sql && \
    chmod -R a-w /usr/src/app/public/uploads-seed

# Replaces `tmpfs: [/tmp, /var/tmp, /run]`
# Sticky bit prevents one process from deleting another process's temp files.
# 1777 = rwxrwxrwt (world-writable + sticky)
RUN chmod 1777 /tmp /var/tmp && \
    mkdir -p /run && chmod 1777 /run

# ──────────────────────────────────────────────────────────────────────────────

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["node", "src/app.js"]