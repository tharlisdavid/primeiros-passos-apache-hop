CREATE TABLE Produtos (
    ID_Produto VARCHAR(10) PRIMARY KEY,
    Nome_Produto VARCHAR(100),
    Categoria VARCHAR(50),
    Preco_Unitario DECIMAL(10, 2),
    Estoque INT
);

INSERT INTO Produtos (ID_Produto, Nome_Produto, Categoria, Preco_Unitario, Estoque) VALUES
('P001', 'Smartphone Galaxy S21', 'Eletrônicos', 2999.00, 50),
('P002', 'Laptop Dell XPS 13', 'Informática', 7500.00, 20),
('P003', 'Monitor LG 27 Pol', 'Informática', 1200.00, 30),
('P004', 'Fone de Ouvido Sony', 'Acessórios', 800.00, 100),
('P005', 'Teclado Mecânico RGB', 'Periféricos', 350.00, 45);
-- ... (repetir para os 100 itens conforme a planilha de Produtos[cite: 2])