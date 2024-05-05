const wrapper = document.querySelector('.wrapper');
const loginLink = document.querySelector('.login-link');
const registerLink = document.querySelector('.registro-link');
const botaoPopUp = document.querySelector('.botaoLogin_PopUp');
const iconClose = document.querySelector('.icon-close');


  registerLink.addEventListener('click', () => {
      wrapper.classList.add('active');
  });

  loginLink.addEventListener('click', () => {
      wrapper.classList.remove('active');
  });

  botaoPopUp.addEventListener('click', () => {
      wrapper.classList.add('active-popUp');
  });

  iconClose.addEventListener('click', () => {
      wrapper.classList.remove('active-popUp');
  });

  // Função para acionar o botão de login ou registro
  function submitForm(event) {
    event.preventDefault(); // Impede o envio do formulário

    // Obtém os valores dos campos de entrada
    var usernameInput = document.querySelector('#username');
    var emailInput = document.querySelector('#email');
    var passwordInput = document.querySelector('#password');

    // Validação dos campos (pode ser adaptada de acordo com as necessidades)
    if (usernameInput.value.trim() === '' || emailInput.value.trim() === '' || passwordInput.value.trim() === '') {
        alert('Por favor, preencha todos os campos.');
        return;
    }

    // Aqui você pode fazer o envio dos dados para o servidor (por exemplo, usando AJAX ou fetch)

    // Exibindo os valores inseridos no console para fins de demonstração
    console.log('Nome de usuário:', usernameInput.value);
    console.log('Email:', emailInput.value);
    console.log('Senha:', passwordInput.value);

    // Redefinindo os valores dos campos de entrada
    usernameInput.value = '';
    emailInput.value = '';
    passwordInput.value = '';

    // Exibindo uma mensagem de sucesso (pode ser adaptada de acordo com as necessidades)
    alert('Login ou registro realizado com sucesso!');
}

// Função para lembrar-se do usuário
function rememberUser() {
    // Obtém o estado de seleção do checkbox
    var rememberCheckbox = document.querySelector('#remember');

    // Verifica se o checkbox está marcado
    if (rememberCheckbox.checked) {
        // Aqui você pode salvar o estado de lembrar-se do usuário (por exemplo, usando cookies ou localStorage)
        console.log('Usuário lembrado.');
    } else {
        // Aqui você pode remover o estado de lembrar-se do usuário (por exemplo, removendo cookies ou dados do localStorage)
        console.log('Usuário não lembrado.');
    }
}

// Evento para acionar o botão de login ou registro
var submitBtn = document.querySelector('#submitBtn');
submitBtn.addEventListener('click', submitForm);

// Evento para lembrar-se do usuário
var rememberCheckbox = document.querySelector('#remember');
rememberCheckbox.addEventListener('change', rememberUser);



