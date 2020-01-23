# Nginx Service Gateway
Service Gateway que visa centralizar todas as aplicações pertinentes ao ecossistema tecnológico da EuQueroInvestir.

---
### Features
- Web Server atuando como gateway de requisições HTTP/HTTPS
- Reverse Proxy atuando no redirecionamento de incoming traffic para portas de serviço correspondentes
- Load Balancer que gerencia e equaliza o volume de incoming traffic
- Automator scripts para rápida migração/criação de aplicações que deverão ser servidas pelo Service Gateway

---
### Estrutura do projeto
- nginx : Diretório de armazenamento dos arquivos necessários ao funcionamento do Service Gateway
- nginx/ssl : Diretório para armazenamento dos certificados SSL
- public_html : Diretório onde devem ser colocadas as aplicações que serão servidas pelo Service Gateway
- scripts : Diretório dos scripts para automatização do processo de migração/criação de aplicações

---
### Preparação do Ambiente

#### (*) As aplicações que serão servidas pelo Nginx devem ser encapsuladas em containers Docker

1. Preparação do container de aplicação
   - para que o processo seja totalmente automatizado, é necessário que o arquivo 'docker-compose.y(a)ml' esteja na raiz do repositório Git
   - cada aplicação deve responder em uma porta de serviço específica e individual. Certifique-se desse detalhe para que não haja conflitos indesejados
   - Para que a comunicação e as regras de Proxy Reverso possam funcionar, cada container deve ser colocado na rede 'azure'

2. Configuração do DNS
   - Para que nova a aplicação responda às requisições, é necessário criar um apontamento do tipo AAA no registro DNS da CloudFlare direcionando o nome escolhido para a aplicação para o IP do Service Gateway 40.112.221.80

---
### Migração/Criação de aplicação

#### (*) Pressupoe-se que passo Preparação do Cenário tenha sido cumprido.

1. Para iniciar a migração ou criação de uma aplicação, faça login no Service Gateway
2. Na raiz do diretório do usuário, execute o comando ```$ npm run app```
3. Selecione uma entre as duas opções fornecidas pelo wizard:
   1. App baseado em repositório Git
      - Será necessário informar a URL do repositório da aplicação a ser migrada ou criada
   2. App baseado em dockerfile local
      - Primeiramente, os arquivos da aplicação devem ser colocados em pasta que possua o mesmo nome do container (definido no docker-compose.y(a)ml), dentro do diretório 'public_html'
      - Quando solicitado, informe ao wizard a localização do arquivo 'docker-compose.y(a)ml' (local do passo anterior)
   3. App pré-existente
      - Esta opção possibilita a criação das regras de proxy para uma aplicação existente

\
(*)  *Em todos os casos, o script considera que a aplicação esteja em um subdiretório de 'public_html'* \
(\*\*) *Após execução do script, o Service Gateway será reiniciado automaticamente e as regras devem funcionar imediatamente.* \
(\*\*\*) *Caso algum erro do tipo 500 ocorra, talvez seja necessário aguardar pela propagação da nova regra DNS.*

---
**IMPORTANTE**

A instância do Docker instalada no host (VM Azure) deve ter a interface de rede com IP fixado para 172.17.0.1.