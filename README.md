# Apache Hop — Ambiente de Integração de Dados

Ambiente completo de integração de dados com **Apache Hop Web**, **PostgreSQL** e **pgAdmin**, orquestrado via Docker Compose.

---

## Arquitetura

```
┌─────────────────────────────────────────────┐
│              Docker — rede hop-net           │
│                                             │
│  ┌──────────────┐    ┌───────────────────┐  │
│  │  Apache Hop  │───▶│    PostgreSQL 15  │  │
│  │  Web :8080   │    │  project-apache-  │  │
│  └──────────────┘    │      hop :5432    │  │
│                      └───────────────────┘  │
│  ┌──────────────┐             ▲             │
│  │   pgAdmin4   │─────────────┘             │
│  │    :5050     │                           │
│  └──────────────┘                           │
└─────────────────────────────────────────────┘
```

---

## Serviços

| Serviço | Container | Porta | Imagem |
|---|---|---|---|
| Apache Hop Web | `hop-web` | `8080` | `apache/hop-web:latest` |
| PostgreSQL | `project-apache-hop` | `5432` | `postgres:15` |
| pgAdmin | `pgadmin` | `5050` | `dpage/pgadmin4:latest` |

---

## Acesso rápido

| Serviço | URL | Credenciais |
|---|---|---|
| Apache Hop Web | http://localhost:8080/ui | — |
| pgAdmin | http://localhost:5050 | `admin@admin.com` / `admin` |
| PostgreSQL | `localhost:5432` | `hopuser` / `hopsenha` / `hopdb` |

---

## Estrutura do projeto

```
apache-hop/
├── docker-compose.yml          # Orquestração dos containers
├── hop-projects/               # Projetos e pipelines do Hop (volume)
├── hop-config/                 # Configurações do Hop (volume)
├── Base de dados/
│   ├── tabela-produto.sql      # DDL + dados da tabela Produtos
│   ├── tabela-vendedor.sql     # DDL + dados da tabela Vendedor
│   └── tabela-vendas.sql       # DDL + dados da tabela Vendas
└── Instalação/
    ├── tutorial-apache-hop/
    │   ├── linux.md            # Instalação completa no Linux
    │   └── windows.md          # Instalação completa no Windows
    └── tutorial-postgres/
        ├── linux.md            # Uso do PostgreSQL/pgAdmin no Linux
        └── windows.md          # Uso do PostgreSQL/pgAdmin no Windows
```

---

## Início rápido

### Pré-requisitos

- Docker Engine (Linux) ou Docker Desktop (Windows/Mac)
- Docker Compose

### 1. Clonar / entrar na pasta do projeto

```bash
cd ~/Documentos/apache-hop
```

### 2. Criar os diretórios de volume (apenas na primeira vez)

```bash
mkdir -p hop-projects hop-config
```

### 3. Corrigir permissões (Linux)

```bash
sudo chown -R $USER:$USER hop-projects hop-config
```

### 4. Subir o ambiente

```bash
# Linux (Ubuntu 24.04 com Docker nativo)
docker-compose up -d

# Linux (Docker Compose plugin) / Windows
docker compose up -d
```

### 5. Verificar containers

```bash
docker ps
```

Saída esperada:

```
NAMES                STATUS    PORTS
hop-web              Up        0.0.0.0:8080->8080/tcp
pgadmin              Up        0.0.0.0:5050->80/tcp
project-apache-hop   Up        0.0.0.0:5432->5432/tcp
```

---

## Banco de dados do projeto

O banco `hopdb` contém três tabelas relacionadas para análise de vendas:

```
Vendedor ──┐
           ├──▶ Vendas
Produtos ──┘
```

| Tabela | Descrição | Arquivo SQL |
|---|---|---|
| `Vendedor` | Cadastro de vendedores com equipe, região e meta | `tabela-vendedor.sql` |
| `Produtos` | Catálogo de produtos com categoria e preço | `tabela-produto.sql` |
| `Vendas` | Registro de vendas com FK para vendedor e produto | `tabela-vendas.sql` |

Para carregar as tabelas no banco, abra o pgAdmin em http://localhost:5050, conecte ao servidor e execute os arquivos SQL pelo **Query Tool** (`Tools → Query Tool`).

A ordem de execução deve ser:
1. `tabela-vendedor.sql`
2. `tabela-produto.sql`
3. `tabela-vendas.sql`

---

## Conexão do Apache Hop ao PostgreSQL

No Apache Hop Web (http://localhost:8080/ui), ao criar uma conexão de banco:

| Campo | Valor |
|---|---|
| **Connection name** | `postgres-hopdb` |
| Connection type | `PostgreSQL` |
| Server host name | `postgres` |
| Port number | `5432` |
| Database name | `hopdb` |
| Username | `hopuser` |
| Password | `hopsenha` |

> O campo **Connection name** é obrigatório. O host deve ser `postgres` (nome do serviço Docker), não `localhost`.

---

## Comandos úteis

```bash
# Ver logs do Hop Web
docker logs hop-web -f

# Ver logs do PostgreSQL
docker logs project-apache-hop -f

# Acessar o banco pelo terminal
docker exec -it project-apache-hop psql -U hopuser -d hopdb

# Parar o ambiente (mantém os dados)
docker-compose down

# Parar e apagar todos os dados
docker-compose down -v

# Recriar apenas o hop-web
docker-compose up -d --force-recreate hop-web
```

---

## Tutoriais detalhados

- [Instalação no Linux](Instalação/tutorial-apache-hop/linux.md)
- [Instalação no Windows](Instalação/tutorial-apache-hop/windows.md)
- [PostgreSQL e pgAdmin no Linux](Instalação/tutorial-postgres/linux.md)
- [PostgreSQL e pgAdmin no Windows](Instalação/tutorial-postgres/windows.md)
