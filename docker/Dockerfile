FROM pgvector/pgvector:0.8.2-pg18-trixie

COPY gre_releation_database.sql /docker-entrypoint-initdb.d/01-gre-schema.sql

HEALTHCHECK --interval=5s --timeout=5s --start-period=30s --retries=10 \
  CMD pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" || exit 1
