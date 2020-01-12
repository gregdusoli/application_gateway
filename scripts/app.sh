#!/bin/bash

echo -e "\033[32m ______________________________________________"
echo    "|                                              |"
echo    "|        ASSISTENTE DE CRIAÇÃO DE APPS         |"
echo -e "|______________________________________________|\033[0m"

echo -e "\033[32m\nSeja bem-vindo ao Assistente de Criação de Containers de Aplicação!\033[0m"
echo -e "\033[33mAtravés deste wizard você pode criar uma nova aplicação ou iniciar um projeto baseado em um repositório Git.\033[0m"

echo -e "\033[1m\nPor favor, selecione a ação desejada:\033[0m"
echo -e "(1) CRIAR NOVA APLICAÇÃO BASEADA EM REPOSITÓRIO"
echo -e "(2) CRIAR NOVA APLICAÇÃO BASEADA EM DOCKERFILE"
echo -e "(3) SAIR"
read option

if [[ $option == 1 ]]; then
  echo -e "\033[32m ______________________________________________"
  echo    "|                                              |"
  echo    "|        NOVA APLICAÇÃO POR REPOSITÓRIO        |"
  echo -e "|______________________________________________|\033[0m"

  echo -e "\033[33m\nEste wizard realiza as seguintes ações:"
  echo    " - clona o respositório Git da aplicação"
  echo    " - procura por um arquivo 'docker-compose.yml' no diretório da aplicação"
  echo    " - executa o comando 'docker-compose up -d' para subir o container da aplicação"
  echo -e " - executa o script para criar as regras de redirecionamento da aplicação\033[0m"

  echo -e "\033[1m\n- Informe o nome da nova aplicação (nome semântico em Kebab Case - ex: 'novo-app')\033[0m"
  read appname

  echo -e "\033[1m\n- Informe o link do repositório da aplicação\033[0m"
  read repolink

  # Acessa o diretório padrão de projetos para criação da aplicação
  cd public_html/

  # Clona o respositório da aplicação
  echo -e ""
  $(git clone $repolink $appname )

  # Acessa o diretório da aplicação clonada
  cd $appname

  # Verifica a existência de um arquivo 'docker-compose.yml na raiz da aplicação criada'
  if [[ -e ./docker-compose.yml ]]; then
    # Executa 'docker-compose up -d' e sobe o container
    echo -e "\033[32m\nO arquivo docker-compose.yml encontrado na raiz da aplicação, executando serviços do container...\n\033[0m"
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
        echo -e "\033[31m\nErro ao criar regras de redirecionamento...execute este passo manualmente com o comando 'npm run proxy'.\n\033[0m"
      fi
    else
      echo -e "\033[31m\nNão foi possível subir os serviços do container! Execute este passo manualmente...\n\033[0m"
    fi
  else 
    echo -e "\033[33m\nO arquivo 'docker-compose.yml' não foi localizado... suba o container manualmente e, a seguir, execute 'npm run proxy' para criar as regras de redirecionamento.\n\033[0m"
    echo -e "\033[1m\033[32m\nAplicação criada com sucesso!\n\033[0m"
    exit 0;
  fi
elif [[ $option == 2 ]]; then
  echo -e "\033[32m ______________________________________________"
  echo    "|                                              |"
  echo    "|        NOVA APLICAÇÃO POR DOCKERFILE         |"
  echo -e "|______________________________________________|\033[0m"

else
  echo -e "\033[1m\033[33m\nCriação da aplicação cancelada!\n\033[0m"
  exit 0
fi
