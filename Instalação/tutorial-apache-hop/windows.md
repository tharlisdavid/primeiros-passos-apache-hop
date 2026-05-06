# Instalação do Ambiente Apache Hop no Windows

### Guia completo com Docker Desktop

Este guia cobre a instalação do Docker Desktop e a configuração do ambiente completo com **Apache Hop Web**, **PostgreSQL** e **pgAdmin**, tudo via Docker Compose.

---

## 1. Requisitos do sistema

| Requisito | Mínimo |
|---|---|
| Windows | Windows 10 (21H2) ou Windows 11 |
| RAM | 8 GB |
| Disco | 10 GB livres |
| Virtualização | Habilitada na BIOS |

Verifique se a virtualização está ativa: abra o **Gerenciador de Tarefas** (`Ctrl+Shift+Esc`) → aba **Desempenho** → **CPU** → campo **Virtualização: Habilitada**.

---

## 2. Habilitar o WSL 2

O Docker Desktop no Windows usa o WSL 2. Abra o **PowerShell como Administrador** e execute:

```powershell
wsl --install
```

Reinicie o computador quando solicitado. Após reiniciar, configure um usuário e senha para o Ubuntu instalado automaticamente.

Verifique a versão do WSL:

```powershell
wsl --version
```

---

## 3. Instalar o Docker Desktop

1. Acesse o site oficial: https://www.docker.com/products/docker-desktop/
2. Baixe o instalador: **Docker Desktop Installer.exe**
3. Execute o instalador. Durante a instalação, marque **Use WSL 2 instead of Hyper-V**
4. Após a instalação, reinicie o computador
5. Abra o **Docker Desktop** e aguarde a inicialização (ícone da baleia na barra de tarefas)
6. Verifique no PowerShell:

```powershell
docker --version
docker compose version
```

---

## 4. Criar a pasta do projeto

Abra o **PowerShell** e execute:

```powershell
mkdir C:\projetos\apache-hop
cd C:\projetos\apache-hop
mkdir hop-projects
mkdir hop-config
```

---

## 5. Criar o arquivo docker-compose.yml

No PowerShell, abra o Bloco de Notas para criar o arquivo:

```powershell
notepad docker-compose.yml
```

Cole o conteúdo abaixo e salve:

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

---

## 6. Subir o ambiente

No PowerShell, dentro da pasta `C:\projetos\apache-hop`:

```powershell
docker compose up -d
```

O Docker irá baixar as imagens automaticamente na primeira vez (pode demorar alguns minutos dependendo da internet).

Verificar se os containers estão rodando:

```powershell
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

Você também pode acompanhar os containers pelo **Docker Desktop**.

---

## 7. Acessar os serviços

| Serviço | Endereço | Login |
|---|---|---|
| Apache Hop Web | http://localhost:8080/ui | — |
| pgAdmin | http://localhost:5050 | admin@admin.com / admin |
| PostgreSQL | localhost:5432 | hopuser / hopsenha / hopdb |

---

## 8. Configurar o PostgreSQL no pgAdmin

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

## 9. Conectar o Apache Hop ao PostgreSQL

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

## 10. Parar o ambiente

```powershell
docker compose down
```

Para parar e remover também os volumes (apaga os dados do banco):

```powershell
docker compose down -v
```

---

## Erros comuns

### `Hardware assisted virtualization and data execution protection must be enabled`

A virtualização está desabilitada na BIOS. Reinicie, entre na BIOS (`Del`, `F2` ou `F10`) e habilite **Intel VT-x** ou **AMD-V**.

### `WSL 2 installation is incomplete`

Execute no PowerShell como Administrador:

```powershell
wsl --update
wsl --set-default-version 2
```

Reinicie e abra o Docker Desktop novamente.

### `port is already allocated`

Algum programa já está usando a porta. Verifique no PowerShell:

```powershell
netstat -ano | findstr :8080
netstat -ano | findstr :5432
netstat -ano | findstr :5050
```

Encerre o processo que está usando a porta ou altere a porta no `docker-compose.yml`.

### Docker Desktop não inicia

- Verifique se o WSL 2 está instalado e atualizado
- Reinicie pelo Docker Desktop → **Troubleshoot → Restart**
- Reinstale o Docker Desktop se o problema persistir

### Container `hop-web` para logo depois de subir

Verifique os logs:

```powershell
docker logs hop-web
```

Geralmente indica problema de permissão nos volumes `hop-projects` ou `hop-config`.

### Porta 5432 já em uso

Se você tiver PostgreSQL instalado nativamente no Windows, ele pode estar usando a mesma porta. Pare o serviço:

1. Abra **Serviços** (`Win + R` → `services.msc`)
2. Encontre **postgresql-x64-XX**
3. Clique em **Parar**

---

## Conclusão

Ao final deste guia você terá:

- Docker Desktop instalado e configurado com WSL 2
- Apache Hop Web acessível em `localhost:8080/ui`
- PostgreSQL rodando e conectado ao pgAdmin
- pgAdmin acessível em `localhost:5050`
- Volumes persistentes para projetos e configurações do Hop
