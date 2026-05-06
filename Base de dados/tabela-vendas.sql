CREATE TABLE Vendas (
    ID_Venda INT PRIMARY KEY,
    Data DATE,
    ID_Vendedor VARCHAR(10),
    ID_Produto VARCHAR(10),
    Quantidade INT,
    Total DECIMAL(10, 2),
    FOREIGN KEY (ID_Vendedor) REFERENCES Vendedor(ID_Vendedor),
    FOREIGN KEY (ID_Produto) REFERENCES Produtos(ID_Produto)
);

INSERT INTO Vendas (ID_Venda, Data, ID_Vendedor, ID_Produto, Quantidade, Total) VALUES
(1001, '2024-01-01', 'V01', 'P001', 2, 5998.00),
(1002, '2024-01-01', 'V02', 'P002', 1, 7500.00),
(1003, '2024-01-02', 'V03', 'P003', 1, 1200.00),
(1004, '2024-01-02', 'V04', 'P004', 5, 4000.00),
(1005, '2024-01-03', 'V05', 'P005', 2, 700.00);
-- ... (repetir para as 100 vendas conforme a planilha de Vendas[cite: 1])