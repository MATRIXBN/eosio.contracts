function default-eosio-directories() {
  EOSIO_DIRECTORIES=($(echo $(ls ${HOME}/eosio)))
  CONTINUE=true
  if [[ $NONINTERACTIVE != true ]]; then
    while $CONTINUE -eq true; do
      echo "We detected the following items in the default EOSIO path:"
      printf '%s\n' "${EOSIO_DIRECTORIES[@]}"
      printf "Enter the EOSIO version number/directory to use:" && read -p " " EOSIO_VERSION
      for ITEM in "${EOSIO_DIRECTORIES[@]}"; do
        if [[ "$ITEM" = "$EOSIO_VERSION" ]]; then
          CONTINUE=false
        fi
      done
    done
  else
    REG='^[0-9]+([.][0-9]+)?$'
    for ITEM in "${EOSIO_DIRECTORIES[@]}"; do
      if [[ "$ITEM" =~ $REG ]]; then
        EOSIO_VERSION=$ITEM
      fi
    done   
    # TODO: Determine which EOSIO is default if multiple exist. Use highest version.
  fi
}

function eosio-directory-prompt() {
  if [[ -z $EOSIO_INSTALL_DIR ]]; then
    echo 'No EOSIO location was specified.'
    while true; do
      if [[ $NONINTERACTIVE != true ]]; then
        printf "Is EOSIO installed in the default location: $HOME/eosio/X.Y (y/n)" && read -p " " PROCEED
      fi
      echo ""
      case $PROCEED in
        "" )
          echo "Is EOSIO installed in the default location?";;
        0 | true | [Yy]* )
          default-eosio-directories;
          break;;
        1 | false | [Nn]* )
          printf "Enter the installation location of EOSIO:" && read -p " " EOSIO_INSTALL_DIR;
          break;;
        * )
          echo "Please type 'y' for yes or 'n' for no.";;
      esac
    done
  fi
  # TODO: Update appropriate info in CMAKE files related to EOSIO installation location.
  . ./scripts/.environment

  INSTALLED_VERSION=$(echo $($EOSIO_INSTALL_DIR/bin/nodeos --version) | cut -f1,2 -d '.' | sed 's/v//g' )
  if [[ $INSTALLED_VERSION < $EOSIO_MIN_SUPPORTED_VERSION ]]; then 
    echo "Detected EOSIO version $INSTALLED_VERSION. Miniumum required version is $EOSIO_MIN_SUPPORTED_VERSION."
    exit 1;
  fi
  echo $EOSIO_INSTALL_DIR
}

function cdt-directory-prompt() {
  if [[ -z $CDT_INSTALL_DIR ]]; then
    echo 'No EOSIO.CDT location was specified.'
    while true; do
      if [[ $NONINTERACTIVE != true ]]; then
        printf "Is EOSIO.CDT installed in the default location? /usr/local/eosio.cdt (y/n)" && read -p " " PROCEED
      fi
      echo ""
      case $PROCEED in
        "" )
          echo "Is EOSIO.CDT installed in the default location?";;
        0 | true | [Yy]* )
          CDT_INSTALL_DIR="/usr/local/eosio.cdt";
          break;;
        1 | false | [Nn]* )
          printf "Enter the installation location of EOSIO.CDT:" && read -p " " CDT_INSTALL_DIR;
          break;;
        * )
          echo "Please type 'y' for yes or 'n' for no.";;
      esac
    done
    # TODO: Update appropriate info in CMAKE files related to EOSIO.CDT installation location.
  fi
  export CDT_INSTALL_DIR="${CDT_INSTALL_DIR:-/usr/local/eosio.cdt}"
  echo $CDT_INSTALL_DIR
}