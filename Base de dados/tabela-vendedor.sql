CREATE TABLE Vendedor (
    ID_Vendedor VARCHAR(10) PRIMARY KEY,
    Nome VARCHAR(100),
    Equipe VARCHAR(50),
    Regiao VARCHAR(50),
    Meta_Mensal DECIMAL(10, 2)
);

INSERT INTO Vendedor (ID_Vendedor, Nome, Equipe, Regiao, Meta_Mensal) VALUES
('V01', 'Ana Silva', 'Alpha', 'Sul', 50000.00),
('V02', 'Bruno Costa', 'Alpha', 'Sul', 50000.00),
('V03', 'Carla Souza', 'Beta', 'Norte', 45000.00),
('V04', 'Diego Lima', 'Beta', 'Norte', 45000.00),
('V05', 'Elena Santos', 'Gama', 'Leste', 48000.00);
-- ... (repetir para os 100 vendedores conforme a planilha de Vendedor[cite: 3])