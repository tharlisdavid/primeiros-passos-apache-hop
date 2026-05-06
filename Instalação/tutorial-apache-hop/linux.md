# Instalação do Ambiente Apache Hop no Linux

### Guia para Pop!_OS, Ubuntu e Debian

Este guia cobre a instalação do Docker, Docker Compose e a configuração do ambiente completo com **Apache Hop Web**, **PostgreSQL** e **pgAdmin**, tudo via Docker Compose.

---

## 1. Atualizar o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Remover versões antigas do Docker (se houver)

```bash
sudo apt remove docker docker.io docker-engine containerd runc docker-compose -y
```

---

## 3. Instalar dependências necessárias

```bash
sudo apt install ca-certificates curl gnupg lsb-release git -y
```

---

## 4. Adicionar o repositório oficial do Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo $ID)/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release; echo $ID) \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

## 5. Instalar o Docker Engine

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Verificar instalação:

```bash
docker --version
docker compose version
```

---

## 6. Ativar o serviço Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

---

## 7. Rodar Docker sem sudo (recomendado)

```bash
sudo usermod -aG docker $USER
```

> Deslogue e entre novamente para aplicar. Teste com `docker ps`.

---

## 8. Instalar o Docker Compose standalone (caso necessário)

Se o comando `docker compose version` retornar erro:

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
```

Se aparecer o erro `bash: /usr/bin/docker-compose: Arquivo ou diretório inexistente`, crie o link simbólico:

```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

> **Nota:** No Ubuntu 24.04 com Docker instalado via `apt`, o comando correto pode ser `docker-compose` (com hífen) ao invés de `docker compose` (com espaço). Ambas as formas são equivalentes — use a que funcionar no seu sistema.

---

## 9. Criar a pasta do projeto

```bash
mkdir -p ~/apache-hop
cd ~/apache-hop
```

---

## 10. Criar os diretórios de volume do Hop

```bash
mkdir -p hop-projects hop-config
sudo chown -R $USER:$USER hop-projects hop-config
```

> Esses diretórios armazenam os projetos e as configurações do Apache Hop. As permissões corretas são necessárias para o container gravar arquivos.

---

## 11. Criar o arquivo docker-compose.yml

```bash
nano docker-compose.yml
```

Cole o conteúdo abaixo:

```yaml
services:
  postgres:
    image: postgres:15
    container_name: project-apache-hop
    restart: always
    environment:
      POSTGRES_USER: hopuser
      POSTGRES_PASSWORD: hopsenha
      POSTGRES_DB: hopdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - hop-net

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    restart: always
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - postgres
    networks:
      - hop-net

  hop-web:
    image: apache/hop-web:latest
    container_name: hop-web
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - ./hop-projects:/files
      - ./hop-config:/root/.hop
    depends_on:
      - postgres
    networks:
      - hop-net

networks:
  hop-net:

volumes:
  postgres_data:
  pgadmin_data:
```

Salve com `Ctrl+O`, depois `Enter`, depois `Ctrl+X`.

---

## 12. Subir o ambiente

```bash
docker-compose up -d
```

> Se `docker-compose` não funcionar, tente `docker compose up -d`.

Verificar se os containers estão rodando:

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

> O Apache Hop Web leva cerca de 25–30 segundos para inicializar completamente após o container subir.

---

## 13. Acessar os serviços

| Serviço | Endereço | Login |
|---|---|---|
| Apache Hop Web | http://localhost:8080/ui | — |
| pgAdmin | http://localhost:5050 | admin@admin.com / admin |
| PostgreSQL | localhost:5432 | hopuser / hopsenha / hopdb |

---

## 14. Configurar o PostgreSQL no pgAdmin

1. Abra o navegador em **http://localhost:5050**
2. Faça login com `admin@admin.com` / `admin`
3. No painel esquerdo, clique com o botão direito em **Servers** → **Register** → **Server**
4. Na aba **General**, defina o nome: `Apache Hop DB`
5. Na aba **Connection**, preencha:

| Campo | Valor |
|---|---|
| Host name/address | `postgres` |
| Port | `5432` |
| Maintenance database | `hopdb` |
| Username | `hopuser` |
| Password | `hopsenha` |

6. Marque **Save password**
7. Clique em **Save**

> O host é `postgres` (nome do serviço no docker-compose), **não** `localhost`.

---

## 15. Conectar o Apache Hop ao PostgreSQL

1. Abra o Apache Hop em **http://localhost:8080/ui**
2. Crie ou abra um pipeline
3. No menu, acesse **File → New → Database connection** ou clique em **New** dentro de um step que exige conexão
4. Preencha o formulário:

| Campo | Valor |
|---|---|
| **Connection name** | `postgres-hopdb` |
| Connection type | `PostgreSQL` |
| Server host name | `postgres` |
| Port number | `5432` |
| Database name | `hopdb` |
| Username | `hopuser` |
| Password | `hopsenha` |

> **Atenção:** o campo **Connection name** no topo do formulário é obrigatório. Sem ele, o Hop exibe o erro *"Please give this database connection a name"*.

5. Clique em **Test** para verificar a conexão
6. Clique em **OK** para salvar

---

## 16. Parar o ambiente

```bash
docker-compose down
```

Para parar e remover também os volumes (apaga os dados do banco):

```bash
docker-compose down -v
```

---

## Erros comuns

### `port is already allocated`

Algum serviço já está usando a porta. Verifique:

```bash
sudo ss -tulpn | grep 8080
sudo ss -tulpn | grep 5432
sudo ss -tulpn | grep 5050
```

### `Cannot connect to the Docker daemon`

O Docker não está rodando. Inicie:

```bash
sudo systemctl start docker
```

### Container `hop-web` sobe mas para logo depois (Exit 255)

Verifique as permissões dos diretórios de volume:

```bash
sudo chown -R $USER:$USER hop-projects hop-config
docker-compose up -d --force-recreate hop-web
```

Veja os logs para mais detalhes:

```bash
docker logs hop-web
```

### `docker compose` não encontrado

Use `docker-compose` (com hífen):

```bash
docker-compose up -d
```

---

## Conclusão

Ao final deste guia você terá:

- Docker Engine e Docker Compose instalados
- Apache Hop Web acessível em `localhost:8080/ui`
- PostgreSQL rodando e conectado ao pgAdmin
- pgAdmin acessível em `localhost:5050`
- Volumes persistentes para projetos e configurações do Hop
