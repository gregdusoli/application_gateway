#!/bin/bash

clear

function option1 {
  # Solicita o nome da aplicação que será também o nome do subdiretório (public_html/APP_NAME/)
  echo -e "\033[1m\n- Informe o nome da nova aplicação (nome semântico em Kebab Case - ex: 'novo-app')\033[0m"
  read appname

  # Solicita o link do repositório de código
  echo -e "\033[1m\n- Informe o link do repositório da aplicação\033[0m"
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
  echo -e "\033[1m\n- Informe o local do arquivo docker-compose.y(a)ml (relativo ao diretório public_html):\033[0m"
  read dockerfile

  # Confirma o local do arquivo docker-compose.yml
  echo -e "\033[32m\nO local do arquivo está correto: (public_html/${dockerfile}/docker-compose.yml)?\n\033[0m"

  # Acessa o diretório da aplicação clonada
  cd $dockerfile

  # Verifica se o arquivo .env.example existe e, caso sim, renomeia para .env
  if [[ -e .env.example ]]; then
    createEnvFile
  fi

  # Executa a função que sube os serviços do container
  dockerComposeUp
}

function option3 {
  cd ../scripts
  ./proxy.sh
}

function dockerComposeUp {
  # Verifica a existência de um arquivo 'docker-compose.yml na raiz da aplicação criada'
  if [[ -e ./docker-compose.yml || -e ./docker-compose.yaml ]]; then
    # Executa 'docker-compose up -d' e sobe o container
    echo -e "\033[32m\nO arquivo docker-compose.y(a)ml encontrado na raiz da aplicação, executando serviços do container...\n\033[0m"
    docker-compose up -d

    # Verifica se a saída do comando anterior gerou algum erro
    if [[ $? -eq 0 ]]; then
      echo -e "\033[32m\nSucesso ao subir os serviços do container da nova aplicação!\n\033[0m"

      # Executa o script para criação das regras de redirecionamento
      echo -e "\033[33m\nPor fim, vamos executar o script de criação das regras de redirecionamento para a nova aplicação...\n\033[0m"
      
      cd ../../scripts
      ./proxy.sh 1 $appname
      
      # Verifica se a saída do comando anterior gerou algum erro
      if [[ $? -eq 0 ]]; then
        echo -e "\033[32m\nRegras de redirecionamento criadas com sucesso!\n\033[0m"
      else 
        echo -e "\033[31m\nErro ao aplicar as novas configurações...restart o container do Application Gateway manualmente.\n\033[0m"
      fi
    else
      echo -e "\033[31m\nNão foi possível subir os serviços do container! Execute este passo manualmente...\n\033[0m"
    fi
  else 
    echo -e "\033[33m\nO arquivo 'docker-compose.y(a)ml' não foi localizado... suba o container manualmente e, a seguir, execute 'npm run proxy' para criar as regras de redirecionamento.\n\033[0m"
    echo -e "\033[1m\033[32m\nAplicação criada com sucesso!\n\033[0m"
    exit 0;
  fi
}

function createEnvFile {
  # Caso exista um arquivo Dotenv, informa ao usuário a respeito e cria o arquivo
  echo -e "\033[33m\033[1m\nA aplicação requer a definição de variáveis ambiente; um arquivo com valores padrão foi criado para que seja possível executar os serviços do container.\033[0m"
  
  echo -e "\033[33m\033[1m*\033[0m\033[33m Caso necessite alterar alguma varíavel ambiente, faça as alterações no arquivo .env e restart o container manualmente.\033[0m"

  mv ./.env.example ./.env
}

##################################
#       BEGIN SCRIPT EXEC        #
##################################

echo -e "\033[32m ________________________________________________" # 48 characters
echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
echo -e "| \t ASSISTENTE DE CRIAÇÃO DE APPS \t\t |"
echo -e "|________________________________________________|\033[0m"

echo -e "\033[32m\nSeja bem-vindo ao Assistente de Criação de Containers de Aplicação!\033[0m"
echo -e "\033[33mAtravés deste wizard você pode criar uma nova aplicação ou iniciar um projeto baseado em um repositório Git.\033[0m"

echo -e "\033[1m\nPor favor, selecione a ação desejada:\033[0m"
echo -e "(1) CRIAR NOVA APLICAÇÃO BASEADA EM REPOSITÓRIO"
echo -e "(2) CRIAR NOVA APLICAÇÃO BASEADA EM DOCKERFILE"
echo -e "(3) CRIAR REGRAS DE PROXY PARA APLICAÇÃO EXISTENTE"
echo -e "(S) SAIR"

read option
 
# Acessa o diretório padrão de projetos para criação da aplicação
cd ../public_html/

if [[ $option == 1 ]]; then

  echo -e "\033[32m ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo -e "| \t NOVA APLICAÇÃO POR REPOSITÓRIO \t |"
  echo -e "|________________________________________________|\033[0m"

  echo -e "\033[33m\nEste wizard realiza as seguintes ações:"
  echo    " - clona o respositório Git da aplicação"
  echo    " - procura por um arquivo 'docker-compose.yml' no diretório da aplicação"
  echo    " - executa o comando 'docker-compose up -d' para subir o container da aplicação"
  echo -e " - executa o script para criar as regras de redirecionamento da aplicação\033[0m"

  option1
elif [[ $option == 2 ]]; then
  
  echo -e "\033[32m ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo -e "| \t NOVA APLICAÇÃO POR DOCKERFILE \t\t |"
  echo -e "|________________________________________________|\033[0m"

  option2
elif [[ $option == 3 ]]; then

  echo -e "\033[32m ________________________________________________" # 48 characters
  echo -e "| \t\t\t\t\t\t |" # 6 tabs + 2 chars + 2 spaces
  echo    "| \t REGRAS PARA APLICAÇÃO EXISTENTE \t\t |"
  echo -e "|________________________________________________|\033[0m"

  option3
else

  echo -e "\033[1m\033[33m\nCriação da aplicação cancelada!\n\033[0m"
  exit 0
fi
