#!/bin/bash

clear

# Define os paths de instalação do Application Gateway e projetos
pwdir=$(dirname "$0")
if [[ "$pwdir" =~ ["./"] ]]; then
  if [[ "$pwdir" =~ ["scripts"] ]]; then
    pwdir=$(pwd)
  else 
    cd ..
    pwdir=$(pwd)
  fi
fi
APPGTW_PATH=$pwdir
APPSVC_PATH="public_html"

# Define outras variáveis necessária
if [[ $# -gt 1 ]]; then
  APPSVC_TYPE=$2
  APPSVC_NAME=$3
else
  APPSVC_TYPE=
  APPSVC_NAME=
fi
SUBDOMAIN=
PORT=

# Formatação de texto
bold="\033[1m"
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
clear="\033[0m"

function option1 {
  # Solicita o nome do domínio principal do servidor (CN = Canonical Name)
  echo -e "$bold\nPra começar, informe o Canonical Name que deseja usar (Nome raiz de domínio):$clear"
  read domain

  # Solicita o nome do subdomínio associado a application/service do usuário
  echo -e "$bold\n- Qual subdomínio você quer vincular ao container ([subdomain].$domain)?$clear"
  read SUBDOMAIN

  # Verifica se a informação do path do application/service foi recebido como parâmetro do script app.sh
  if [[ -z $APPSVC_NAME ]]; then
    echo -e "$bold\n- Qual é o nome do container da aplicação (exatamente o mesmo que está no Docker Compose do container)?$clear"
    read APPSVC_NAME
  fi
  
  # Acessa o diretório da aplicação clonada
  if [[ -e $APPSVC_NAME ]]; then
    cd $APPSVC_NAME
  else
    echo -e "$bold$red\nO caminho informado não foi encontrado. Execução abortada!$clear"
    exit 1
  fi

  echo -e "$bold\n- Em qual porta sua aplicação está escutando (para redirecionamento de requisições)?$clear"
  read PORT

  echo -e "$green ________________________________________________" # 48 characters
  echo -e "\t"
  echo -e "$bold     A seguinte regra de Proxy será criada: $clear$green"
  echo -e "        FQDN: $SUBDOMAIN.$domain "
  echo -e "        Container: $APPSVC_NAME:$PORT "
  echo -e "________________________________________________$clear"

  echo -e "$bold$yellow\n*NOTA:$clear \033[33mCaso ainda não tenha criado o container da aplicação, não prossiga com este wizard e execute o script 'app.sh'.$clear"

  echo -e "$bold\n- Confirma a criação do item? [S|n]$clear"
  read confirm

  if [[ "$confirm" =~ [sS] ]]; then
    # Invoca as functions que criar os arquivos de Stream e Proxy
    proxyFileCreate
    upstreamFileCreate
    
    # Valida as regras criadas e somente prossegue em caso de sucesso
    cd $APPGTW_PATH
    echo $(docker-compose exec service-application_gateway nginx -t)
    
    # Testa as regras criadas e se tudo estiver ok, reinicia o serviço do Nginx
    if [[ $? -eq 0 ]]; then
      echo $(docker-compose exec service-application_gateway nginx -s reload)

      if [[ $? -eq 0 ]]; then
        echo -e "$green\nRegras de Stream e Proxy criadas com sucesso!\n$clear"
      fi
    else
      echo -e "$bold$red\nOcorreu um erro ao criar as regras de Stream e Proxy!\nO script foi abortado...$clear"
      exit 1
    fi
  else
    echo -e "$bold$yellow\nCriação da regra cancelada!\n$clear"
    exit 0
  fi
}

function proxyFileCreate {
  # Monta a regra de Proxy antes da criação do arquivo
  proxy_rule="server {
    listen 80;
    listen [::]:80;

    server_name $SUBDOMAIN.eqi.life;

    location / {
      proxy_pass http://$SUBDOMAIN;
      access_log logs/$SUBDOMAIN.access.log;
    }
  }"

  # Antes de criar o arquivo, verifica se já existe um com mesmo nome e deleta
  proxy_file="$APPGTW_PATH/nginx/conf.d/$SUBDOMAIN.conf"
  
  if [[ -e "$proxy_file" ]]; then
    rm "$proxy_file"
  fi

  touch "$proxy_file"

  # Grava o conteúdo da regra de Proxy no arquivo
  echo "$proxy_rule" >> $proxy_file

  # Retorna o status da criação do arquivo
  if [[ -e $proxy_file ]]; then
    echo -e "$green\nO arquivo $proxy_file foi criado com sucesso!$clear"
  else
    echo -e "$red\nErro ao criar arquivo $proxy_file...$clear"
  fi
}

function upstreamFileCreate {
  # Monta a regra de Upstream antes da criação do arquivo
  upstream_rule="upstream $SUBDOMAIN {
    server $APPSVC_NAME:$PORT;
  }"

  # Antes de criar o arquivo, verifica se já existe um com mesmo nome e deleta
  upstream_file="$APPGTW_PATH/nginx/upstreams/$SUBDOMAIN.conf"
  
  if [[ -e "$upstream_file" ]]; then
    rm "$upstream_file"
  fi

  touch "$upstream_file"

  # Grava o conteúdo da regra de Proxy no arquivo
  echo "$upstream_rule" >> $upstream_file

  # Retorna o status da criação do arquivo
  if [[ -e $upstream_file ]]; then
    echo -e "$green\nO arquivo $upstream_file foi criado com sucesso!$clear"
  else
    echo -e "$red\nErro ao criar arquivo $upstream_file...$clear"
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

# Caso o script tenha recebido algum argumento, não exibe o menu principal
if [[ $# -lt 1 ]]; then
  echo -e "$bold\nPor favor, selecione a ação desejada:$clear"
  echo "(1) CRIAR REDIRECIONAMENTO"
  echo "(?) SAIR"
fi

# Antes de receber a opção do usuário, verifica se ela não foi enviada como argumento 
if [ $# -gt 0 ]; then
  option=$1
else
  read option
fi

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

