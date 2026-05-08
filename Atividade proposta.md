## Atividade: Construção de Tabela Fato no Apache Hop

### 0. Pré-requisito: Conexão (Relational Database Connection)

Antes de iniciar a Pipeline, crie a conexão com o PostgreSQL:

* **Hostname:** Use o nome do serviço definido no seu `docker-compose` (ex: `db` ou `postgres`) ou o IP da rede Docker. Evite `localhost` se o Hop e o PG estiverem em containers separados.
* **Database/Username/Password:** Conforme configurado no seu pgAdmin.

---

### 1. Extração: Table Input (x3)

Você criará três transforms de **Table Input** para ler as tabelas de origem.

* **Configuração:** Selecione a conexão criada e utilize `SELECT * FROM nome_da_tabela`.
* **Importante:** No Apache Hop, para o *Merge Join* funcionar corretamente, os dados **precisam estar ordenados** pela chave de junção.
* No SQL do Table Input de **Vendas**, use: `ORDER BY id_produto, id_vendedor`.
* No de **Produto**, use: `ORDER BY id_produto`.
* No de **Vendedor**, use: `ORDER BY id_vendedor`.



### 2. Ordenação: Sort Rows (Opcional, mas recomendado)

Se você não ordenou via SQL no passo anterior, arraste o transform **Sort Rows** após cada Table Input.

* Ordene pelos IDs que serão usados no Join. O *Merge Join* falhará ou trará dados errados se os fluxos não estiverem ordenados.

### 3. Integração: Merge Join (x2)

O Hop une apenas duas fontes por vez.

* **Join 1 (Vendas + Produto):**
* First Transform: `Vendas` | Second Transform: `Produto`.
* Join Type: `INNER`.
* Key Fields: `id_produto` em ambos os lados.


* **Join 2 (Resultado anterior + Vendedor):**
* First Transform: `Merge Join 1` | Second Transform: `Vendedor`.
* Join Type: `INNER`.
* Key Fields: `id_vendedor` em ambos os lados.



### 4. Transformação: Calculator

Aqui criamos a métrica da nossa fato.

* **Nova Coluna:** `valor_total`.
* **Calculation:** Escolha `A * B` (Multiplication).
* **Field A:** `quantidade`.
* **Field B:** `preco_unitario` (ou valor unitário).
* **Value Type:** `Number` ou `BigNumber`.

### 5. Saneamento: Select Values

Utilizado para organizar o "shape" final dos dados antes da carga.

* **Aba Select & Alter:** Renomeie colunas para um padrão amigável (ex: de `nome_vend` para `vendedor_nome`).
* **Aba Remove:** Exclua os IDs repetidos que vieram das tabelas de dimensão (mantenha apenas os da tabela de vendas) e colunas temporárias.
* **Aba Meta-data:** Altere o formato da data da venda para `yyyy-MM-dd` e garanta que o `valor_total` esteja como `Number`.

### 6. Carga: Table Output

O destino final da sua tabela fato.

* **Target Table:** `dw_vendas`.
* **Opções:** Marque **Truncate table** se desejar limpar a tabela antes de cada nova carga.
* **Specify database fields:** Mapeie os campos que saíram do *Select Values* para as colunas da tabela de destino no PostgreSQL.

---

### Dica para ambiente Docker:

Certifique-se de que o driver JDBC do PostgreSQL (`.jar`) está na pasta `/hop/lib/jdbc` dentro do seu container do Apache Hop, caso contrário a conexão com o banco não será estabelecida.
