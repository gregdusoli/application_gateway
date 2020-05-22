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
PUBLIC_HTML="public_html"

# Define outras variáveis necessárias
APPSVC_TYPE=
APPSVC_NAME=
APPSVC_PATH=

# Formatação de texto
bold="\033[1m"
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
clear="\033[0m"

function option1 {
  # Invoce a function que efine se o tipo do container é 'application' ou 'service'
  setAppSvcType

  # Move o ponteiro para o diretório correspondente ao tipo (application/service)
  cd $APPSVC_TYPE
  
  # Solicita o nome da aplicação que será também o nome do subdiretório (public_html/APP_NAME/)
  echo -e "$bold\n- Qual é o nome do container da aplicação (exatamente o mesmo que está no Docker Compose do container)?$clear"
  read APPSVC_NAME

  # Solicita o link do repositório de código
  echo -e "$bold\n- Qual é o link do repositório da aplicação?$clear"
  read repolink

  # Clona o respositório da aplicação
  $(git clone $repolink $APPSVC_NAME )

  # Testar o resultado do comando git clone, caso haja erro encerra a execução
  if [[ $? == 128 ]]; then
    echo -e "$bold$red\nO repositório informado não existe ou é privado... execução abortada!$clear"
    exit 1
  fi

  # Acessa o diretório da aplicação clonada
  cd $APPSVC_NAME

  # Verifica se o arquivo .env.example existe e, caso sim, renomeia para .env
  if [[ -e .env.example ]]; then
    createEnvFile
  fi

  # Define o caminho absoluto da aplicação
  APPSVC_PATH="$APPGTW_PATH/$PUBLIC_HTML/$APPSVC_TYPE/$APPSVC_NAME"

  # Invoca a execução da function responsável pelo processo de Dockerização
  dockerCompose
}

function option2 {
  # Informa o usuário sobre o local padrão para applications e services
  echo -e "$bold$yellow\nIMPORTANTE: Este script pressupõem que sua aplicação esteja dentro do diretório $APPGTW_PATH/public_html/.$clear"

  # Invoce a function que efine se o tipo do container é 'application' ou 'service'
  setAppSvcType

  # Move o ponteiro para o diretório correspondente ao tipo (application/service)
  cd $APPSVC_TYPE
  
  # Solicita o nome da aplicação que será também o nome do subdiretório (public_html/APP_NAME/)
  echo -e "$bold\n- Qual é o nome do container da aplicação (nome do container Docker, omitido o prefixo de tipo)?$clear"
  read APPSVC_NAME
  
  # Acessa o diretório da aplicação clonada
  if [[ -e $APPSVC_NAME ]]; then
    cd $APPSVC_NAME
  else
    echo -e "$bold$red\nO caminho informado não foi encontrado. Execução abortada!$clear"
    exit 1
  fi

  # Verifica se o arquivo .env.example existe e, caso sim, renomeia para .env
  if [[ -e .env.example ]]; then
    createEnvFile
  fi

  # Define o caminho absoluto da aplicação
  APPSVC_PATH="$APPGTW_PATH/$PUBLIC_HTML/$APPSVC_TYPE/$APPSVC_NAME"

  # Invoca a execução da function responsável pelo processo de Dockerização
  dockerCompose
}

function option3 {
  # Move o cursor para o diretório de scripts
  cd $APPGTW_PATH/scripts/
  
  # Executa o script de criação de regras Proxy
  ./proxy.sh
}

function dockerCompose {
  # Verifica a existência de um arquivo 'docker-compose.yml antes de subir o container para evitar erro'
  if [[ -e "$APPSVC_PATH/docker-compose.yml" || -e "$APPSVC_PATH/docker-compose.yaml" ]]; then
    # Executa 'docker-compose up -d' e sobe o container
    docker-compose up -d

    # Verifica se a saída do comando anterior gerou algum erro
    if [[ $? -eq 0 ]]; then
      echo -e "$green\nSucesso ao subir os serviços do container da nova aplicação!\n$clear"

      # Executa o script para criação das regras de redirecionamento
      echo -e "$yellow\nPor fim, vamos executar o script de criação das regras de redirecionamento para a nova aplicação...\n$clear"
      
      # Move o cursor para o diretório raiz do Application Gateway
      cd $APPGTW_PATH

      # Invoca o script de criação das regras de Streams e Proxy
      ./scripts/proxy.sh 1 "$APPSVC_TYPE-$APPSVC_NAME"
      
      # Verifica se a saída do comando anterior gerou algum erro
      if [[ $? -eq 0 ]]; then
        echo -e "$green\nRegras de redirecionamento criadas com sucesso!\n$clear"
      else 
        echo -e "$red\nErro ao aplicar as novas configurações...verifique possíveis inconsistências em seu application/service.\n$clear"
      fi
    else
      echo -e "$red\nNão foi possível subir os serviços do container... execute este passo manualmente.\n$clear"
    fi
  else 
    echo -e "$yellow\nArquivo docker-compose.yml não localizado! Revise seu application/service e execute manualmente os passos restantes.\n$clear"
    echo -e "$bold\nApplication/Service criado com sucesso, porém a execução gerou alerta(s)!\n$clear"
    exit 0;
  fi
}

function createEnvFile {
  # Caso exista um arquivo Env, informa ao usuário a respeito e cria o arquivo
  echo -e "$yellow$bold\nA aplicação requer a definição de variáveis ambiente; um arquivo Env conforme o exemplo foi criado para que seja possível executar os serviços do container.$clear"
  
  mv ./.env.example ./.env

  echo -e "$yellow$bold$clear$yellow\nForneça os dados requeridos pelo arquivo Env, em seguida, execute este script novamente selecionando a opção 2.\n$clear"
  exit 0
}

function setAppSvcType {
  echo -e "$bold\n- O container que você vai implementar é de qual tipo?$clear"
  echo -e "(Em caso de dúvida, considere de maneira generalista 'application' como software com UI e 'service' como software sem UI)"
  echo -e " - Application \t(1)"
  echo -e " - Service \t(2)"

  optiontype=0
  while [ $optiontype == 0 ] || [ $optiontype -gt 2 ]; do
    echo -e "$bold Digite a opção correspondente:$clear"
    read optiontype
  done

  case $optiontype in
    1) APPSVC_TYPE='application';;
    2) APPSVC_TYPE='service';;
    *) APPSVC_TYPE='Tipo de inválido';;
  esac
}

##################################
#       BEGIN SCRIPT EXEC        #
##################################

echo -e "$green ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "| \t ASSISTENTE DE CRIAÇÃO DE APPS \t\t |"
echo -e "|________________________________________________|$clear"

echo -e "$green\nSeja bem-vindo ao Assistente de Criação de Containers de Aplicação!$clear"
echo -e "$yellow\nAtravés deste wizard você pode criar uma nova aplicação ou iniciar um projeto baseado em um repositório Git.$clear"

echo -e "$bold\nPor favor, selecione a ação desejada:$clear"
echo -e "(1) CRIAR NOVA APLICAÇÃO BASEADA EM REPOSITÓRIO REMOTO"
echo -e "(2) CRIAR NOVA APLICAÇÃO BASEADA EM DOCKER-COMPOSE LOCAL"
echo -e "(3) CRIAR REGRAS DE PROXY PARA APLICAÇÃO LOCAL EXISTENTE"
echo -e "(?) SAIR"

read option

# Acessa o diretório padrão de projetos para criação da aplicação
cd "$APPGTW_PATH/$PUBLIC_HTML"

if [[ $option == 1 ]]; then

  echo -e "$green ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo -e "| \t NOVA APLICAÇÃO POR REPOSITÓRIO \t |"
  echo -e "|________________________________________________|$clear"

  echo -e "$yellow\nEste wizard realiza as seguintes ações:"
  echo    " - clona o respositório Git da aplicação"
  echo    " - procura por um arquivo 'docker-compose.yml' no diretório da aplicação"
  echo    " - executa o comando 'docker-compose up -d' para subir o container da aplicação"
  echo -e " - executa o script para criar as regras de redirecionamento da aplicação$clear"

  option1
elif [[ $option == 2 ]]; then
  
  echo -e "$green ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo -e "| \t NOVA APLICAÇÃO POR DOCKER-COMPOSE \t |"
  echo -e "|________________________________________________|$clear"

  option2
elif [[ $option == 3 ]]; then

  echo -e "$green ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo    "| \t REGRAS PARA APLICAÇÃO EXISTENTE \t\t |"
  echo -e "|________________________________________________|$clear"

  option3
else

  echo -e "$bold$yellow\nCriação da aplicação cancelada!\n$clear"
  exit 0
fi
