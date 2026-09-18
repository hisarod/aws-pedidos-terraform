# AWS Pedidos Terraform

Projeto desenvolvido no **Capacita iRede**, utilizando Terraform para criar uma infraestrutura na AWS e uma aplicação de pedidos integrada ao Amazon SQS, AWS Lambda e CloudWatch.

## Tecnologias utilizadas

* Terraform
* Amazon VPC
* Amazon EC2
* Amazon SQS
* AWS Lambda
* Amazon CloudWatch
* Python
* Git e GitHub

---

## 1. Objetivo do projeto

O objetivo deste projeto é desenvolver uma aplicação de pedidos utilizando APIs em Python e uma infraestrutura definida como código com Terraform.

A aplicação possui dois fluxos principais:

* Consulta de produtos;
* Criação de pedidos.

Quando um pedido é criado, ele deve ser enviado para uma fila do Amazon SQS. A AWS Lambda recebe a mensagem da fila e registra o processamento no Amazon CloudWatch.

---

## 2. Arquitetura da solução

```text
                    Usuário
                       |
                       v
                    Amazon EC2
                       |
             ---------------------
             |                   |
             v                   v
       API de Produtos     API de Pedidos
                                 |
                                 v
                         Amazon SQS
                    pedidos-a-processar
                                 |
                                 v
                            AWS Lambda
                                 |
                                 v
                         CloudWatch Logs
```

### Componentes da arquitetura

#### VPC

Rede virtual utilizada para organizar os recursos da aplicação.

#### Subnet pública

Rede pública onde a instância EC2 será executada.

#### Internet Gateway

Permite a comunicação da subnet pública com a internet.

#### Route Table

Responsável por definir a rota de saída da subnet para a internet.

#### Security Group

Grupo de segurança da EC2 com regras para:

* HTTP: porta 80;
* SSH: porta 22;
* Saída de tráfego para a internet.

#### Amazon EC2

Instância responsável por executar as APIs da aplicação.

#### Amazon SQS

Fila responsável por armazenar os pedidos recebidos pela API.

Nome da fila:

```text
pedidos-a-processar
```

#### AWS Lambda

Função responsável por receber e processar as mensagens enviadas para a fila SQS.

#### Amazon CloudWatch

Serviço utilizado para registrar e consultar os logs da função Lambda.

---

## 3. Estrutura do projeto

```text
aws-pedidos-terraform
│
├── api
│   ├── app.py
│   ├── requirements.txt
│   └── README.md
│
├── lambda
│   └── lambda_function.py
│
├── terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── sqs.tf
│   ├── lambda.tf
│   └── .terraform.lock.hcl
│
├── evidencias
│
├── .gitignore
└── README.md
```

---

## 4. Pré-requisitos

Antes de executar o projeto, instale:

* Terraform;
* AWS CLI;
* Python;
* Git;
* Conta AWS ou ambiente de laboratório autorizado.

Verifique as instalações:

```bash
terraform version
aws --version
python --version
git --version
```

---

## 5. Configuração da AWS

Configure suas credenciais utilizando um usuário IAM autorizado ou o ambiente de laboratório fornecido pelo professor.

```bash
aws configure
```

Informe:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

Região utilizada no projeto:

```text
us-east-1
```

> Não utilize ou publique credenciais do usuário Root. Nunca envie Access Keys, Secret Keys ou senhas para o GitHub.

---

## 6. Como executar o Terraform

Entre na pasta do Terraform:

```bash
cd terraform
```

Inicialize o Terraform:

```bash
terraform init
```

Formate os arquivos:

```bash
terraform fmt
```

Valide a configuração:

```bash
terraform validate
```

Visualize o plano de execução:

```bash
terraform plan
```

Para criar os recursos na AWS:

```bash
terraform apply
```

Confirme a operação quando solicitado.

> Atenção: o comando `terraform apply` cria recursos reais na AWS e pode gerar custos. Execute somente em uma conta autorizada, laboratório ou ambiente com créditos.

---

## 7. Como acessar a aplicação na EC2

Após a criação da infraestrutura, consulte os recursos no console da AWS.

### Passos

1. Acesse o serviço Amazon EC2;
2. Abra a instância criada;
3. Verifique se ela está em execução;
4. Copie o endereço IPv4 público;
5. Acesse a aplicação pelo navegador ou pelo terminal.

Exemplo:

```text
http://IP_PUBLICO_DA_EC2
```

API de produtos:

```text
http://IP_PUBLICO_DA_EC2/produtos
```

API de pedidos:

```text
http://IP_PUBLICO_DA_EC2/pedidos
```

Substitua `IP_PUBLICO_DA_EC2` pelo endereço real da instância.

---

## 8. Como testar a API de Produtos

A API de produtos utiliza o método HTTP `GET`.

```bash
curl http://IP_PUBLICO_DA_EC2/produtos
```

Exemplo de resposta:

```json
[
  {
    "id": 1,
    "nome": "Notebook",
    "preco": 3500.00
  },
  {
    "id": 2,
    "nome": "Mouse",
    "preco": 80.00
  }
]
```

---

## 9. Como testar a API de Pedidos

A API de pedidos utiliza o método HTTP `POST`.

Exemplo:

```bash
curl -X POST http://IP_PUBLICO_DA_EC2/pedidos \
  -H "Content-Type: application/json" \
  -d "{\"produto_id\":1,\"quantidade\":2}"
```

### Fluxo esperado

```text
1. A API recebe o pedido;
2. O pedido é enviado para o Amazon SQS;
3. A mensagem fica disponível na fila;
4. A AWS Lambda recebe a mensagem;
5. A Lambda processa o pedido;
6. O CloudWatch registra o log da execução.
```

---

## 10. Como verificar a mensagem no SQS

No console da AWS:

1. Acesse o serviço Amazon SQS;
2. Abra a fila `pedidos-a-processar`;
3. Selecione a opção de enviar e receber mensagens;
4. Consulte as mensagens disponíveis;
5. Verifique os dados do pedido enviado pela API.

Exemplo de mensagem:

```json
{
  "produto_id": 1,
  "quantidade": 2
}
```

---

## 11. Como verificar os logs da Lambda

No console da AWS:

1. Acesse o serviço AWS Lambda;
2. Abra a função criada pelo Terraform;
3. Acesse a área de monitoramento;
4. Abra os logs no Amazon CloudWatch;
5. Consulte a execução da função.

Exemplo de log esperado:

```text
Pedido recebido:
{"produto_id": 1, "quantidade": 2}
```

---

## 12. Evidências da atividade

As evidências devem ser adicionadas à pasta `evidencias`.

### Evidência 1 — EC2 com aplicação rodando

Print da instância EC2 em execução e da aplicação acessada.

Arquivo sugerido:

```text
evidencias/01-ec2-aplicacao.png
```

### Evidência 2 — Mensagem chegando no SQS

Print da fila `pedidos-a-processar` contendo a mensagem do pedido.

Arquivo sugerido:

```text
evidencias/02-mensagem-sqs.png
```

### Evidência 3 — Log da Lambda no CloudWatch

Print do log da Lambda mostrando o pedido recebido.

Arquivo sugerido:

```text
evidencias/03-log-lambda-cloudwatch.png
```

### Evidência 4 — Saída do Terraform Apply

Print do terminal mostrando a execução:

```bash
terraform apply
```

Arquivo sugerido:

```text
evidencias/04-terraform-apply.png
```

### Evidência 5 — Teste das APIs

Print dos testes das APIs de produtos e pedidos.

Arquivo sugerido:

```text
evidencias/05-teste-apis.png
```

> As evidências devem representar execuções reais. Não adicione prints simulados como se fossem recursos reais da AWS.

---

## 13. Como destruir os recursos

Após finalizar os testes, remova os recursos criados pelo Terraform:

```bash
terraform destroy
```

Confirme a operação quando solicitado.

> Execute o `terraform destroy` para evitar que os recursos continuem gerando possíveis cobranças.

---

## 14. Validação local

A configuração Terraform pode ser validada localmente com:

```bash
terraform fmt
terraform validate
```

Resultado esperado:

```text
Success! The configuration is valid.
```

---

## 15. Status do projeto

O código Terraform foi organizado para representar a infraestrutura da aplicação.

A execução real na AWS depende de uma conta autorizada, laboratório ou ambiente com créditos disponíveis.

---

## Autora

**Heloísa Fernandes Rodrigues**

Projeto desenvolvido no **Capacita iRede**.
