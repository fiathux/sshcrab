#!/bin/bash

if [ -z "$PREFIX" ]; then
  LOCAL_PATH=$HOME/.local
else
  LOCAL_PATH=`echo "$PREFIX"|sed 's/\/$//'`
fi
CONFIG_PATH=$HOME
BIN_PATH=$LOCAL_PATH/bin
RES_PATH=$LOCAL_PATH/share/sshcrab

# check toolchain
check_toolchain() {
  which which>/dev/null
  [ $? != 0 ] && {
    echo "no command 'which'">&2
    return 1
  }
  while read ln; do
    which $ln>/dev/null
    [ $? != 0 ] && {
      echo "no command '$ln'">&2
      return 1
    }
  done <<EOF
awk bash cat cut grep rev scp sed sftp ssh
EOF
  which sshpass>/dev/null
  [ $? != 0 ] && {
    echo "HINT: no command 'sshpass'">&2
    echo "will not support to automatically login with password.">&2
  }
  return 0
}

# check and create path
make_path() {
  if [ ! -z "$XDG_CONFIG_HOME" ]; then
    mkdir -p $XDG_CONFIG_HOME/sshcrab
    CONFIG_PATH=$XDG_CONFIG_HOME/sshcrab
  fi
  if [ ! -d BIN_PATH ]; then
    mkdir -p $BIN_PATH
  fi
  if [ ! -d RES_PATH ]; then
    mkdir -p $RES_PATH
  fi
}

# install one script
install_one_script() {
  cp ./bin/$1 $BIN_PATH/$1
  chmod +x "$BIN_PATH/$1"
}

# check path for bash
check_path_for_bash() {
  if [ -f "$HOME/.profile" ] || [ -f "$HOME/.bash_profile" ]; then
    local file
    [ -f "$HOME/.profile" ] && file="$HOME/.profile"
    [ -f "$HOME/.bash_profile" ] && file="$HOME/.bash_profile"
    echo "check and update bash profile">&2
    cat > $RES_PATH/sshcrab_bash_plugin <<EOF
# sshcrab plugin
export CRAB_PREFIX="$LOCAL_PATH"
export PATH="\`bash \$CRAB_PREFIX/share/sshcrab/checkpath\`"
source $RES_PATH/completions
EOF
    if [ -z "$(cat $file|grep sshcrab_bash_plugin)" ]; then
      echo "source $RES_PATH/sshcrab_bash_plugin" >> $file
    fi
  fi
}

# remove bash plugin
remove_bash_plugin() {
  if [ -f "$HOME/.profile" ] || [ -f "$HOME/.bash_profile" ]; then
    local file
    [ -f "$HOME/.profile" ] && file="$HOME/.profile"
    [ -f "$HOME/.bash_profile" ] && file="$HOME/.bash_profile"
    echo "remove bash plugin">&2
    sed -i '/sshcrab_bash_plugin/d' $file
  fi
}

# check path for zsh
check_path_for_zsh() {
  if [ -f "$HOME/.zshrc" ]; then
    echo "check and update zsh profile">&2
    cat > $RES_PATH/sshcrab_zsh_plugin <<EOF
# sshcrab plugin
export CRAB_PREFIX="$LOCAL_PATH"
export PATH="\`zsh \$CRAB_PREFIX/share/sshcrab/checkpath\`"
source $RES_PATH/completions_zsh
EOF
    if [ -z "$(cat $HOME/.zshrc|grep sshcrab_zsh_plugin)" ]; then
      echo "source $RES_PATH/sshcrab_zsh_plugin" >> $HOME/.zshrc
    fi
  fi
}

# remove zsh plugin
remove_zsh_plugin() {
  if [ -f "$HOME/.zshrc" ]; then
    echo "remove zsh plugin">&2
    sed -i '/sshcrab_zsh_plugin/d' $HOME/.zshrc
  fi
}

# do install
install() {
  check_toolchain
  if [ $? != 0 ]; then
    echo "install failed">&2
    return 1
  fi
  if [ -f $RES_PATH/installed_list ]; then
    echo "sshcrab has been installed">&2
    return 1
  fi
  make_path
  while read ln; do
    install_one_script $ln
    echo "$ln" >> $RES_PATH/installed_list
  done < <(ls ./bin)
  cp -r ./share/* $RES_PATH
  check_path_for_bash
  check_path_for_zsh
  if [ $CONFIG_PATH = $HOME ]; then
    cp ./share/crabhosts_example $CONFIG_PATH/.crabhosts
    chmod 600 $CONFIG_PATH/.crabhosts
    echo "HINT: you can use '$HOME/.crabhosts' to edit your hosts file.">&2
  else
    cp ./share/crabhosts_example $CONFIG_PATH/crabhosts
    chmod 600 $CONFIG_PATH/crabhosts
    echo "HINT: you can use '$CONFIG_PATH/crabhosts' to edit your hosts file.">&2
  fi
  echo "install success"
}

# do remove
uninstall() {
  if [ ! -f $RES_PATH/installed_list ]; then
    echo "sshcrab has not been installed">&2
    return 1
  fi
  while read ln; do
    rm -f $BIN_PATH/$ln
  done < $RES_PATH/installed_list
  rm -rf $RES_PATH/
  remove_bash_plugin
  remove_zsh_plugin
  echo "remove success"
}

# show help document
show_help() {
  echo ""
  echo "Usage of $0:"
  echo ""
  echo "    install sshcrab:"
  echo "      $0 install"
  echo ""
  echo "    remove sshcrab:"
  echo "      $0 remove"
  echo ""
  echo "    Environment Variables:"
  echo "      PREFIX: install path, default is $HOME/.local"
  echo ""
}

# select an operation
case $1 in
  install)
    install $2
    ;;
  remove)
    uninstall $2
    ;;
  *)
    show_help
    ;;
esac
