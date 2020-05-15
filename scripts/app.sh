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

function option1 {
  # Solicita o nome da aplicação que será também o nome do subdiretório (public_html/APP_NAME/)
  echo -e "$bold\n- Informe o nome da nova aplicação (nome semântico em Snake Case - ex: 'api_gateway')$clear"
  read appname

  # Solicita o link do repositório de código
  echo -e "$bold\n- Informe o link do repositório da aplicação$clear"
  read repolink

  # Clona o respositório da aplicação
  $(git clone $repolink $appname )

  # Acessa o diretório da aplicação clonada
  cd $appname

  # Verifica se o arquivo .env.example existe e, caso sim, renomeia para .env
  if [[ -e .env.example ]]; then
    createEnvFile
  fi

  # Executa a função que sube os serviços do container
  dockerComposeUp
}

function option2 {
  # Solicita o local do arquivo docker-compose.yml
  echo -e "$bold\n- Informe o local do arquivo docker-compose.y(a)ml (relativo ao diretório public_html):$clear"
  read dockerfile

  # Confirma o local do arquivo docker-compose.yml
  if [[ -e "$APPGTW_PATH/public_html/${dockerfile}/docker-compose.yml" ]]; then
    echo -e "$green\nO arquivo Docker Compose foi validado em: ($APPGTW_PATH/public_html/${dockerfile}/docker-compose.yml)!\n$clear"

    # Acessa o diretório da aplicação clonada
    cd $dockerfile

  # Acessa o diretório da aplicação clonada
  cd $dockerfile

    # Executa a função que sube os serviços do container
    dockerComposeUp
  else
    echo -e "$bold$red\nO arquivo Docker Compose informado é inválido ou não existe em $APPGTW_PATH/public_html/${dockerfile}\n$clear"
  fi

  # Executa a função que sube os serviços do container
  dockerComposeUp
}

function option3 {
  # Move o cursor para o diretório de scripts
  cd $APPGTW_PATH/scripts/
  
  # Executa o script de criação de regras Proxy
  ./proxy.sh
}

function dockerComposeUp {
  # Verifica a existência de um arquivo 'docker-compose.yml na raiz da aplicação criada'
  if [[ -e ./docker-compose.yml || -e ./docker-compose.yaml ]]; then
    # Executa 'docker-compose up -d' e sobe o container
    echo -e "$green\nO arquivo docker-compose.y(a)ml encontrado na raiz da aplicação, executando serviços do container...\n$clear"
    docker-compose up -d

    # Verifica se a saída do comando anterior gerou algum erro
    if [[ $? -eq 0 ]]; then
      echo -e "$green\nSucesso ao subir os serviços do container da nova aplicação!\n$clear"

      # Executa o script para criação das regras de redirecionamento
      echo -e "$yellow\nPor fim, vamos executar o script de criação das regras de redirecionamento para a nova aplicação...\n$clear"
      
      # Move o cursor para o diretório de scripts
      cd $APPGTW_PATH/scripts/
      ./proxy.sh 1 $appname
      
      # Verifica se a saída do comando anterior gerou algum erro
      if [[ $? -eq 0 ]]; then
        echo -e "$green\nRegras de redirecionamento criadas com sucesso!\n$clear"
      else 
        echo -e "$red\nErro ao aplicar as novas configurações...restart o container do Application Gateway manualmente.\n$clear"
      fi
    else
      echo -e "$red\nNão foi possível subir os serviços do container! Execute este passo manualmente...\n$clear"
    fi
  else 
    echo -e "$yellow\nO arquivo 'docker-compose.y(a)ml' não foi localizado... suba o container manualmente e, a seguir, execute 'npm run proxy' para criar as regras de redirecionamento.\n$clear"
    echo -e "$bold$green\nAplicação criada com sucesso!\n$clear"
    exit 0;
  fi
}

function createEnvFile {
  # Caso exista um arquivo Dotenv, informa ao usuário a respeito e cria o arquivo
  echo -e "$yellow$bold\nA aplicação requer a definição de variáveis ambiente; um arquivo com valores padrão foi criado para que seja possível executar os serviços do container.$clear"
  
  echo -e "$yellow$bold*$clear$yellow Caso necessite alterar alguma varíavel ambiente, faça as alterações no arquivo .env e restart o container manualmente.$clear"

  mv ./.env.example ./.env
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
echo -e "(1) CRIAR NOVA APLICAÇÃO BASEADA EM REPOSITÓRIO"
echo -e "(2) CRIAR NOVA APLICAÇÃO BASEADA EM DOCKERFILE"
echo -e "(3) CRIAR REGRAS DE PROXY PARA APLICAÇÃO EXISTENTE"
echo -e "(S) SAIR"

read option

# Acessa o diretório padrão de projetos para criação da aplicação
cd public_html/

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
  echo -e "| \t NOVA APLICAÇÃO POR DOCKERFILE \t\t |"
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
