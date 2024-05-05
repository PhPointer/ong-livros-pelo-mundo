<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="icon/icons8-estante-de-livros-48.ico" type="image/x-icon">
    <link rel="stylesheet" href="estilo_sobre.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <title>ONG - Livros pelo Mundo</title>
</head>
<body>

    <header>
        <h2 class="logo">Logo</h2>
        <nav class="navigation">
            <a href="index.php">Início</a>
            <a href="pesquisarLivro.php">Pesquisar Livro</a>
            <a href="sobre.php">Sobre</a>
            <a href="contato.php">Contato</a>
            <button class="botaoLogin_PopUp">Login</button>
        </nav>
   </header>

    <div class="livro">
        <h2 class="title">Nome do Livro</h2>
        <div class="bloco">
            <div class="linha">
                <div class="coluna">
                    <form>
                        <input type="text" class="form-control" id="nomeArtista" placeholder="Digite o título do livro">
                        <button type="button" class="botaoPrimario" onclick="buscarLivro(document.getElementById('nomeArtista').value)">Buscar</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="content">
        <script src="buscarLivro.js"></script>
        <h3 id="name"></h3>
        <img id="cover" src="" alt="">
        <div id="title"></div>
    </div>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <footer id="rodape">
        <span>&copy Copyright 2024 - <script>document.write(new Date().getFullYear());</script> Desenvolvido por <a href="https://github.com/pedrofratassi/ong-livro-pelo-mundo"
        target="_blank" rel="noopener noreferrer">ONG - Livros Pelo Mundo.</a> Todos os Direitos Reservados.
        </span>  
    </footer>
    
</body>
</html>
