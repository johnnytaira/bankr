# Bankr

Bankr is a bank account registration and referral API.

## Local setup

This app is made with Phoenix. To run locally, you need to run these following steps:


  * Install deps with `mix deps.get`
  * Configure database `mix ecto.setup`
  * Install assets and Node.js `cd assets && npm install`
  * Run locally with `mix phx.server`

The API is on [`localhost:4000`](http://localhost:4000)

## API documentation. 

Bankr has 3 endpoints:

### Registration

Route: `/api/register`
Method: `POST`

#### Parameters (full registration)
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
#### Response
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

Route: `api/login`
Method: `POST`

#### Parameters
```
  {
    "cpf": "32432018028",
    "password": "12345678"
  }
```

#### Response
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

A JWT token is generated after login and can be added on protected endpoints as an `Authorization header` (`Bearer token`)

### Referrall list

User must be logged in to see referred lists. 

Route: `/api/v1/referrals`
Method: `GET`
Authorization: `Bearer <token>`

#### Response
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

## Implementation details

This app has PostgreSQL database. Registration info such as `name`, `email`, `birth_date` and `cpf` are encrypted.
The encryption layer was inspired on tutorial [Phoenix Ecto Encryption Example](https://github.com/dwyl/phoenix-ecto-encryption-example

`Guardian` and `Bcrypt` were chosen to login and API authentication flow.

`Bodyguard` controls authorization on logged users.
