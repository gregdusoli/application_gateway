# Application Gateway

Este Application Gateway visa prover um ecossistema de aplicações, fornecendo criação de regras proxy, upstreams, controle de tráfego e gerenciamento de requisições centralizados.

---

### Features

- Nginx servindo como gateway de requisições HTTP/HTTPS (certicação SSL a ser implementada)
- Reverse Proxy atuando no redirecionamento de incoming traffic para portas de serviço correspondentes
- Load Balancer para gerenciamento e equalização do volume de tráfego (a ser implementado)
- Automation scripts para realizar migração/criação de aplicações que deverão ser gerenciadas pelo Application Gateway

---

### Estrutura do projeto

- nginx : Diretório de armazenamento dos arquivos necessários ao funcionamento do Application Gateway
- nginx/ssl : Diretório para armazenamento dos certificados SSL
- public_html : Diretório onde devem ser colocadas as aplicações que serão gerenciadas pelo Application Gateway
- scripts : Diretório dos scripts para automatização do processo de migração/criação de aplicações

---

### Preparação do Ambiente

#### (\*) As aplicações que serão gerenciads pelo Application Gateway devem ser encapsuladas em containers Docker

1. Preparação do container de aplicação

   - para que o processo seja totalmente automatizado, é necessário que o arquivo 'docker-compose.y(a)ml' esteja na raiz do repositório Git
   - cada aplicação deve responder em uma porta de serviço específica e individual. Certifique-se desse detalhe para que não haja conflitos indesejados
   - Para que a comunicação e as regras de Proxy Reverso possam funcionar, cada container deve ser colocado na mesma rede do container do Application Gateway

2. Configuração do DNS
   - Para que as aplicações respondam às requisições, é necessário criar uma entrada do tipo AAA no gerenciador de Zona DNS do domínio vinculado, apontando para o IP público do Application Gateway

---

### Migração/Criação de aplicação

#### (\*) Pressupoe-se que passo Preparação do Cenário tenha sido cumprido.

1. Para iniciar a migração ou criação de uma aplicação, acesse o host do Application Gateway
2. Na raiz do diretório do Application Gateway, execute o comando `$ npm run app` ou `$ ./app.sh`
3. Selecione uma entre as duas opções fornecidas pelo wizard:
   1. App baseado em repositório Git
      - Será necessário informar a URL do repositório da aplicação a ser migrada ou criada
   2. App baseado em dockerfile local
      - Primeiramente, os arquivos da aplicação devem ser colocados em pasta que possua o mesmo nome do container (definido no docker-compose.y(a)ml), dentro do diretório 'public_html'
      - Quando solicitado, informe ao wizard a localização do arquivo 'docker-compose.y(a)ml' (local do passo anterior)
   3. App pré-existente
      - Esta opção possibilita a criação das regras de proxy para uma aplicação existente

\
(*) *Em todos os casos, o script considera que a aplicação esteja em um subdiretório de 'public_html'* \
(\*\*) *Após execução do script, o Application Gateway será reiniciado automaticamente e as regras devem funcionar imediatamente.* \
(\*\*\*) *Caso algum erro do tipo 500 ocorra, talvez seja necessário aguardar pela propagação da nova regra DNS.\*

---

**IMPORTANTE**

Certifique-se que a instância do Docker instalada no seu host tenha a interface de rede definida com o IP 172.17.0.1.
