<?php
   require_once 'conexao.php';

   if(!empty($_POST)){
    //Chegada de dados vindo do método POST e então podemos tentar inserir no Banco de Dados
    try{
        $sql = "INSERT INTO usuarios  (nome_usuario, email, senha, tipo_usuario) VALUES(:nome_usuario, :email, :senha, :tipo_usuario)";

        //Preparando PDO  em SQL
        $stmt = $pdo -> prepare($sql);

        //Organizando os dados em SQL
        $dados = array(
            ':nome_usuario' => $_POST['username'],  
            ':email' => $_POST['email'],
            //md5 é função que codifica a senha para não sabermos qual é, ou seja, através de Algoritmo codifica a senha para não aparacer a respectiva a senha do usuário lá no Banco de Dados
            ':senha' => md5($_POST['password']),
            ':tipo_usuario' => 'usuario'  // valor padrão
        );

        //Tentando executar a SQL (INSERT)
        //Realizar a inserção dos Dados no BD (com PHP)
        if($stmt -> execute($dados)){
            header("Location: index.php?status=sucesso");
        } 
    } catch (PDOException $e){
        //die($e -> getMessage());
        header("Location: index.php?msgErro=");
    }

   } else {
    //Impede que Usuário acesse diretamente esse Arquivo .PHP, ou seja, restrigindo acesso do Usuário a essa área
    header("Location: index.php?msgErro=Erro de Acesso.");
   }

   //Caso de algum problema o die irá interromper a execução
   die();
?>  