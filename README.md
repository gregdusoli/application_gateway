# Application Gateway

Este Application Gateway visa prover um ecossistema de aplicações e serviços, fornecendo criação de regras proxy, upstreams, controle de tráfego e gerenciamento de requisições centralizados.

---

### Features

- Nginx servindo como gateway de requisições HTTP/HTTPS (certicação SSL a ser implementada)
- Reverse Proxy atuando no redirecionamento de incoming traffic para portas de serviço correspondentes
- Load Balancer para gerenciamento e equalização do volume de tráfego (a ser implementado)
- Automation scripts para realizar migração/criação de aplicações que deverão ser gerenciadas pelo Application Gateway

---

### Estrutura do projeto

- nginx : Diretório de armazenamento dos arquivos necessários ao funcionamento do Application Gateway
- nginx/config: Diretório que contém os arquicos de configuração do servidor
- nginx/conf.d: Diretório para as configurações de rotas de requisições
- nginx/upstreams: Diretório para conter as regras de upstreams de aplicações
- nginx/ssl : Diretório para armazenamento dos certificados SSL
- scripts : Diretório dos scripts para automatização do processo de migração/criação de aplicações

---

### Preparação do Ambiente

#### (\*) As aplicações/serviços que serão gerenciados pelo Application Gateway devem estar Dockerizados

1. Este Application Gateway deve estar localizado na raiz de diretórios do usuário (~/), caso não esteja, isso deve ser corrigido antes de prosseguir
2. Renomear o arquivo .env.example para .env e fornecer os dados que ele solicita
3. O Application Gateway espera que as aplicações/serviços a serem expostos externamente estejam na pasta 'public_html', na raiz do usuário. Caso não exista, crie:
```$ cd ~/ && mkdir public_html```
4. Preparação dos containers de aplicação
   - Para que o processo seja totalmente automatizado, é necessário que o arquivo 'docker-compose.yml' esteja na raiz do diretório da aplicação
   - Ao criar uma aplicação (utilizando os scripts de automação ou não), seu nome deve ser definido com letras minúsculas. Em caso de nome composto, deve ser adotada a convenção [Snake Case](https://medium.com/better-programming/string-case-styles-camel-pascal-snake-and-kebab-case-981407998841).
   - Para que a comunicação e as regras de Proxy Reverso possam funcionar, cada container deve ser colocado na mesma rede do container do Application Gateway ao qual pertence
5. Configuração do DNS
   - Para que as aplicações respondam às requisições, é necessário criar uma entrada do tipo AAA no gerenciador de Zona DNS do domínio vinculado, apontando para o IP público do Application Gateway

---

### Migração/Criação de aplicação

#### (\*) Pressupoe-se que passo Preparação do Cenário tenha sido cumprido.

1. Para iniciar a migração ou criação de uma aplicação, acesse o host do Application Gateway
2. Acesse o diretório do Application Gateway: ```$ cd ~/application_gateway```
2. Execute o script de automação com o comando ```$ ./scripts/app.sh```
3. Selecione uma entre as duas opções fornecidas pelo wizard:
   1. App baseado em repositório Git
      - Será necessário informar a URL do repositório da aplicação a ser migrada ou criada
   2. App baseado em docker-compose.yml pré-existente
      - Primeiramente, os arquivos da aplicação devem ser colocados em pasta que possua o mesmo nome do container (definido no docker-compose.yml), dentro do diretório 'public_html'
      - Quando solicitado, informe ao wizard a localização do arquivo 'docker-compose.yml' (local do passo anterior)
   3. App pré-existente
      - Esta opção possibilita a criação das regras de proxy para uma aplicação existente
___
(\*) Em todos os casos, o script considera que a aplicação esteja em um subdiretório de 'public_html'
(\*\*) Após execução do script, o Application Gateway será reiniciado automaticamente e as regras devem funcionar imediatamente.
(\*\*\*) Caso algum erro do tipo 500 ocorra, talvez seja necessário aguardar pela propagação da nova regra DNS.

