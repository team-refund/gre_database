# GRE Database Docker

[기술 스택 문서](https://app.notion.com/p/41bf138a33718154ac8fff50e26810d0)의 PostgreSQL 18 / pgvector 0.8.x 기준으로 구성했습니다.
기반 이미지: `pgvector/pgvector:0.8.2-pg18-trixie`.
현재 `gre_releation_database.sql`을 이미지에 포함하고 빈 데이터 디렉터리의 최초 실행 시 자동 적용합니다.

## 폴더 구성

```text
gre_database/
├── docker/
│   ├── Dockerfile
│   └── .env.example
├── migrations/
│   └── 20261123_add_policy_rag.sql
├── compose.yaml
├── gre_releation_database.sql
├── gre_releation_database.dbml
├── gre_releation_database.dbdiagram
├── .dockerignore
├── .gitignore
└── README.md
```

명령은 저장소 루트에서 실행합니다. 실제 `.env`는 루트에 두며 Git에서 제외합니다.
`artifacts/`의 이미지 파일도 Git에서 제외합니다.

## 실행 (PowerShell)

```powershell
Copy-Item docker/.env.example .env
# .env에서 POSTGRES_PASSWORD를 설정합니다.
docker compose up -d --build
docker compose ps
```

PostgreSQL 18 데이터 볼륨은 `/var/lib/postgresql`에 연결합니다.

## 이미지 파일 전달

```powershell
docker build -f docker/Dockerfile -t gre-database:pg18-vector0.8.2 .
New-Item -ItemType Directory -Force artifacts
docker save -o artifacts/gre-database-pg18-vector0.8.2.tar gre-database:pg18-vector0.8.2
```

받은 PC에서 저장소의 `compose.yaml`과 직접 설정한 `.env`를 사용해 다음 명령을 실행합니다.

```powershell
docker load -i artifacts/gre-database-pg18-vector0.8.2.tar
docker compose up -d --no-build
```

이미지 파일은 스키마를 포함하며 실행 중인 DB 데이터나 비밀번호를 포함하지 않습니다.
빌드한 이미지의 플랫폼은 `linux/amd64`입니다.
기존 볼륨에는 초기화 SQL이 다시 실행되지 않으므로 이후 스키마 변경은 별도 마이그레이션이 필요합니다.

## 기존 DB에 RAG 테이블 추가

`8132d0f` 이전 스키마로 만든 DB에는 백업 후 아래 마이그레이션을 한 번만 실행합니다.
새 DB는 초기화 SQL에 같은 테이블이 포함되어 있으므로 실행하지 않습니다.

```powershell
docker compose cp migrations/20261123_add_policy_rag.sql db:/tmp/gre-add-policy-rag.sql
docker compose exec db sh -c 'exec psql -U $POSTGRES_USER -d $POSTGRES_DB -v ON_ERROR_STOP=1 -f /tmp/gre-add-policy-rag.sql'
```

트랜잭션 안에서 RAG 테이블 3개와 관련 인덱스·제약조건을 추가하며 기존 데이터는 유지합니다.

`docker compose down`은 데이터를 유지합니다. `down -v`는 볼륨 데이터를 삭제하므로 주의하세요.
