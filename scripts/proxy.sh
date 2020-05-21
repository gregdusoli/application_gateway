#!/bin/bash

clear

# Define o Path de instalação do Application Gateway
APPGTW_PATH=$(echo -e ~/application_gateway)

# Formatação de texto
bold="\033[1m"
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
clear="\033[0m"

# Associa variáveis locais aos parâmetros recebidos do caller
if [[  $# -eq 3  ]]; then
  option=$1
  subdomain=$2
  appname=$3
fi

function option1 {
  # Solicita o nome do domínio principal do servidor (CN = Canonical Name)
  echo -e "$bold\nPra começar, informe o Canonical Name que deseja usar (Nome raiz de domínio):$clear"
  read domain

  if [[ -z "$subdomain" ]]; then
    echo -e "$bold\n- Qual subdomínio deve ser vinculado? (FQDN = [subdomain].$domain)$clear"
    read subdomain
  fi

  if [[ -z "$appname" ]]; then
    echo -e "$bold\n- Qual o nome do container da aplicação? (Você deve informar exatamente o mesmo que consta no Docker Compose do container)$clear"
    read appname
  fi

  echo -e "$bold\n- Em qual porta sua aplicação está escutando (para redirecionamento de requisições)?$clear"
  read port

  echo -e "$green ________________________________________________" # 48 characters
  echo -e "\t"
  echo -e "$bold     A seguinte regra de Proxy será criada: $clear$green"
  echo -e "        FQDN: $subdomain.$domain"
  echo -e "        Container: $appname:$port"
  echo -e "________________________________________________$clear"

  echo -e "$bold$yellow\n*NOTA:$clear \033[33mCaso ainda não tenha criado o container da aplicação, não prossiga com este wizard e execute o script 'app.sh'.$clear"

  echo -e "$bold\n- Confirma a criação do item? [S|n]$clear"
  read confirm

  if [[ "$confirm" =~ [sS] ]]; then
    # Acessa o diretório para criação do arquivo com a regra de Proxy
    cd conf.d

    # Cria o arquivo da regra de Proxy
    proxy_file="$subdomain.conf"
    touch $(echo "$proxy_file")

    proxy_rule="server {
      listen 80;
      listen [::]:80;

      server_name $subdomain.eqi.life;

      location / {
        proxy_pass http://$subdomain;
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
      server $appname:$port;
    }"

    # Grava o conteúdo da regra de Proxy no arquivo
    echo "$upstream_rule" >> $upstream_file

    # Valida as regras criadas e somente prossegue em caso de sucesso
    cd $APPGTW_PATH
    echo $(docker-compose exec service-application_gateway nginx -t)
    
    if [[ $? -eq 1 ]]; then
      echo -e "$red$bold\nOcorreu um erro ao criar as regras de Stream e Proxy!\nO script foi abortado...$clear"
      exit 1
    fi

    # Reinicia o serviço do Nginx e aplica as regras criadas
    echo $(docker-compose exec service-application_gateway nginx -s reload)

    if [[ $? -eq 0 ]]; then
      echo -e "$bold$green\nRegras de Stream e Proxy criadas com sucesso!\n$clear"
    fi
  else
    echo -e "$bold$yellow\nCriação da regra cancelada!\n$clear"
    exit 0
  fi
}

##################################
#       BEGIN SCRIPT EXEC        #
##################################

echo -e "$green ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "|    ASSISTENTE DE CRIAÇÃO DE REGRAS DE PROXY    |"
echo -e "|________________________________________________|$clear"

echo -e "$green\nSeja bem-vindo ao Assistente de Criação de regras de Proxy!$clear"
echo -e "$yellow\nAtravés deste wizard você pode criar uma regra de redirecionamento de requisições para seu novo container de app.$clear"

echo -e "$bold\nPor favor, selecione a ação desejada:$clear"
echo "(1) CRIAR REDIRECIONAMENTO"
echo "(?) SAIR"

read option

# Acessa o diretório de configurações do Nginx
cd $APPGTW_PATH/nginx/

if [[  $option == 1  ]]; then

  echo -e "$green ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo -e "| \t\t\t$bold AVISO $clear$green\t\t\t |"
  echo -e "| \t Antes de criar este redirecionamento \t |"
  echo -e "| \t é necessário criar o apontamento DNS \t |"
  echo -e "|________________________________________________|$clear"

  option1
else

  echo -e "$bold$yellow\nCriação das regras cancelada!\n$clear"
  exit 0
fi

