<?php
    // Configurações de conexão com o banco de dados
    $host = 'localhost';
    $dbname = 'ONG';
    $user = 'postgres';
    $password = '123';

    try {
        // Conecta ao banco de dados usando a extensão PDO e o driver PostgreSQL
        $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        
    } catch (PDOException $e) {
        // Em caso de erro na conexão ou na consulta
        die('Erro ao conectar com o banco de dados: ' . $e->getMessage());
    }
?>
 