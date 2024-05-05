<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <link rel="shortcut icon" href="icon/icons8-estante-de-livros-48.ico" type="image/x-icon">
    <link rel="stylesheet" href="estilo_sobre.css" type="text/css">
    <title>ONG - Livros pelo Mundo</title>
</head>
<body>
   <header>
        <h2 class="logo">Logo</h2>
        <nav class="navigation">
            <a href="#">Início</a>
            <a href="pesquisarLivro.php">Pesquisar Livro</a>
            <a href="sobre.php">Sobre</a>
            <a href="contato.php">Contato</a>
            <button class="botaoLogin_PopUp">Login</button> 
        </nav>
   </header>

    <div class="container">
        <?php if(!empty($_GET['msgErro'])) { ?>
            <div class="alert warning-alert" role="alert">
            <?php echo $_GET['msgErro']; ?> 
            </div>
        <?php } ?>  
        
        <?php if(!empty($_GET['msgSucesso'])) { ?>
            <div class="alert warning-sucess" role="alert">
            <?php echo $_GET['msgSucesso']; ?> 
            </div>
        <?php } ?>  
    </div>

    <div class="wrapper">
        <span class="icon-close">
            <ion-icon name="close-sharp"></ion-icon>
        </span>

        <div class="form-box login">
            <h2>Login</h2>
            <form action="processaUsuario.php" method="POST">
                <div class="input-box">
                   <span class="icon">
                        <ion-icon name="mail"></ion-icon>
                    </span>
                   <input type="email" name="email" required> 
                   <label>Email</label>
                </div>
                <div class="input-box">
                   <span class="icon">
                        <ion-icon name="lock-closed"></ion-icon>
                    </span>
                   <input type="password" name="password" required> 
                   <label>Senha</label>
                </div>
                <div class="lembrar-esquecer">
                    <label><input type="checkbox">Lembre-me</label>
                    <br>
                    <a href="#">Eu aceito os Termos de Uso</a>
                </div>
                <button type="submit" class="botao" name="enviarDados">Login</button>
                <div class="login-resgistrado">
                    <p>Não tem nenhuma Conta? <a href="#" class="registro-link">Registre</a></p>
                </div>
            </form>
        </div>

        <div class="form-box register">
            <h2>Registração</h2>
            <form action="processaUsuario.php" method="POST">
                <div class="input-box">
                   <span class="icon">
                        <ion-icon name="person"></ion-icon>
                    </span>
                   <input type="text" name="username" required> 
                   <label>Nome de Usuário</label>
                </div>
                <div class="input-box">
                   <span class="icon">
                        <ion-icon name="mail"></ion-icon>
                    </span>
                   <input type="email" name="email" required> 
                   <label>Email</label>
                </div>
                <div class="input-box">
                   <span class="icon">
                        <ion-icon name="lock-closed"></ion-icon>
                    </span>
                   <input type="password" name="password" required> 
                   <label>Senha</label>
                </div>
                <div class="lembrar-esquecer">
                    <label><input type="checkbox">Lembre-me</label>
                    <a href="#">Esqueceu Senha?</a>
                </div>
                <button type="submit" class="botao" name="enviarDados">Registrar</button>
                <div class="login-resgistrado">
                    <p>Já possuí uma Conta? <a href="#" class="login-link">Login</a></p>
                </div>
            </form>
        </div>
    </div>

    <script>
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const msgErro = urlParams.get('msgErro');
            if (msgErro) {
                let message = '';
                switch(msgErro) {
                    case 'sucesso':
                        message = 'Sucesso ao se Cadastrar';
                        break;
                    case 'erro':
                        message = 'Falha ao se Cadastrar...';
                        break;
                    case 'acesso':
                        message = 'Erro de Acesso.';
                        break;
                }
                alert(decodeURIComponent(message));
            }
        }
    </script>

    <footer id="rodape">
        <span>&copy Copyright 2024 - <script>document.write(new Date().getFullYear());</script> Desenvolvido por <a href="https://github.com/pedrofratassi/ong-livro-pelo-mundo"
        target="_blank" rel="noopener noreferrer">ONG - Livros Pelo Mundo.</a> Todos os Direitos Reservados.
        </span>  
    </footer>


    <script src="script.js"></script>    
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
