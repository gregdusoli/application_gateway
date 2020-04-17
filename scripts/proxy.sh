#!/bin/bash

clear

if [[  $# -eq 2  ]]; then
  option=$1
  subdomain=$2
fi

echo -e "\033[32m ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "|    ASSISTENTE DE CRIAÇÃO DE REGRAS DE PROXY    |"
echo -e "|________________________________________________|\033[0m"
 
echo -e "\033[32m\nSeja bem-vindo ao Assistente de Criação de regras de Proxy!\033[0m"
echo -e "\033[33mAtravés deste wizard você pode criar uma regra de redirecionamento de requisições para seu novo container de app.\033[0m"

if [[  $option != 1  ]]; then
  echo -e "\033[1m\nPor favor, selecione a ação desejada:\033[0m"
  echo "(1) CRIAR REDIRECIONAMENTO"
  echo "(2) SAIR"
  read option
fi

echo -e "\033[32m ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "| \t\t\t\033[1m AVISO \033[0m\033[32m\t\t\t |"
echo -e "| \t Antes de criar este redirecionamento \t |"
echo -e "| \t é necessário criar o apontamento DNS \t |"
echo -e "|________________________________________________|\033[0m"

echo -e "\033[1m\nPra começar, informe seu Domain Name principal:\033[0m"
read domain

if [[ -z "$subdomain" ]]; then
  echo -e "\033[1m\n- Qual o subdomain desejado? (FQDN = [subdomain].$domain)\033[0m"
  read subdomain
fi

echo -e "\033[1m\n- Para qual porta devo redirecionar as requisições?\033[0m"
read port

echo -e "\033[32m________________________________________________" # 48 characters
echo -e "\t"
echo -e "\033[1m     A seguinte regra de Proxy será criada: \033[0m\033[32m"
echo -e "        FQDN: $subdomain.$domain"
echo -e "        Porta: $port"
echo -e "________________________________________________\033[0m"

echo -e "\033[1m\033[33m\n*NOTA:\033[0m \033[33mpara que a esta regra funcione, é necessário que o container Docker da aplicação esteja rodando na porta de serviço informada no passo anterior."
echo -e "Caso ainda não tenha criado o container da aplicação, não prossiga com este wizard e execute o script 'app.sh'.\033[0m"

echo -e "\033[1m\n- Confirma a criação do item? [S|n]\033[0m"
read confirm

if [[ "$confirm" =~ [sS] ]]; then
  # Acessa o diretório para criação do arquivo com a regra de Proxy
  cd ../nginx/conf.d

  # Cria o arquivo da regra de Proxy
  proxy_file="$subdomain.conf"
  touch $(echo "$proxy_file")

  proxy_rule="server {
    listen 80;
    listen [::]:80;

    server_name  $subdomain.$domain;

    location / {
      proxy_pass http://$subdomain;
      proxy_buffering off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \"upgrade\";
    }
  }"

  # Grava o conteúdo da regra de Proxy no arquivo
  echo "$proxy_rule" >> $proxy_file

  # Acessa o diretório para criação do arquivo com a regra de Proxy
  cd ../upstreams

  # Cria o arquivo da regra de Upstream
  upstream_file="$subdomain.conf"
  touch $(echo "$upstream_file")

  upstream_rule="upstream $subdomain {
    server 172.17.0.1:$port;
  }"

  # Grava o conteúdo da regra de Proxy no arquivo
  echo "$upstream_rule" >> $upstream_file

  # Reinicia o serviço do Nginx e aplica as regras criadas
  docker exec -it nginx_reverseproxy -s reload

  if [[ $? -eq 0 ]]; then
    echo -e "\033[1m\033[32m\nRegras de Stream e Proxy criadas com sucesso!\n\033[0m"
  else 
    echo -e "\033[1m\033[31m\nErro ao criar Regras de Stream e Proxy...\n\033[0m"
  fi
else
  echo -e "\033[1m\033[33m\nCriação da regra cancelada!\n\033[0m"
  exit 0
fi