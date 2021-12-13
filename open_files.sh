#!/bin/bash

# Alummno: Cheuk Kelly Ng Pante
# Correo Institucional: alu0101364544@ull.edu.es
# Universidad de La Laguna - Ingeniería Informática
# Asignatura: Sistemas Operativos
# Practica de BASH ficheros Abiertos por Usuarios

echo

# === Constantes y variables ===
PROGNAME=$(basename $0)
WHICH_LSOF="which lsof"
USERS_CONNECT=$(who | cut -f 1 -d " " | sort | uniq)
USERS_NO_CONNECT=$(cat /etc/passwd | tr ":" " " | awk '{print $1}')
filter=
u=0
USERS_U=
arrUser=()
arrOff=()

# === Estilos ===
TEXT_BOLD=$(tput bold)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_YELLOW=$(tput setaf 3)
TEXT_BLUE=$(tput setaf 4)
TEXT_PURPLE=$(tput setaf 5)
TEXT_BLUE_CYAN=$(tput setaf 6)
TEXT_WHITE=$(tput setaf 7)
TEXT_BLACK=$(tput setaf 8)

# === Funciones ===

#Funcion de error exit
error_exit()
{   
  echo "${PROGNAME}: ${1:-"Error desconocido"}" 1>&2        
  exit 1
}

#Función que saca un mensaje de como se usa el script
usage()
{
  echo "${TEXT_RED}${TEXT_BOLD}usage: ./open_files.sh [-h | --help] [-f | --filter patron] [-o | --off_line] [-u | --user users]${TEXT_RESET}"
}

# Funcion para comprobar si existe un usuario, si no existe, error_exit
check_user()
{
  id $user > /dev/null 2> /dev/null || error_exit "El usuario ${TEXT_BOLD}${TEXT_RED}$user${TEXT_RESET} no existe en el sistema"
}

prog_principal()
{
  printf "%-35s %-3s %-30s %-3s %-20s %-3s %-10s\n" "${TEXT_BOLD}User${TEXT_RESET}" "|" "${TEXT_BOLD}Num_files_open${TEXT_RESET}" "|" "${TEXT_BOLD}UID${TEXT_RESET}" "|" "${TEXT_BOLD}PID${TEXT_RESET}" 
  printf "==========================|========================|==============|=============\n"
  for i in $USERS; do
    if [ "$filter" == "1" ]; then
      printf "%-25s %-3s %-20s %-3s %-10s %-3s %-10s\n" "$i" "|" "$(lsof -u $i | awk '{print $9}' | grep -E $pattern$ | wc -l)" "|" "$(id -u $i)" "|" "$(ps -u $i --no-headers -o pid --sort=-time | head -n 1 | awk '{print $1}')"
    else
      printf "%-25s %-3s %-20s %-3s %-10s %-3s %-10s\n" "$i" "|" "$(lsof -u $i | wc -l)" "|" "$(id -u $i)" "|" "$(ps -u $i --no-headers -o pid --sort=-time | head -n 1 | awk '{print $1}')"
    fi
  done
}

# Para desinstalar lsof: sudo apt-get --purge remove lsof
$WHICH_LSOF > /dev/null || error_exit "${TEXT_RED}No tiene el programa lsof instalado en el sistema, para instalar: ${TEXT_YELLOW}sudo apt install lsof${TEXT_RESET}"  #Comprobar si lsof está instalado
echo "${TEXT_ULINE}${TEXT_BOLD}${TEXT_BLACK}Script ${PROGNAME}${TEXT_RESET}"
if [ "$1" == "" ]; then
  USERS=$USERS_CONNECT
  prog_principal
  exit 0
else
  while [ "$1" != "" ]; do
    case $1 in
      -h | --help )
          usage
          exit 0
        ;;
      -f | --filter )
          filter=1
          if [ "$2" == "" ]; then
            error_exit "Debe de introducir algun patron"
          fi
          pattern=$2
          echo "${TEXT_BOLD}${TEXT_YELLOW}Filtramos con el patron añadido: ${TEXT_RED}$pattern${TEXT_RESET}"
          shift
        ;;
      -o | --off_line ) 
          offline=1
          for i in $USERS_NO_CONNECT; do
            band="false"
            for j in $USERS_CONNECT; do
              if [ "$i" == "$j" ]; then
                band="true"
              fi
            done
            if [ "$band" == "false" ]; then
              arrOff+=($i)
            fi
          done
          USERS_O=${arrOff[@]}
          USERS=$USERS_O
        ;;
      -u | --user )
          u=1
          if [ "$2" == "" ] || [ "$(echo ${2:0:1})" == "-" ]; then
            error_exit "Debe introducir algun usuario despues de la opcion -u"
          fi
          while [ "$2" != "" ]; do
            if [ "$(echo ${2:0:1})" == "-" ]; then   # Cojo el primer caracter de un string para ver si es una opcion "-" y lo comparo 
              break
            else
              user=$2 # Variable para llevar $2 a la funcion check_user y comprobar que ese usuario existe en el sistema
              check_user 
              arrUser+=($2)
            fi
            shift
          done
          USERS_U=${arrUser[@]}
          USERS=$USERS_U
        ;;
      *) 
        error_exit "${TEXT_BOLD}${TEXT_RED}Opcion introducida no disponible${TEXT_RESET}"
    esac 
    shift
  done

  # Intersección de -u y -off_line
  if [ "$offline" == "1" ] && [ "$u" == "1" ]; then
    for i in $USERS_O; do
      band="false"
      for j in $USERS_U; do
        if [ "$i" == "$j" ]; then
          band="true"
        fi
      done
      if [ "$band" == "false" ]; then
        arrInter+=($i)
      fi
    done
  USERS=${arrInter[@]}
  fi
fi

prog_principal