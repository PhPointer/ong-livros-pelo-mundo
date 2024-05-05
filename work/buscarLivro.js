function buscarLivro(titulo) {
    // Variáveis para armazenar os elementos HTML
    var nameElement = document.getElementById("name");
    var coverElement = document.getElementById("cover");
    var titleElement = document.getElementById("title");

    // Limpar os elementos HTML
    nameElement.innerHTML = "";
    coverElement.src = "";
    titleElement.innerHTML = "";

    // Requisição AJAX
    $.ajax({
        url: 'https://openlibrary.org/search.json?title=' + encodeURIComponent(titulo),
        success: function(response) {
            console.log(response);

            var bookTitle = response.docs[0].title; // Obtém o título do primeiro livro
            var authorName = response.docs[0].author_name[0];
            var coverURL = "http://covers.openlibrary.org/b/id/" + response.docs[0].cover_i + "-M.jpg";

            nameElement.innerHTML = "Autor: " + authorName;
            coverElement.src = coverURL;
            titleElement.innerHTML = "Título do Livro: " + bookTitle;
        },
        error: function() {
            console.error("Ocorreu um erro na requisição.");
        }
    });
}
