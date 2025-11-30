-- Créer la table des livres
CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    published_year INT
);

-- Insérer quelques livres par défaut pour le test
INSERT INTO books (title, author, published_year) VALUES ('La Peste', 'Albert Camus', 1947);
INSERT INTO books (title, author, published_year) VALUES ('1984', 'George Orwell', 1949);
INSERT INTO books (title, author, published_year) VALUES ('Le Petit Prince', 'Antoine de Saint-Exupéry', 1943);