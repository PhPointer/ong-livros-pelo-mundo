CREATE TABLE livros (
  id_livros SERIAL PRIMARY KEY,
  nome_livro VARCHAR(100) NOT NULL
);
  
CREATE TABLE autores (
  id_autor SERIAL PRIMARY KEY,
  nome_autor VARCHAR(255) NOT NULL
);
    
CREATE TABLE editoras (
  id_editora SERIAL PRIMARY KEY,
  nome_editora VARCHAR(255) NOT NULL
);
      
CREATE TABLE acervo (
  id_acervo SERIAL PRIMARY KEY,
  nome_livro INT NOT NULL,
  nome_autor INT NOT NULL,
  nome_editora INT NOT NULL,
  FOREIGN KEY (nome_livro) REFERENCES livros(id_livros),
  FOREIGN KEY (nome_autor) REFERENCES autores(id_autor),
  FOREIGN KEY (nome_editora) REFERENCES editoras(id_editora)
);
      
CREATE TABLE cidade_estado(
  id_CiEs SERIAL PRIMARY KEY,
  Cidade varchar (255) not null,
  Estado varchar (255) not null,
  Rua varchar (255) not null
);
     
CREATE TABLE cursos(
  id_curso SERIAL PRIMARY KEY,
  endereco int NOT NULL,
  tipoCurso varchar (255),
  nomeCurso varchar (255) NOT NULL,
  FOREIGN KEY (endereco) REFERENCES cidade_estado(id_CiEs)
);
       
CREATE TABLE doados(
  id_doado SERIAL PRIMARY KEY,
  dataDoado date not null,
  livroDoado int NOT NULL,
  cursoDestino int not null,
  FOREIGN KEY (livroDoado) REFERENCES acervo(id_acervo),
  FOREIGN KEY (cursoDestino) REFERENCES cursos(id_curso)
);
         
CREATE TABLE arrecadados(
  id_arreca SERIAL PRIMARY KEY,
  livroArreca int not null,
  dataArreca date not null,
  FOREIGN KEY (livroArreca) REFERENCES acervo(id_acervo)
);

CREATE TABLE usuarios (
  id_usuario SERIAL PRIMARY KEY,
  nome_usuario varchar (255) NOT NULL,
  tipo_usuario varchar (255) NOT NULL CHECK(tipo_usuario IN ('adm', 'desenvolvedorSenior', 'estagiario', 'usuario'))
);

-- Criando a Função para obter id da Editora.

CREATE OR REPLACE FUNCTION OBTER_ID_EDITORA(EDITORA TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	IF VALIDAR_STRING(EDITORA) THEN
		SELECT ID_EDITORA 
		INTO COD 
		FROM EDITORAS 
		WHERE LOWER(NOME_EDITORA) = LOWER(EDITORA);
		IF COD IS NOT NULL THEN
			RETURN COD;
		ELSE
			RETURN 0;
		END IF;
	ELSE
		RAISE NOTICE 'ERRO: NOME DE EDITORA INVALIDO!';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql; 

SELECT OBTER_ID_EDITORA('');
SELECT OBTER_ID_EDITORA(NULL);
SELECT OBTER_ID_EDITORA('SADAADAD');
SELECT OBTER_ID_EDITORA('ÁTICA');
SELECT OBTER_ID_EDITORA('NOVA AGUILAR');
SELECT * FROM EDITORAS;

-- **********************Testes da Função ******************************

-- Criando a Função para Adicionar uma editora.

CREATE OR REPLACE FUNCTION ADD_EDITORA(NOME_EDITORA TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(NOME_EDITORA) THEN
		INSERT INTO EDITORAS(nome_editora) VALUES(NOME_EDITORA);
		RAISE NOTICE 'EDITORA INSERIDA COM SUCESSO!';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'ERRO: EDITORA NÃO INSERIDA!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ADD_EDITORA('Editora XPTO');
SELECT ADD_EDITORA('Editora XPTO2');
SELECT ADD_EDITORA('Editora XPT3');

-- **********************Testes da Função ******************************

-- Criando a Função para Validar String.
CREATE OR REPLACE FUNCTION VALIDAR_STRING(STR TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF STR IS NOT NULL AND LENGTH(TRIM(STR)) > 0 THEN 
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT VALIDAR_STRING('');
SELECT VALIDAR_STRING(NULL);
SELECT VALIDAR_STRING(' TESTE ');

-- **********************Testes da Função ******************************

-- Criando a Função para Obter id de um Endereço.
CREATE OR REPLACE FUNCTION OBTER_ID_ENDERECO(ENDERECO TEXT)
RETURNS INTEGER AS $$
DECLARE 
	COD INTEGER;
BEGIN
	IF VALIDAR_STRING(ENDERECO) THEN
	
		SELECT CE.ID_CIES INTO COD 
		FROM CIDADE_ESTADO AS CE
		WHERE LOWER(CE.RUA) = LOWER(ENDERECO);
		
		IF COD IS NOT NULL THEN
			RETURN COD;
		ELSE
			RETURN 0;
		END IF;
	ELSE
		RAISE NOTICE 'ENDEREÇO INVÁLIDO!';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT OBTER_ID_ENDERECO('');
SELECT OBTER_ID_ENDERECO(NULL);
SELECT OBTER_ID_ENDERECO('Avenida Brasil');
SELECT OBTER_ID_ENDERECO('AVENIDA BRASIL');
SELECT OBTER_ID_ENDERECO('rua das palmeiras');

-- **********************Testes da Função ******************************

-- Criando a Função para inserir um novo Curso.
CREATE OR REPLACE FUNCTION add_curso(nome_curso text, tipo_curso text, endereco text)
RETURNS BOOLEAN AS $$

BEGIN
	IF VALIDAR_STRING(nome_curso) 
		AND VALIDAR_STRING(tipo_curso) 
		AND VALIDAR_STRING(endereco) THEN
			INSERT INTO CURSOS(ENDERECO, TIPOCURSO, NOMECURSO)
			VALUES(
				OBTER_ID_ENDERECO(endereco),
				tipo_curso,
				nome_curso
			);
		RAISE NOTICE 'CURSO INSERIDO COM SUCESSO!';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'ERRO: CURSO NÃO INSERIDO!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT add_curso('ADS', 'TECNOLOGIA', 'RUA DAS FLORES');
SELECT add_curso('ENG', 'TECNOLOGIA', 'AVENIDA BRASIL');
SELECT add_curso('LING. ESTRANGEIRA', 'LETRAS', 'RUA DA ALEGRIA');
SELECT * FROM CURSOS;

-- **********************Testes da Função ******************************

-- Criando a Função para inserir um novo livro
CREATE OR REPLACE FUNCTION INSERIR_LIVRO(NOME TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(NOME) THEN
	  INSERT INTO LIVROS(NOME_LIVRO) VALUES(NOME);
		RAISE NOTICE 'LIVRO INSERIDO COM SUCESSO';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'LIVRO NÃO INSERIDO, NOME VAZIO!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT INSERIR_LIVRO('TESTE');
SELECT INSERIR_LIVRO('');
SELECT INSERIR_LIVRO(NULL);
SELECT * FROM LIVROS;

-- **********************Testes da Função ******************************

-- Criando a Função para gerar datas aleatórias para os livros doados
CREATE OR REPLACE FUNCTION random_date_between(start_date DATE, end_date DATE) RETURNS DATE AS $$
DECLARE
    random_days INTEGER;
    random_date DATE;
BEGIN
    -- Calcula o número de dias entre as datas de início e fim
    random_days := random() * (end_date - start_date + 1);

    -- Adiciona um número aleatório de dias à data de início
    random_date := start_date + random_days;

    -- Retorna a data aleatória
    RETURN random_date;
END;
$$ LANGUAGE plpgsql;

-- Criando a Função para gerar datas aleatórias para os livros arrecadados
CREATE OR REPLACE FUNCTION random_date_within_range(start_date DATE, end_date DATE)
RETURNS DATE AS $$
DECLARE
    random_days INTERVAL;
BEGIN
    random_days := (FLOOR(RANDOM() * 60) || ' days')::INTERVAL; -- Gera um intervalo aleatório de até 60 dias
    RETURN start_date + random_days;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION checa_se_livro_ja_foi_doado()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM doados WHERE livroDoado = NEW.livroDoado) THEN
        RAISE EXCEPTION 'Livro já foi doado. Inserção não permitida.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER gatilho_checa_se_livro_ja_foi_doado
BEFORE INSERT ON doados
FOR EACH ROW
EXECUTE FUNCTION checa_se_livro_ja_foi_doado();



CREATE VIEW VeIDdoLivroAutorEditora AS
SELECT
    p.id_livros AS ID_Livro,
    p.nome_livro AS Produto,
    a1.id_autor AS ID_Autor,
    a1.nome_autor AS Autor,
    e.id_editora AS ID_Editora,
    e.nome_editora AS Editora,
    ce.id_CiEs AS ID_Endereco,
    ce.Cidade AS Cidade,
    ce.Estado AS Estado,
    c.nomeCurso AS NomeCurso
FROM
    livros p
LEFT JOIN
    autores a1 ON p.id_livros = a1.id_autor
LEFT JOIN
    editoras e ON p.id_livros = e.id_editora
LEFT JOIN
    cidade_estado ce ON p.id_livros = ce.id_CiEs
LEFT JOIN
    cursos c ON ce.id_CiEs = c.endereco;
	
SELECT * FROM VeIDdoLivroAutorEditora;

-- Inserindo dados nas tabelas
INSERT INTO livros (nome_livro) VALUES ('O Alquimista');
INSERT INTO autores (nome_autor) VALUES ('Paulo Coelho');
INSERT INTO editoras (nome_editora) VALUES ('HarperCollins');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (1, 1, 1);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('São Paulo', 'SP', 'Rua das Flores');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (1, 'Literatura', 'Curso de Literatura da UNICAMP');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 1, 1);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (1, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Os Sertões');
INSERT INTO autores (nome_autor) VALUES ('Euclides da Cunha');
INSERT INTO editoras (nome_editora) VALUES ('Francisco Alves');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (2, 2, 2);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Rio de Janeiro', 'RJ', 'Avenida Brasil');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (2, 'História', 'Curso de História da USP');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 2, 2);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (2, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('O Cortiço');
INSERT INTO autores (nome_autor) VALUES ('Aluíso de Azevedo');
INSERT INTO editoras (nome_editora) VALUES ('Martin Claret');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (3, 3, 3);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Rio de Janeiro', 'RJ', 'Avenida Copacabana');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (3, 'Literatura', 'Curso de Literatura da UNESP');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 3, 3);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (3, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Capitães de Areia');
INSERT INTO autores (nome_autor) VALUES ('Jorge Amado');
INSERT INTO editoras (nome_editora) VALUES ('Companhia Editora Nacional');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (4, 4, 4);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Salvador', 'BA', 'Rua da Alegria');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (4, 'Literatura', 'Curso de Literatura da UFBA');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 4, 4);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (4, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Iracema');
INSERT INTO autores (nome_autor) VALUES ('José de Alencar');
INSERT INTO editoras (nome_editora) VALUES ('Ática');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (5, 5, 5);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Fortaleza', 'CE', 'Avenida Beira Mar');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (5, 'Literatura', 'Curso de Literatura da UFC');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 5, 5);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (5, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Dom Casmurro');
INSERT INTO autores (nome_autor) VALUES ('Machado de Assis');
INSERT INTO editoras (nome_editora) VALUES ('Nova Aguilar');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (6, 6, 6);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Rio de Janeiro', 'RJ', 'Rua das Palmeiras');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (6, 'Literatura', 'Curso de Literatura da UFRJ');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 6, 6);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (6, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Morte e Vida Severina');
INSERT INTO autores (nome_autor) VALUES ('João Cabral de Melo Neto');
INSERT INTO editoras (nome_editora) VALUES ('osé Olympio Editora');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (7, 7, 7);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Recife', 'PE', 'Avenida Boa Viagem');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (7, 'Literatura', 'Curso de Literatura da UFPE');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 7, 7);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (7, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Vidas Secas');
INSERT INTO autores (nome_autor) VALUES ('Graciliano Ramos');
INSERT INTO editoras (nome_editora) VALUES ('Record');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (8, 8, 8);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Palmeira dos Índios', 'AL', 'Avenida Getúlio Vargas');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (8, 'Literatura', 'Curso de Literatura da UFAL');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 8, 8);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (8, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('A Hora da Estrela');
INSERT INTO autores (nome_autor) VALUES ('Clarice Lispector');
INSERT INTO editoras (nome_editora) VALUES ('Editora Francisco Alves');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (9, 9, 9);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Rio de Janeiro', 'RJ', 'Avenida Atlântica');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (9, 'Literatura', 'Curso de Literatura da UFRJ');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 9,9);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (9, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Memórias Póstumas de Brás Cubas');
INSERT INTO autores (nome_autor) VALUES ('Machado de Assis');
INSERT INTO editoras (nome_editora) VALUES ('Garnier');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (10, 10, 10);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Rio de Janeiro', 'RJ', 'Rua das Laranjeiras');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (10, 'Literatura', 'Curso de Literatura da UFF');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 10, 10);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (10, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('O Auto da Compadecida');
INSERT INTO autores (nome_autor) VALUES ('Ariano Suassuna');
INSERT INTO editoras (nome_editora) VALUES ('Editora José Olympio');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (11, 11, 11);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Recife', 'PE', 'Rua do Príncipe');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (11, 'Literatura', 'Curso de Literatura da UFPE');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 11, 11);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (11, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('O Guarani');
INSERT INTO autores (nome_autor) VALUES ('José de Alencar');
INSERT INTO editoras (nome_editora) VALUES ('Editora Globo');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (12, 12, 12);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Fortaleza', 'CE', 'Avenida Beira-Mar');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (12, 'Literatura', 'Curso de Literatura da UFC');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 12, 12);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (12, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Terra Sonâmbula');
INSERT INTO autores (nome_autor) VALUES ('Mia Couto');
INSERT INTO editoras (nome_editora) VALUES ('Companhia das Letras');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (13, 13, 13);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Maputo', 'AC', 'Avenida Eduardo Mondlane');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (13, 'Literatura', 'Curso de Literatura da Universidade Eduardo Mondlane');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 13, 13);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (13, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('O Mulato');
INSERT INTO autores (nome_autor) VALUES ('Aluísio Azevedo');
INSERT INTO editoras (nome_editora) VALUES ('Martin Claret');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (14, 14, 14);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('São Luís', 'MA', 'Avenida Litorânea');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (14, 'Literatura', 'Curso de Literatura da UFMA');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 14, 14);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (14, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Gabriela, Cravo e Canela');
INSERT INTO autores (nome_autor) VALUES ('Jorge Amado');
INSERT INTO editoras (nome_editora) VALUES ('Record');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (15, 15, 15);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Ilhéus', 'BA', 'Avenida Dois de Julho');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (15, 'Literatura', 'Curso de Literatura da UFBA');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 15, 15);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (15, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Claro Enigma');
INSERT INTO autores (nome_autor) VALUES ('Carlos Drummond de Andrade');
INSERT INTO editoras (nome_editora) VALUES ('Companhia das Letras');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (16, 16, 16);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Belo Horizonte', 'MG', 'Avenida Afonso Pena');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (16, 'Literatura', 'Curso de Literatura da UFMG');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 16, 16);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (16, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('O Vendedor de Passados');
INSERT INTO autores (nome_autor) VALUES ('José Eduardo Agualusa');
INSERT INTO editoras (nome_editora) VALUES ('Companhia das Letras');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (17, 17, 17);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Luanda', 'MT', 'Avenida Marginal');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (17, 'Literatura', 'Curso de Literatura da Universidade de Luanda');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 17, 17);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (17, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Mayombe');
INSERT INTO autores (nome_autor) VALUES ('Pepetela');
INSERT INTO editoras (nome_editora) VALUES ('Civilização Brasileira');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (18, 18, 18);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Luanda', 'RO', 'Rua das Acácias');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (18, 'Literatura', 'Curso de Literatura da Universidade Agostinho Neto');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 18, 18);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (18, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));

-- Inserindo dados nas tabela
INSERT INTO livros (nome_livro) VALUES ('Lucíola');
INSERT INTO autores (nome_autor) VALUES ('José de Alencar');
INSERT INTO editoras (nome_editora) VALUES ('Garnier');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (19, 19, 19);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('Fortaleza', 'CE', 'Rua do Parque');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (19, 'Literatura', 'Curso de Literatura da UFC');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 19, 19);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (19, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));


-- Exemplo para dar Errado e , assim, acionando o Trigger
INSERT INTO livros (nome_livro) VALUES ('O Alquimista');
INSERT INTO autores (nome_autor) VALUES ('Paulo Coelho');
INSERT INTO editoras (nome_editora) VALUES ('HarperCollins');
INSERT INTO acervo (nome_livro, nome_autor, nome_editora) VALUES (1, 1, 1);
INSERT INTO cidade_estado (Cidade, Estado, Rua) VALUES ('São Paulo', 'SP', 'Rua das Flores');
INSERT INTO cursos (endereco, tipoCurso, nomeCurso) VALUES (1, 'Literatura', 'Curso de Literatura da UNICAMP');
INSERT INTO doados (dataDoado, livroDoado, cursoDestino) VALUES (random_date_between(DATE '1994-07-05', DATE '2024-12-31'), 1, 1);
INSERT INTO arrecadados (livroArreca, dataArreca) VALUES (1, random_date_within_range(DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1)), DATE((SELECT dataDoado FROM doados ORDER BY id_doado DESC LIMIT 1) + INTERVAL '2 months')));



-- Criando nova view para mostra endereço atualizado
CREATE VIEW endereco_enviado AS
SELECT 
    doados.dataDoado, 
    arrecadados.dataArreca, 
    cursos.nomeCurso, 
    cidade_estado.Cidade, 
    cidade_estado.Estado, 
    cidade_estado.Rua
FROM 
    doados
JOIN 
    arrecadados ON doados.id_doado = arrecadados.id_arreca
JOIN 
    cursos ON doados.cursoDestino = cursos.id_curso
JOIN 
    cidade_estado ON cursos.endereco = cidade_estado.id_CiEs;

-- Consultando a View 'endereco_enviado'
SELECT * FROM endereco_enviado;


-- Stored Procedure 01: Atualizará os dados na tabela cidade_estado.
CREATE OR REPLACE PROCEDURE atualizar_endereco_curso(
    IN curso_id INT,
    IN nova_cidade VARCHAR(255),
    IN novo_estado CHAR(2),
    IN nova_rua VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE cidade_estado
    SET Cidade = nova_cidade, Estado = novo_estado, Rua = nova_rua
    WHERE id_CiEs = curso_id;
END;
$$;

CALL atualizar_endereco_curso(18, 'Luanda', 'LU', 'Rua das Salve Jorge');

-- Verificand se Stored Procedure 01 funcionou
SELECT Cidade, Estado, Rua
FROM cidade_estado
WHERE id_CiEs = 18;



-- Stored Procedure 02: Gerará um relatório com informações sobre as doações, considerando um período de datas.
CREATE OR REPLACE PROCEDURE relatorio_doacoes(
    IN data_inicial DATE,
    IN data_final DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_doacoes INT;
BEGIN
    SELECT COUNT(*) INTO total_doacoes
    FROM doados
    WHERE dataDoado BETWEEN data_inicial AND data_final;

    RAISE NOTICE 'Total de doações no período: %', total_doacoes;
END;
$$;

-- Verificand se Stored Procedure 02 funcionou
CALL relatorio_doacoes(DATE '2013-01-01', DATE '2024-12-31');



--Subconsulta 01: Recupera o nome dos autores e o nome dos livros que estão associados a eles no acervo, mas apenas para os autores que têm pelo menos dois livros no acervo
SELECT a.nome_autor, l.nome_livro
FROM autores a
JOIN acervo ac ON a.id_autor = ac.nome_autor
JOIN livros l ON ac.nome_livro = l.id_livros
WHERE a.id_autor IN (
  SELECT nome_autor
  FROM acervo
  GROUP BY nome_autor
  HAVING COUNT(*) >= 2
);


-- Subconsulta 02: Obtenha os nomes de todos os livros que foram doados e arrecadados
SELECT l.nome_livro 
FROM livros l 
JOIN acervo a ON l.id_livros = a.nome_livro 
WHERE a.id_acervo IN (
  SELECT livroDoado FROM doados 
  UNION 
  SELECT livroArreca FROM arrecadados
);

-- Subconsulta 03: Obtenha os nomes de todos os cursos que receberam doação de livros 
SELECT c.nomeCurso 
FROM cursos c 
JOIN doados d ON c.id_curso = d.cursoDestino;


-- Subconsulta 04: Obtenha os nomes de todos os autores que escreveram um livro que foi doado e arrecadados
SELECT a.nome_autor 
FROM autores a 
JOIN acervo ac ON a.id_autor = ac.nome_autor 
JOIN livros l ON l.id_livros = ac.nome_livro 
WHERE ac.id_acervo IN (
  SELECT livroDoado FROM doados 
  INTERSECT 
  SELECT livroArreca FROM arrecadados
);
