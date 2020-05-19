# Bankr

Bankr é uma API de cadastro de contas bancárias, que contém também funcionalidade para visualização de indicações. 

## Configuração local da API

A API foi feita utilizando o framework web Phoenix.Para rodar localmente, é preciso seguir os seguintes passos (conforme documentação oficial):


  * Instalar dependências com `mix deps.get`
  * Configurar banco de dados com `mix ecto.setup`
  * Instalar dependências e Node.js com `cd assets && npm install`
  * Rodar localmente com `mix phx.server`

A API serve no endereço [`localhost:4000`](http://localhost:4000)

## Endpoints da API. 

O Bankr serve 3 endpoints:

### Cadastro

O cadastro é feito a partir da rota `/api/register`, método `POST`

#### Parâmetros (cadastro completo)
```
 {
    "data":{
      "birth_date": "2010-04-17",
      "city": "São Paulo",
      "country": "Brasil",
      "cpf": "32432018028",
      "email": "valid@email.com",
      "gender": "male",
      "name": "A Name",
      "state": "SP"
    }
  }
```

#### Exemplo de retorno
```
  {
      "data": {
          "birth_date": "2010-04-17",
          "city": "São Paulo",
          "country": "Brasil",
          "cpf": "32432018028",
          "email": "valid@email.com",
          "gender": "male",
          "generated_rc": "JHh2MLrd",
          "id": 1,
          "name": "A Name",
          "registration_status": "completed",
          "state": "SP",
          "password": "12345678"
      },
      "message": "Sucesso!"
  }
```

### Login

O login é feito a partir da rota `api/login`, método post.

#### Parâmetros
```
  {
    "cpf": "32432018028",
    "password": "12345678"
  }
```

#### Exemplo de retorno
```
{
    "data": {
        "cpf": "32432018028",
        "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJiYW5rciIsImV4cCI6MTU5MjI2NzA0MSwiaWF0IjoxNTg5ODQ3ODQxLCJpc3MiOiJiYW5rciIsImp0aSI6IjNlNDVkMjFmLWIxZGEtNGZjYy1hOGM0LTBmOGYzNmY1NWFhMiIsIm5iZiI6MTU4OTg0Nzg0MCwic3ViIjoiMSIsInR5cCI6ImFjY2VzcyJ9.1fScPRPDRcVcYHEiunhkcGwBoG-Ophq3dNBdNO64IO9SbTOqDtp8Oz4ZYWgKQ6DKXhJBbK7tnGJPsOxdFUyq8Q"
    },
    "message": "Logado com sucesso! Adicione o token no Authorization header para realizar requests autorizados.",
    "status": "ok"
}
```

Após o login, um token JWT é gerado e enviado na mensagem de retorno. O consumidor da API deve adicionar o token JWT na `Authorization header` das requisições autenticadas. O tipo da autorização é `Bearer`

### Visualização de indicações 

O usuário precisa estar devidamente logado para visualizar quem usou o código de indicação do seu cadastro. A rota está em `/api/v1/referrals`, método `GET`

#### Exemplo de retorno
```
  %{
    "data" => [
      %{
        "id" => 1,
        "name" => "José Amarildo"
      },
      %{
        "id" => 2,
        "name" => "Andreia Silva"
      }
    ]
  }
```

## Detalhes sobre a implementação

O banco de dados utilizado para esta API é o PostgreSQL. Informações de nome, e-mail, data de nascimento e CPF estão criptografadas, utilizando funções da biblioteca erlang `:crypto`. As funções _wrapper_ foram baseadas do tutorial [Phoenix Ecto Encryption Example](https://github.com/dwyl/phoenix-ecto-encryption-example).

As funções de criptografia dos dados são utilizadas no `type` `Bankr.EncryptedType`. Ele importa comportamentos de uma string, mas antes de salvar no banco o campo é convertido para binary e é criptografado e antes da visualização é descriptografado. 

Para o login, utilizei a biblioteca `Guardian` para implementar o fluxo de autenticação e o `Bcrypt` para fazer o _hashing_ das senhas. 

Para controle de acesso dos usuários logados (exemplo: visualização de indicações), eu utilizei a biblioteca `Bodyguard`, adicionando `Bodyguard.Plug` nos endpoints necessários.

A geração de strings aleatórias é feita através da biblioteca `EntropyString`

Nos testes, utilizei a biblioteca `Faker` para gerar informações randômicas sobre nome de cidade, e-mail e nome. A geração de CPFs válidos e sua validação é feita através do `Cpfcnpj`.
