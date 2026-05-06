# PostgreSQL com pgAdmin no Windows

### Guia completo com Docker Desktop

Este guia cobre como subir e utilizar o **PostgreSQL** e o **pgAdmin** via Docker Compose no Windows, integrado ao ambiente Apache Hop.

> Pré-requisito: Docker Desktop instalado e funcionando. Consulte o tutorial `tutorial-apache-hop/windows.md` se ainda não tiver.

---

## 1. O que é PostgreSQL?

O **PostgreSQL** é um banco de dados relacional open source, amplamente utilizado em produção. No nosso ambiente, ele é usado como banco de dados integrado ao Apache Hop para armazenar e processar dados.

O **pgAdmin** é a interface gráfica oficial para gerenciar bancos PostgreSQL via navegador.

---

## 2. Subir o PostgreSQL e pgAdmin

Abra o **PowerShell**, navegue até a pasta do projeto e execute:

```powershell
cd C:\projetos\apache-hop
docker compose up -d postgres pgadmin
```

Verifique se os containers estão rodando:

```powershell
docker ps
```

Saída esperada:

```
NAMES                STATUS    PORTS
project-apache-hop   Up        0.0.0.0:5432->5432/tcp
pgadmin              Up        0.0.0.0:5050->80/tcp
```

Você também pode visualizar os containers rodando na interface do **Docker Desktop**.

---

## 3. Acessar o pgAdmin

1. Abra o navegador em **http://localhost:5050**
2. Faça login com:
   - Email: `admin@admin.com`
   - Senha: `admin`

---

## 4. Registrar o servidor PostgreSQL no pgAdmin

1. No painel esquerdo, clique com o botão direito em **Servers** → **Register** → **Server**
2. Na aba **General**, defina o nome: `Apache Hop DB`
3. Na aba **Connection**, preencha:

| Campo | Valor |
|---|---|
| Host name/address | `postgres` |
| Port | `5432` |
| Maintenance database | `hopdb` |
| Username | `hopuser` |
| Password | `hopsenha` |

4. Marque **Save password**
5. Clique em **Save**

> O host é `postgres` (nome do serviço no docker-compose), **não** `localhost`.

---

## 5. Criar tabela pelo pgAdmin

1. No painel esquerdo, expanda: **Apache Hop DB** → **Databases** → **hopdb** → **Schemas** → **public**
2. Clique com o botão direito em **Tables** → **Create** → **Table**
3. Defina o nome e as colunas desejadas
4. Clique em **Save**

---

## 6. Executar SQL pelo pgAdmin

1. Selecione o banco `hopdb` no painel esquerdo
2. Clique em **Tools** → **Query Tool**
3. Digite e execute o SQL:

```sql
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100),
    criado_em TIMESTAMP DEFAULT NOW()
);

INSERT INTO clientes (nome, email) VALUES
    ('Ana Silva', 'ana@email.com'),
    ('Bruno Costa', 'bruno@email.com');

SELECT * FROM clientes;
```

Execute com **F5** ou o botão **Run**.

---

## 7. Carregar as tabelas do projeto

O projeto possui três tabelas na pasta `Base de dados/`. Execute-as na ordem abaixo pelo Query Tool:

1. `tabela-vendedor.sql` — cria e popula a tabela `Vendedor`
2. `tabela-produto.sql` — cria e popula a tabela `Produtos`
3. `tabela-vendas.sql` — cria e popula a tabela `Vendas` (depende das duas anteriores)

Estrutura das tabelas:

```sql
Vendedor (ID_Vendedor, Nome, Equipe, Regiao, Meta_Mensal)
Produtos (ID_Produto, Nome_Produto, Categoria, Preco_Unitario, Estoque)
Vendas   (ID_Venda, Data, ID_Vendedor FK, ID_Produto FK, Quantidade, Total)
```

---

## 8. Acessar o PostgreSQL pelo terminal (psql)

Abra o PowerShell e acesse o banco diretamente pelo container:

```powershell
docker exec -it project-apache-hop psql -U hopuser -d hopdb
```

Comandos úteis dentro do psql:

```sql
\l          -- listar bancos de dados
\dt         -- listar tabelas
\d vendas   -- descrever estrutura da tabela
\q          -- sair
```

---

## 9. Conectar o Apache Hop ao PostgreSQL

1. Abra o Apache Hop em **http://localhost:8080/ui**
2. Crie ou abra um pipeline
3. Acesse **File → New → Database connection** ou clique em **New** dentro de um step que exige conexão
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

## 10. Verificar logs do PostgreSQL

```powershell
docker logs project-apache-hop
docker logs project-apache-hop -f   # acompanhar em tempo real
```

Você também pode ver os logs pelo **Docker Desktop**: clique no container `project-apache-hop` → aba **Logs**.

---

## 11. Parar os serviços

```powershell
docker compose down
```

Os dados do banco são persistidos no volume `postgres_data`. Para apagar tudo:

```powershell
docker compose down -v
```

---

## Erros comuns

### `FATAL: password authentication failed for user "hopuser"`

Verifique se as credenciais no `docker-compose.yml` estão corretas. Se alterou as credenciais após o primeiro `up`, remova o volume e suba novamente:

```powershell
docker compose down -v
docker compose up -d
```

### `could not connect to server: Connection refused`

O container do PostgreSQL ainda está iniciando. Aguarde alguns segundos e tente novamente.

### pgAdmin não carrega a árvore de objetos

Clique com o botão direito no servidor → **Disconnect Server** → **Connect Server** novamente.

### Hop retorna erro "Please give this database connection a name"

O campo **Connection name** no topo do formulário de conexão está vazio. Preencha com um nome qualquer, ex: `postgres-hopdb`.

### Docker Desktop mostra o container como `Exited`

Verifique os logs pelo Docker Desktop ou pelo PowerShell:

```powershell
docker logs project-apache-hop
```

Geralmente indica problema de permissão no volume ou porta já ocupada.

### Porta 5432 já em uso

Se você tiver PostgreSQL instalado nativamente no Windows, ele pode estar usando a mesma porta. Pare o serviço:

1. Abra **Serviços** (`Win + R` → `services.msc`)
2. Encontre **postgresql-x64-XX**
3. Clique em **Parar**

---

## Conclusão

Ao final deste guia você saberá:

- Subir o PostgreSQL e pgAdmin via Docker Desktop no Windows
- Registrar e navegar pelo banco no pgAdmin
- Criar tabelas e executar SQL
- Carregar as tabelas do projeto (Vendedor, Produtos, Vendas)
- Acessar o banco pelo terminal com psql
- Conectar o Apache Hop ao PostgreSQL
