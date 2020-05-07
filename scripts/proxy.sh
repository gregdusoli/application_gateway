#!/bin/bash

clear

# Define o Path de instalação do Application Gateway
APPGTW_PATH=$PWD

# Formatação de texto
bold="\033[1m"
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
clear="\033[0m"

if [[  $# -eq 2  ]]; then
  option=$1
  subdomain=$2
fi

echo -e "$green ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "|    ASSISTENTE DE CRIAÇÃO DE REGRAS DE PROXY    |"
echo -e "|________________________________________________|$clear"
 
echo -e "$green\nSeja bem-vindo ao Assistente de Criação de regras de Proxy!$clear"
echo -e "$yellow\nAtravés deste wizard você pode criar uma regra de redirecionamento de requisições para seu novo container de app.$clear"

if [[  $option != 1  ]]; then
  echo -e "$bold\nPor favor, selecione a ação desejada:$clear"
  echo "(1) CRIAR REDIRECIONAMENTO"
  echo "(2) SAIR"
  read option
fi

echo -e "$green ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "| \t\t\t$bold AVISO $clear$green\t\t\t |"
echo -e "| \t Antes de criar este redirecionamento \t |"
echo -e "| \t é necessário criar o apontamento DNS \t |"
echo -e "|________________________________________________|$clear"

echo -e "$bold\nPra começar, informe seu Domain Name principal:$clear"
read domain

if [[ -z "$subdomain" ]]; then
  echo -e "$bold\n- Qual o subdomain desejado? (FQDN = [subdomain].$domain)$clear"
  read subdomain
fi

echo -e "$bold\n- Para qual porta devo redirecionar as requisições?$clear"
read port

echo -e "$green ________________________________________________" # 48 characters
echo -e "\t"
echo -e "$bold     A seguinte regra de Proxy será criada: $clear$green"
echo -e "        FQDN: $subdomain.$domain"
echo -e "        Porta: $port"
echo -e "________________________________________________$clear"

echo -e "$bold$yellow\n*NOTA:$clear \033[33mpara que a esta regra funcione, é necessário que o container Docker da aplicação esteja rodando na porta de serviço informada no passo anterior."
echo -e "Caso ainda não tenha criado o container da aplicação, não prossiga com este wizard e execute o script 'app.sh'.$clear"

echo -e "$bold\n- Confirma a criação do item? [S|n]$clear"
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
    echo -e "$bold$green\nRegras de Stream e Proxy criadas com sucesso!\n$clear"
  else 
    echo -e "$bold$red\nErro ao criar Regras de Stream e Proxy...\n$clear"
  fi
else
  echo -e "$bold$yellow\nCriação da regra cancelada!\n$clear"
  exit 0
fi