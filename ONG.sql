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
  FOREIGN KEY (nome_livro) REFERENCES livros(id_livros) ON DELETE CASCADE,
  FOREIGN KEY (nome_autor) REFERENCES autores(id_autor) ON DELETE CASCADE,
  FOREIGN KEY (nome_editora) REFERENCES editoras(id_editora) ON DELETE CASCADE
);

CREATE TABLE cidade_estado (
  id_CiEs SERIAL PRIMARY KEY,
  Cidade VARCHAR(255) NOT NULL,
  Estado VARCHAR(255) NOT NULL,
  Rua VARCHAR(255) NOT NULL
);

CREATE TABLE cursos (
  id_curso SERIAL PRIMARY KEY,
  endereco INT NOT NULL,
  tipoCurso VARCHAR(255),
  nomeCurso VARCHAR(255) NOT NULL,
  FOREIGN KEY (endereco) REFERENCES cidade_estado(id_CiEs) ON DELETE CASCADE
);

CREATE TABLE doados (
  id_doado SERIAL PRIMARY KEY,
  dataDoado DATE NOT NULL,
  livroDoado INT NOT NULL,
  cursoDestino INT NOT NULL,
  FOREIGN KEY (livroDoado) REFERENCES acervo(id_acervo) ON DELETE CASCADE,
  FOREIGN KEY (cursoDestino) REFERENCES cursos(id_curso) ON DELETE CASCADE
);

CREATE TABLE arrecadados (
  id_arreca SERIAL PRIMARY KEY,
  livroArreca INT NOT NULL,
  dataArreca DATE NOT NULL,
  FOREIGN KEY (livroArreca) REFERENCES acervo(id_acervo) ON DELETE CASCADE
);

CREATE TABLE usuarios (
  id_usuario SERIAL PRIMARY KEY,
  nome_usuario VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(255) NOT NULL CHECK(tipo_usuario IN ('adm', 'desenvolvedorSenior', 'estagiario', 'usuario'))
);

-- Criando a Função para obter id do Curso.

CREATE OR REPLACE FUNCTION GET_ID_CURSO(CURSO TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	IF VALIDAR_STRING(CURSO) THEN
	   SELECT ID_CURSO
	   INTO COD
	   FROM CURSOS
	   WHERE LOWER(NOMECURSO)  = LOWER(CURSO);
	   IF COD IS NOT NULL THEN
	   		RETURN COD;
	   ELSE
			RETURN 0;
	   END IF;
	ELSE
		RAISE NOTICE 'ERRO: VALOR INVÁLIDO!';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT GET_ID_CURSO('');
SELECT GET_ID_CURSO(NULL);
SELECT GET_ID_CURSO('DSFAFA');
SELECT GET_ID_CURSO('ENG');
SELECT GET_ID_CURSO('CURSO DE LITERATURA DA UNICAMP');
SELECT * FROM CURSOS;

-- ********************** Testes da Função ******************************

-- Criando a Função para obter id do acervo.

CREATE OR REPLACE FUNCTION GET_ID_ACERVO(ACERVO TEXT)
RETURNS INTEGER AS $$
DECLARE 
    ACERVO_ID INTEGER;
BEGIN
    IF VALIDAR_STRING(ACERVO) THEN
        SELECT a.id_acervo
        INTO ACERVO_ID
        FROM acervo a
        JOIN livros l ON a.nome_livro = l.id_livros
        WHERE LOWER(l.nome_livro) = LOWER(ACERVO);
        
        RETURN ACERVO_ID;
    ELSE
        RAISE NOTICE 'Erro: Valor inválido!';
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'Erro: Não foi possível encontrar o acervo.';
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;


SELECT GET_ID_ACERVO('');
SELECT GET_ID_ACERVO(NULL);
SELECT GET_ID_ACERVO('SDSSDFS');
SELECT GET_ID_ACERVO('O ALQUIMISTA');
SELECT GET_ID_ACERVO('O CORTIÇO')
SELECT * FROM ACERVO;
SELECT * FROM LIVROS;

-- ********************** Testes da Função ******************************

-- Criando a Função para obter ID da Doação.

CREATE OR REPLACE FUNCTION GET_ID_DOACAO(LIVRO TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	
	IF VALIDAR_STRING(LIVRO) THEN
		
		IF GET_ID_ACERVO(LIVRO) IS NOT NULL THEN

			SELECT id_doado
			INTO COD
			FROM doados
			WHERE livroDoado = GET_ID_ACERVO(LIVRO);
	
			RAISE NOTICE '';
			RETURN COD;
		ELSE 
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETRO DE ENTRADA INVÁLIDO!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT GET_ID_DOACAO('O ALQUIMISTA');
ROLLBACK;

SELECT * FROM CURSOS;
SELECT * FROM LIVROS;
SELECT * FROM DOADOS; 
-- **********************Testes da Função ******************************

-- Criando a Função para Adicionar um Usuario.

CREATE OR REPLACE FUNCTION ADD_USUARIO(NOME_USER TEXT, TYPE_USER TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(NOME_USER) AND
	   VALIDAR_STRING(TYPE_USER) AND
	   CHECK_TYPE_USER(TYPE_USER) THEN
	   	INSERT INTO USUARIOS(nome_usuario, tipo_usuario)
		VALUES(NOME_USER, TYPE_USER);
	   	RAISE NOTICE 'Usuário adicionado com sucesso.';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'Falha ao adicionar usuário: valores inválidos.';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ADD_USUARIO('', '');
SELECT ADD_USUARIO(NULL,NULL);
SELECT ADD_USUARIO('', 'ASDADAD');
SELECT ADD_USUARIO('EDINEI', '');
SELECT ADD_USUARIO('EDINEI', 'ASAASAAC');
SELECT ADD_USUARIO('EDINEI',NULL);
SELECT ADD_USUARIO('', 'estagiario');
SELECT ADD_USUARIO(NULL, 'estagiario');
SELECT ADD_USUARIO('EDINEI', 'estagiario');
SELECT * FROM USUARIOS;

-- **********************Testes da Função ******************************

-- Criando a Função para verificar tipo de usuario.

CREATE OR REPLACE FUNCTION CHECK_TYPE_USER(USER_TYPE TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(USER_TYPE)THEN
		RETURN LOWER(USER_TYPE) IN(LOWER('adm'), 
							LOWER('desenvolvedorSenior'), 
							LOWER('estagiario'), 
							LOWER('usuario'));
	ELSE
		RAISE NOTICE 'ERRO: VALOR INVÁLIDO!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT CHECK_TYPE_USER('');
SELECT CHECK_TYPE_USER(NULL);
SELECT CHECK_TYPE_USER('SDCSCS');
SELECT CHECK_TYPE_USER('adm');
SELECT CHECK_TYPE_USER('usuario');
SELECT CHECK_TYPE_USER('estagiario');
SELECT CHECK_TYPE_USER('desenvolvedorSenior');
SELECT CHECK_TYPE_USER('desenvolvedorSeniorA');

-- **********************Testes da Função ******************************

-- Criando Função para Adicionar um novo Endereço.

CREATE OR REPLACE FUNCTION ADD_ENDERECO(cidade TEXT, estado TEXT, rua TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(cidade) AND
	   VALIDAR_STRING(estado) AND
	   VALIDAR_STRING(rua) THEN
	   INSERT INTO CIDADE_ESTADO(Cidade,Estado,Rua)
	   VALUES(cidade,estado,rua);
	   RAISE NOTICE 'ENDEREÇO ADICIONADO COM SUCESSO!';
	   RETURN TRUE;
	ELSE
		RAISE NOTICE 'ERRO: FALHA AO ADICIONAR ENDEREÇO!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ADD_ENDERECO('','','');
SELECT ADD_ENDERECO(NULL,NULL,NULL);
SELECT ADD_ENDERECO('TESTE CIDADE','TESTE ESTADO','');
SELECT ADD_ENDERECO('TESTE CIDADE','','TESTE RUA');
SELECT ADD_ENDERECO('','TESTE ESTADO','TESTE RUA');
SELECT ADD_ENDERECO('TESTE CIDADE','TESTE ESTADO','TESTE RUA');
SELECT * FROM CIDADE_ESTADO;

-- ********************** Testes da Função ******************************

-- Criando a Função para inserir Acervo.

CREATE OR REPLACE FUNCTION ADD_ACERVO(livro TEXT, autor TEXT, editora TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	if VALIDAR_STRING(livro) AND
	   VALIDAR_STRING(autor) AND
	   VALIDAR_STRING(editora) THEN
	   	INSERT INTO ACERVO(nome_livro, nome_autor, nome_editora)
		VALUES(GET_ID_LIVRO(livro), 
			   GET_ID_AUTOR(autor), 
			   GET_ID_EDITORA(editora));
		RAISE NOTICE 'ACERVO INSERIDO COM SUCESSO!';	   
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'ERRO: ACERVO NÃO INSERIDO!';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ADD_ACERVO('', '', '');
SELECT ADD_ACERVO('SCAACA', 'AASDASD', '');
SELECT ADD_ACERVO('ASDADDA', '', 'ADADAD');
SELECT ADD_ACERVO('', 'ADCACA', 'ACACA');
SELECT ADD_ACERVO('IRACEMA', 'PAULO COELHO', 'ÁTICA');
SELECT * FROM ACERVO;

-- **********************Testes da Função ******************************

-- Criando a Função para adicionar um Autor;

CREATE OR REPLACE FUNCTION ADD_AUTOR(nome TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(nome) THEN
		INSERT INTO AUTORES(NOME_AUTOR)
		VALUES (nome);
		RAISE NOTICE 'AUTOR INSERIDO COM SUCESSO!';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'ERRO: NOME INVÁLIDO';
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ADD_AUTOR('');
SELECT ADD_AUTOR(NULL);
SELECT ADD_AUTOR('TESTE');
SELECT * FROM AUTORES;

-- **********************Testes da Função ******************************

-- Criando a Função para obter id do Autor;

CREATE OR REPLACE FUNCTION GET_ID_AUTOR(AUTOR TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	IF VALIDAR_STRING(AUTOR) THEN
		SELECT ID_AUTOR
		INTO COD 
		FROM AUTORES
		WHERE LOWER(NOME_AUTOR) = LOWER(AUTOR) ;
		IF COD IS NOT NULL THEN
			RETURN COD;
		ELSE
			RETURN 0;
		END IF;
	ELSE
		RAISE NOTICE 'ERRO: NOME DO AUTOR INVÁLIDO!';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT GET_ID_AUTOR('');
SELECT GET_ID_AUTOR(NULL);
SELECT GET_ID_AUTOR('SDSDSDF');
SELECT GET_ID_AUTOR('PAULO COELHO');
SELECT GET_ID_AUTOR('JORGE AMADO');
SELECT * FROM AUTORES;

-- **********************Testes da Função ******************************

-- Criando a Função para obter id do livro;

CREATE OR REPLACE FUNCTION GET_ID_LIVRO(LIVRO TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	IF VALIDAR_STRING(LIVRO) THEN
		SELECT ID_LIVROS 
		INTO COD 
		FROM LIVROS
		WHERE LOWER(NOME_LIVRO) = LOWER(LIVRO) ;
		IF COD IS NOT NULL THEN
			RETURN COD;
		ELSE
			RETURN 0;
		END IF;
	ELSE
		RAISE NOTICE 'ERRO: NOME DO LIVRO INVÁLIDO!';
		RETURN 0;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT GET_ID_LIVRO('');
SELECT GET_ID_LIVRO(NULL);
SELECT GET_ID_LIVRO('ASASDAD');
SELECT GET_ID_LIVRO('TESTE');
SELECT GET_ID_LIVRO('IRACEMA');
SELECT * FROM LIVROS;

-- **********************Testes da Função ******************************

-- Criando a Função para obter id da Editora.

CREATE OR REPLACE FUNCTION GET_ID_EDITORA(EDITORA TEXT)
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

SELECT GET_ID_EDITORA('');
SELECT GET_ID_EDITORA(NULL);
SELECT GET_ID_EDITORA('SADAADAD');
SELECT GET_ID_EDITORA('ÁTICA');
SELECT GET_ID_EDITORA('NOVA AGUILAR');
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
CREATE OR REPLACE FUNCTION GET_ID_ENDERECO(ENDERECO TEXT)
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

SELECT GET_ID_ENDERECO('');
SELECT GET_ID_ENDERECO(NULL);
SELECT GET_ID_ENDERECO('Avenida Brasil');
SELECT GET_ID_ENDERECO('AVENIDA BRASIL');
SELECT GET_ID_ENDERECO('rua das palmeiras');

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
CREATE OR REPLACE FUNCTION ADD_LIVRO(NOME TEXT)
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

SELECT ADD_LIVRO('TESTE');
SELECT ADD_LIVRO('');
SELECT ADD_LIVRO(NULL);
SELECT * FROM LIVROS;

-- **********************Testes da Função ******************************

-- Criando a Função para obter id do Usuário.

CREATE OR REPLACE FUNCTION GET_ID_USUARIO(USUARIO TEXT)
RETURNS INTEGER AS $$
DECLARE ID_USER INTEGER;
BEGIN
	IF VALIDAR_STRING(USUARIO) THEN
	
		SELECT ID_USUARIO 
		INTO ID_USER
		FROM  USUARIOS
		WHERE NOME_USUARIO = USUARIO;

		IF FOUND THEN
			RAISE NOTICE 'USUARIO ENCONTRADO!';
			RETURN ID_USER;
		ELSE
			RAISE EXCEPTION 'USUARIO NÃO ENCONTRADO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'NOME INVÁLIDO!';
	END IF;	
END $$
LANGUAGE plpgsql;

SELECT GET_ID_USUARIO('');
SELECT GET_ID_USUARIO(NULL);
SELECT GET_ID_USUARIO('SDCSC');
SELECT GET_ID_USUARIO('EDINEI');
SELECT * FROM USUARIOS;

-- ********************** Testes da Função ******************************

-- Criando a Função para obter id dos Arrecadamentos.

CREATE OR REPLACE FUNCTION GET_ID_ARRECADADOS(NOME_LIVRO_ACERVO TEXT)
RETURNS INTEGER AS $$
DECLARE COD INTEGER;
BEGIN
	IF VALIDAR_STRING(NOME_LIVRO_ACERVO) THEN
	
	   	SELECT ID_ARRECA
		INTO COD
		FROM ARRECADADOS
		WHERE LIVROARRECA = GET_ID_ACERVO(NOME_LIVRO_ACERVO);

		IF FOUND THEN
			RAISE NOTICE 'LIVRO ENCONTRADO NA ARRECADAÇÃO!';
			RETURN COD;
		ELSE
			RAISE EXCEPTION 'LIVRO NÃO ENCONTRADO NA ARRECADAÇÃO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'NOME DO LIVRO INVÁLIDO!';
	END IF;
END $$
LANGUAGE plpgsql;


SELECT GET_ID_ARRECADADOS('');
SELECT GET_ID_ARRECADADOS(NULL);
SELECT GET_ID_ARRECADADOS('SASDAD');
SELECT GET_ID_ARRECADADOS('IRACEMA');
SELECT GET_ID_ARRECADADOS('O CORTIÇO');
SELECT * FROM ACERVO;
SELECT * FROM LIVROS;
SELECT * FROM ARRECADADOS;
-- ********************** Testes da Função ******************************

-- Criando a Função para adicionar os Arrecadamentos.

CREATE OR REPLACE FUNCTION ADD_ARRECADADOS(LIVRO TEXT, DATA_ARRECA DATE)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(LIVRO) THEN
		INSERT INTO ARRECADADOS(LIVROARRECA,
								 DATAARRECA
								)VALUES(GET_ID_LIVRO(LIVRO),
										DATA_ARRECA
								);
		IF FOUND THEN
			RAISE NOTICE 'Livro arrecadado inserido com sucesso.';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA NA INSERÇÃO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'Parâmetros inválidos para a função ADD_ARRECADADOS.';
	END IF;
END $$
LANGUAGE plpgsql;

SELECT * FROM ACERVO;
SELECT ADD_ACERVO('TESTE LIVRO ARRECADADOS', 'TESTE AUTOR', 'TESTE EDITORA');
SELECT ADD_LIVRO('TESTE LIVRO ARRECADADOS');
SELECT ADD_AUTOR('TESTE AUTOR');
SELECT ADD_EDITORA('TESTE EDITORA');
SELECT ADD_ARRECADADOS(NULL, NULL);
SELECT ADD_ARRECADADOS('JSDSDSD', NULL);
SELECT ADD_ARRECADADOS('TESTE LIVRO ARRECADADOS', NULL);
SELECT ADD_ARRECADADOS('TESTE LIVRO ARRECADADOS','');
SELECT ADD_ARRECADADOS(NULL, CURRENT_DATE);
SELECT ADD_ARRECADADOS('', CURRENT_DATE);
SELECT ADD_ARRECADADOS('SDSDSDSDSDSDS', CURRENT_DATE);
SELECT ADD_ARRECADADOS('TESTE LIVRO ARRECADADOS', CURRENT_DATE);
SELECT * FROM ARRECADADOS;
SELECT * FROM LIVROS;

-- ********************** Testes da Função ******************************

-- Criando a Função para realizar update no Acervo.

CREATE OR REPLACE FUNCTION UPDATE_ACERVO(OLD_LIVRO TEXT, 
										  NEW_LIVRO TEXT, 
										  AUTOR TEXT, 
										  EDITORA TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(NEW_LIVRO) AND
	   VALIDAR_STRING(OLD_LIVRO) AND
	   VALIDAR_STRING(AUTOR) AND 
	   VALIDAR_STRING(EDITORA) THEN
	
		IF GET_ID_ACERVO(OLD_LIVRO) IS NOT NULL AND
		   GET_ID_LIVRO(NEW_LIVRO) IS NOT NULL AND
		   GET_ID_EDITORA(EDITORA) IS NOT NULL AND 
		   GET_ID_AUTOR(AUTOR) IS NOT NULL THEN
	
			UPDATE ACERVO
			SET NOME_LIVRO = GET_ID_LIVRO(NEW_LIVRO), 
				NOME_AUTOR = GET_ID_AUTOR(AUTOR), 
				NOME_EDITORA = GET_ID_EDITORA(EDITORA)
			WHERE ID_ACERVO =  GET_ID_ACERVO(OLD_LIVRO);

				RAISE NOTICE 'ACERVO ATUALIZADO COM SUCESSO!';
				RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'LIVRO NÃO ENCONTRADO NO ACERVO PARA ATUALIZAÇÃO OU PARÂMETROS INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

SELECT UPDATE_ACERVO('','', '', '');
SELECT UPDATE_ACERVO('','',NULL,NULL);
SELECT UPDATE_ACERVO('',NULL, '',NULL);
SELECT UPDATE_ACERVO('',NULL,NULL,'');
SELECT UPDATE_ACERVO('','','',NULL);
SELECT UPDATE_ACERVO('','',NULL,'');
SELECT UPDATE_ACERVO(NULL,NULL,'','');
SELECT UPDATE_ACERVO(NULL,NULL,NULL,NULL);
SELECT UPDATE_ACERVO('IRACEMA','O CORTIÇO', 'JOSÉ DE ALENCAR', 'ÁTICA');
SELECT UPDATE_ACERVO('O CORTIÇO','IRACEMA', 'JORGE AMADO', 'ÁTICA');
SELECT UPDATE_ACERVO('IRACEMA','O CORTIÇO', 'JOSÉ DE ALENCAR', 'MARTIN CLARET');
SELECT UPDATE_ACERVO('','IRACEMA', 'JORGE AMADO', 'MARTIN CLARET');
SELECT UPDATE_ACERVO('SAASASA','IRACEMA', 'JOSÉ DE ALENCAR', 'MARTIN CLARET');
SELECT UPDATE_ACERVO('','SASASSA', 'ASASAS', 'SASAS');
SELECT * FROM LIVROS;
SELECT * FROM AUTORES;
SELECT * FROM EDITORAS;
select * from acervo;

-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de livro em Arrecadados;

CREATE OR REPLACE FUNCTION UPDATE_ARRECADADOS(OLD_LIVRO TEXT, 
											   NEW_LIVRO TEXT, 
											   NEW_DATA DATE)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(NEW_LIVRO) AND
	   VALIDAR_STRING(OLD_LIVRO) THEN

		IF GET_ID_ACERVO(OLD_LIVRO) IS NOT NULL AND
		   GET_ID_ACERVO(NEW_LIVRO) IS NOT NULL AND
		   GET_ID_ARRECADADOS(OLD_LIVRO) IS NOT NULL THEN

			UPDATE ARRECADADOS
			SET LIVROARRECA = GET_ID_ACERVO(NEW_LIVRO),
				DATAARRECA = NEW_DATA
			WHERE LIVROARRECA = GET_ID_ACERVO(OLD_LIVRO);
		
			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;	
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_ARRECADADOS('O ALQUIMISTA','OS SERTÕES','2000-06-20');
ROLLBACK;

SELECT * FROM LIVROS;
SELECT * FROM ACERVO;
SELECT * FROM ARRECADADOS;
-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de Autores.

CREATE OR REPLACE FUNCTION UPDATE_AUTOR(OLD_AUTOR TEXT, 
										 NEW_AUTOR TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(NEW_AUTOR) AND
	   VALIDAR_STRING(OLD_AUTOR) THEN

		IF GET_ID_AUTOR(OLD_AUTOR) IS NOT NULL THEN

			UPDATE AUTORES
			SET NOME_AUTOR = NEW_AUTOR
			WHERE ID_AUTOR = GET_ID_AUTOR(OLD_AUTOR);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_AUTOR('PAULO COELHO','MUDOU O NOME DO AUTOR AQUI!');
ROLLBACK;

SELECT * FROM AUTORES;
-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de Curso.

CREATE OR REPLACE FUNCTION UPDATE_CURSO(OLD_CURSO TEXT, 
										 NEW_ENDERECO TEXT, 
										 TIPO_CURSO TEXT, 
										 NOME_CURSO TEXT)
RETURNS BOOLEAN AS $$
BEGIN

	IF VALIDAR_STRING(NEW_ENDERECO) AND
	   VALIDAR_STRING(OLD_CURSO) AND
	   VALIDAR_STRING(TIPO_CURSO) AND
	   VALIDAR_STRING(NOME_CURSO) THEN

		IF GET_ID_ENDERECO(NEW_ENDERECO) IS NOT NULL AND
		   GET_ID_CURSO(OLD_CURSO) IS NOT NULL THEN

			UPDATE cursos
			SET endereco = GET_ID_ENDERECO(NEW_ENDERECO),
				tipoCurso = TIPO_CURSO,
				nomeCurso = NOME_CURSO			
			WHERE id_curso = GET_ID_CURSO(OLD_CURSO);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_CURSO('CURSO DE LITERATURA DA UNICAMP','AVENIDA BRASIL','TIPO CURSO TESTE AQUI!','NOME TESTE CURSO AQUI!');
	
ROLLBACK;

SELECT * FROM CIDADE_ESTADO;
SELECT * FROM CURSOS;

-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de uma Editora.

CREATE OR REPLACE FUNCTION UPDATE_EDITORA(OLD_EDITORA TEXT, 
										   NEW_EDITORA TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(OLD_EDITORA) AND
	   VALIDAR_STRING(NEW_EDITORA) THEN
	
		IF GET_ID_EDITORA(OLD_EDITORA) IS NOT NULL THEN
	
			UPDATE EDITORAS
			SET nome_editora = NEW_EDITORA
			WHERE id_editora = GET_ID_EDITORA(OLD_EDITORA);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_EDITORA('ÁTICA','TESTE MUDAR NOME EDITORA AQUI!');
ROLLBACK;

SELECT * FROM EDITORAS;
-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de um Endereço.

CREATE OR REPLACE FUNCTION UPDATE_ENDERECO(OLD_ENDERECO TEXT , 
										    NEW_RUA TEXT, 
											NEW_ESTADO TEXT, 
											NEW_CIDADE TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(OLD_ENDERECO) AND
	   VALIDAR_STRING(NEW_RUA) AND
	   VALIDAR_STRING(NEW_ESTADO) AND
	   VALIDAR_STRING(NEW_CIDADE) THEN
	
 		IF GET_ID_ENDERECO(OLD_ENDERECO) IS NOT NULL THEN 
	
			UPDATE cidade_estado
			SET Cidade = NEW_CIDADE,
				Estado = NEW_ESTADO,
				Rua = NEW_RUA
			WHERE id_CiEs = GET_ID_ENDERECO(OLD_ENDERECO);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_ENDERECO('RUA DAS FLORES','RUA NOVA TESTE','NOVO ESTADO TESTE','NOVA CIDADE TESTE');
ROLLBACK;

SELECT * FROM CIDADE_ESTADO;
-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de um livro.

CREATE OR REPLACE FUNCTION UPDATE_LIVRO(OLD_LIVRO TEXT, 
										 NEW_LIVRO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(OLD_LIVRO) AND
	   VALIDAR_STRING(NEW_LIVRO) THEN
	
		IF GET_ID_LIVRO(OLD_LIVRO) IS NOT NULL THEN
	
			UPDATE livros
			SET nome_livro = NEW_LIVRO
			WHERE id_livros = GET_ID_LIVRO(OLD_LIVRO);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_LIVRO('IRACEMA','TESTE UPDATE NOME AQUI!');
ROLLBACK;

SELECT * FROM LIVROS;
-- **********************Testes da Função ******************************

-- Criando a Função para realizar update de um Usuário.

CREATE OR REPLACE FUNCTION UPDATE_USUARIO(OLD_USUARIO TEXT, 
										  NEW_USUARIO TEXT, 
	 									  TYPE_USER TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	IF VALIDAR_STRING(OLD_USUARIO) AND
	   VALIDAR_STRING(NEW_USUARIO) AND
	   VALIDAR_STRING(TYPE_USER) THEN
	
		IF GET_ID_USUARIO(OLD_USUARIO) IS NOT NULL AND
		   CHECK_TYPE_USER(TYPE_USER) THEN
	
			UPDATE usuarios
			SET nome_usuario = NEW_USUARIO,
				tipo_usuario = TYPE_USER
			WHERE id_usuario = GET_ID_USUARIO(OLD_USUARIO);

			RAISE NOTICE 'REGISTRO ATUALIZADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'REGISTRO NÃO ENCONTRADO PARA UPDATE OU PARÂMETROS DE ENTRADA INVÁLIDOS!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT UPDATE_USUARIO('EDINEI','TESTE UPDATE USUÁRIO','desenvolvedorSenior');
	SELECT UPDATE_USUARIO('EDINEI','TESTE UPDATE USUÁRIO','SDSDSD');
	SELECT UPDATE_USUARIO('EDINEI','TESTE UPDATE USUÁRIO','');
	SELECT UPDATE_USUARIO('EDINEI','TESTE UPDATE USUÁRIO',NULL);  
ROLLBACK;

SELECT * FROM USUARIOS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Acervo.

CREATE OR REPLACE FUNCTION DELETE_ACERVO(LIVRO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(LIVRO) THEN

		DELETE FROM ACERVO
		WHERE id_acervo = GET_ID_ACERVO(LIVRO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE 
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_ACERVO('O ALQUIMISTA');
ROLLBACK;

SELECT * FROM LIVROS;
SELECT * FROM ACERVO;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Arrecadados.

CREATE OR REPLACE FUNCTION DELETE_ARRECADADOS(LIVRO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(LIVRO) THEN

		DELETE FROM arrecadados 
		WHERE id_arreca = GET_ID_ARRECADADOS(LIVRO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_ARRECADADOS('O ALQUIMISTA');
ROLLBACK;

SELECT * FROM LIVROS;
SELECT * FROM ACERVO;
SELECT * FROM ARRECADADOS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Autor.

CREATE OR REPLACE FUNCTION DELETE_AUTOR(AUTOR TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(AUTOR) THEN
	
		DELETE FROM autores
		WHERE id_autor = GET_ID_AUTOR(AUTOR);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;
	
BEGIN;
	SELECT DELETE_AUTOR('PAULO COELHO');
ROLLBACK;

SELECT * FROM AUTORES;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Endereço.

CREATE OR REPLACE FUNCTION DELETE_ENDERECO(ENDERECO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(ENDERECO) THEN
	
		DELETE FROM cidade_estado
		WHERE id_CiEs = GET_ID_ENDERECO(ENDERECO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_ENDERECO('RUA DAS FLORES');
ROLLBACK;

SELECT * FROM cidade_estado;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Curso.

CREATE OR REPLACE FUNCTION DELETE_CURSO(CURSO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(CURSO) THEN
	
		DELETE FROM cursos
		WHERE id_curso = GET_ID_CURSO(CURSO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_CURSO('CURSO DE LITERATURA DA UNICAMP');
ROLLBACK;

SELECT * FROM CURSOS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Doados.

CREATE OR REPLACE FUNCTION DELETE_DOADOS(LIVRO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(LIVRO) THEN
	
		DELETE FROM doados
		WHERE id_doado = GET_ID_DOACAO(LIVRO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_DOADOS('O ALQUIMISTA');
ROLLBACK;

SELECT * FROM LIVROS;
SELECT * FROM DOADOS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Editora.

CREATE OR REPLACE FUNCTION DELETE_EDITORA(EDITORA TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(EDITORA) THEN
	
		DELETE FROM editoras
		WHERE id_editora = GET_ID_EDITORA(EDITORA);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_EDITORA('HARPERCOLLINS');
ROLLBACK;

SELECT * FROM EDITORAS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Livro.

CREATE OR REPLACE FUNCTION DELETE_LIVRO(LIVRO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(LIVRO) THEN
	
		DELETE FROM livros
		WHERE id_livros = GET_ID_LIVRO(LIVRO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_LIVRO('O ALQUIMISTA');
ROLLBACK;

SELECT * FROM LIVROS;
-- **********************Testes da Função ******************************

-- Criando a Função para Deletar Usuário.

CREATE OR REPLACE FUNCTION DELETE_USUARIO(USUARIO TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	
	IF VALIDAR_STRING(USUARIO) THEN
	
		DELETE FROM usuarios
		WHERE id_usuario = GET_ID_USUARIO(USUARIO);
	
		IF FOUND THEN
			RAISE NOTICE 'REGISTRO DELETADO COM SUCESSO!';
			RETURN TRUE;
		ELSE
			RAISE EXCEPTION 'FALHA AO DELETAR REGISTRO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'PARÂMETROS DE ENTRADA INVÁLIDOS!';
	END IF;
END $$
LANGUAGE plpgsql;

BEGIN;
	SELECT DELETE_USUARIO('EDINEI');
ROLLBACK;

SELECT * FROM USUARIOS;
-- **********************Testes da Função ******************************

-- FUNÇÃO QUE LISTA DOAÇÕES DE LIVRO POR PERIODO

CREATE OR REPLACE FUNCTION listar_doacoes_por_periodo(data_inicial DATE, data_final DATE)
RETURNS TABLE (
    id_doacao INT,
    data_doacao DATE,
    livro_id INT,
    nome_livro VARCHAR(100),
    curso_id INT,
    nome_curso VARCHAR(255)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_doado, d.dataDoado, l.id_livros, l.nome_livro, c.id_curso, c.nomeCurso
    FROM doados d
    JOIN acervo a ON d.livroDoado = a.id_acervo
    JOIN livros l ON a.nome_livro = l.id_livros
    JOIN cursos c ON d.cursoDestino = c.id_curso
    WHERE d.dataDoado BETWEEN data_inicial AND data_final;
END;
$$ LANGUAGE plpgsql;

-- Exemplo de uso:
select * from doados;
SELECT * FROM listar_doacoes_por_periodo(DATE '1994-12-18', DATE '2010-12-31');
SELECT * FROM listar_doacoes_por_periodo(DATE '2007-01-01', DATE '2024-12-31');
-- *********************************** TESTE DA FUNÇÃO **************************************

-- FUNÇÃO PARA VERIFICAR LIVROS DOADOS PARA UM CURSO ESPECÍFICO. 

CREATE OR REPLACE FUNCTION Livros_Doado_Curso(cursoId INT)
    RETURNS TABLE(nome_livro VARCHAR(100))
AS $$
BEGIN
    RETURN QUERY
    SELECT l.nome_livro
    FROM livros l
    JOIN acervo a ON l.id_livros = a.nome_livro
    JOIN doados d ON a.id_acervo = d.livroDoado
    WHERE d.cursoDestino = cursoId;
END $$
LANGUAGE plpgsql;

SELECT * FROM CURSOS;
SELECT * FROM DOADOS;
SELECT * FROM LIVROS;
SELECT Livros_Doado_Curso(GET_ID_CURSO('CURSO DE LITERATURA DA UNICAMP'));
SELECT Livros_Doado_Curso(GET_ID_CURSO('CURSO DE HISTÓRIA DA USP'));

-- ******************************** TESTE DA FUNÇÃO *****************************************






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