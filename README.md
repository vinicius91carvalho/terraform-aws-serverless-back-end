# Terraform AWS Serverless Back-end

> Implante um back-end completo na AWS utilizando a arquitetura Serverless com Terraform

## Características

* Hospeda duas API's simples, sendo uma com **autenticação** e acesso ao banco (Como exemplo)
* Pronta para os **ambientes de desenvolvimento, homologação e produção**
* Os endpoints já possuirão um domínio associado e um **certificado SSL**
* Possuí **CI/CD** utilizando o Bitbucket Pipelines
* Garante a segurança por meio da **criação das permissões mínimas** para cada recurso
* Testes unitários e integrados
* Integração com o Sonar (Inspeção da qualidade do código)

## Serviços AWS

* [API Gateway][1]: **Gerência as APIs** da aplicação (Segurança, Manutenção, Versionamento, Publicação e etc)
* [Lambda][2]: Serviço que **executa as regras de negócio em funções** que apenas são cobradas quando estão em execução
* [DynamoDB][3]: Banco de dados NoSQL baseado em chave-valor com desempenho em milissegundos em qualquer escala
* [Cognito][4]: Serviço de autenticação e autorização para ser incorporado na aplicação

[1]: https://aws.amazon.com/pt/api-gateway/
[2]: https://aws.amazon.com/pt/lambda/
[3]: https://aws.amazon.com/pt/dynamodb/
[4]: https://aws.amazon.com/pt/cognito/

## Arquitetura da aplicação

![Arquitetura][5]

[5]: assets/architecture.png

## Serviços Atlassian

* [Bitbucket][6]: Serviço de controle de versão para armazenar este projeto, concorrente do Github.
* [Bitbucket Pipelines][7]: Serviço de CI/CD integrado ao Bitbucket

[6]: https://www.atlassian.com/br/software/bitbucket
[7]: https://bitbucket.org/product/br/features/pipelines

![Pipeline][8]

[8]: assets/pipeline.png

Existem 2 pipelines configurados. Um para ser executado na branch de *dev* e outro na branch *master*. Sendo que a branch *dev* implanta no ambiente de desenvolvimento e a branch *master* é responsável por implantar a aplicação no ambiente de homologação de forma automática e produção atráves de um passo manual.

### Ambientes

> Os valores entre chaves {} são variáveis

O projeto irá criar 3 ambientes na cloud: 

- O ambiente de desenvolvimento que irá responder pela url: https://dev-api-{nomeDoProjeto}.{domínio}
- O ambiente de homologação que irá responder pela url: https://stage-api-{nomeDoProjeto}.{domínio}
- O ambiente de produção que irá responder pelas urls: https://prod-api-{nomeDoProjeto}.{domínio} e https://api-{nomeDoProjeto}.{domínio}

## Requisitos

- Criar uma conta na AWS
- Criar um usuário IAM com a role **AdministratorAccess** do tipo programático (Acesso via CLI)
- Possuir um domínio gerênciado pelo Route53
- Criar um certificado SSL para esse domínio através do projeto [terraform-aws-serverless-ssl-certificate][13]
- Criar um *remote state* do Terraform através do projeto [terraform-aws-serverless-remote-state][11]
  - O *remote state* é utilizado para armazenar o estado que o Terraform gerência no S3 e fazer o lock-in em uma tabela do DynamoDB para não permitir alterações concorrentes
  - Caso não queira utilizar o remote state basta remover o código abaixo do arquivo terraform/main.tf
  ``` hcl
    terraform {
      backend "s3" {
        bucket         = "project-name-982687753950-us-east-1-remote-state"
        key            = "back-end/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "project-name-982687753950-us-east-1-remote-state"
      }
    }
  ```
- Caso queira utilizar o CI/CD é necessário criar uma conta no Bitbucket
  - Para subir esse repositório direto no Bitbucket, pode-se utilizar o projeto [terraform-aws-serverless-version-control][12]
  - Após subir esse projeto devidamente configurado para o Bitbucket é necessário:
    - Configurar as variáveis(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY e AWS_DEFAULT_REGION) em Settings -> Pipelines -> Account Variables
    - Configurar a variável SONAR_TOKEN caso deseje utilizar o passo "Send SonarCloud Metrics"
    - Configurar a variável PROJECT_NAME com o nome do projeto (Será utilizada para as URL's da aplicação)
    - Ativar a feature de Pipeline do Bitbucket (Basta acessar o repositório, clicar no item *Pipelines* no menu lateral esquerdo)
  - Alterar o arquivo cypress/fixtures/cred-user-cognito.json com as informações capturadas do Cognito
    - Criar um usuário no cognito que será utilizado para testes e inserir o username e o password neste arquivo.

[9]: https://learn.hashicorp.com/terraform/getting-started/install.html
[10]: https://www.npmjs.com/get-npm
[11]: https://github.com/vinicius91carvalho/terraform-aws-serverless-remote-state
[12]: https://github.com/vinicius91carvalho/terraform-aws-serverless-version-control
[13]: https://github.com/vinicius91carvalho/terraform-aws-serverless-ssl-certificate

## Configuração

As configurações de cada ambiente estão dentro dos arquivos:
```
 terraform
 |- dev.tfvars
 |- stage.tfvars
 |- prod.tfvars
```

Cada arquivo representa seu respectivo ambiente e dentro deles há as seguintes variáveis:

```
region                = "us-east-1"
project_name          = "project-name"
environment           = "dev"
domain                = "domain"
```

Sendo que:

#### `region`
- __Descrição__: Região na AWS ao qual os recursos serão implantados
#### `project_name`
- __Descrição__: Nome do projeto ao qual será utilizado tanto nas urls quanto no *remote-state* caso você deseje utilizá-lo.
#### `environment`
- __Descrição__: Será utilizado como prefixo nos nomes dos recursos criados
#### `domain`
- __Descrição__: Domínio que será utilizado para hospedar as aplicações. É necessário que o domínio esteja gerênciado peo Route53.
#### `user_cognito_email`
- __Descrição__: E-mail do usuário que será criado no Cognito para ser utilizado nos testes integrados
#### `user_cognito_password`
- __Descrição__: Senha do usuário que será criado no Cognito para ser utilizado nos testes integrados
#### `group_cognito_name`
- __Descrição__: Nome do grupo de usuário que será criado no Cognito e em que o usuário de teste será adicionado

## Implantação

### Via Bitbucket Pipelines

1. Basta configurar as variáveis de ambiente na conta do Bitbucket conforme descrito na seção [Requisitos][14] (Item: Caso queira utilizar o CI/CD é necessário criar uma conta no Bitbucket)
2. Iniciar a execução do pipeline. Ele criará todos os recursos na infra da AWS

[14]: #Requisitos

### Local

#### Instalação das ferramentas

- É necessário instalar o [Terraform][9] para aplicação das receitas
- É necessário instalar o [AWS CLI][15] e configurá-lo com os dados do [usuário IAM com acesso programático][14]
- O Node Package Manager [npm][10]
 
[15]: https://docs.aws.amazon.com/pt_br/cli/latest/userguide/cli-chap-configure.html

#### Executar os comandos

> Os comandos abaixo levam em consideração o ambiente de desenvolvimento, para trocar para os outros ambientes basta substituir "dev" por "stage" (homologação) ou "prod" (produção)

```
terraform init
terraform workspace new dev
terraform apply -var-file=dev.tfvars

npm install -g serverless
cd api/
npm install
sls deploy -v -s dev
```

## Licença

__MIT License__

Copyright (c) 2019-2020 Vinicius Carvalho

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.