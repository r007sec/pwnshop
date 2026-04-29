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

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["node", "src/app.js"]