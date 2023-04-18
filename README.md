**Tools for create SSH shortcut. support BASH and ZSH completion. let you
easily switch between many server via ssh.**

## Install

### Requirement:

- awk
- bash
- cat
- cut
- grep
- rev
- scp
- sed
- openssh
- sshpass
- which

Installer will find below file to install Shell completion plugins:

- For BASH: `~/.profile` or `~/.bash_profile`
- For ZSH: `~/.zshrc`

If file not exist, plugins and environment will not be configure.

### Install

```
bash ./install.sh install
```

Tools will only install under user directory by default.

You can apply `PREFIX` variable to install it into another place.

```
PREFIX=/usr/local bash ./install.sh install
```

### Uninstall

```
bash ./install.sh remove
```

If tools installed with PREFIX. you need apply same value on doing uninstall as
well.

### Manually use configure

if BASH profile or zshrc are not exists before install. you need manually
config your user after installed.

for BASH, append code below into your bash profile:

```
source <PREFIX>/share/sshcrab/sshcrab_bash_plugin
```

eg.

```
source $HOME/.local/share/sshcrab/sshcrab_bash_plugin
```

for ZSH, append code below into your bash profile:

```
source <PREFIX>/share/sshcrab/sshcrab_zsh_plugin
```

## Usage

### Config

sshcrab supported read hosts from `~/.ssh/config`. also you can use sshcrab
style config file. tools will find file in order by path below:

1. `~/.crabhosts`
1. `$XDG_CONFIG_HOME/sshcrab/crabhosts`
1. `~/.config/sshcrab/crabhosts`

example of crabhosts:

```shell
#
# Some configured host which defined in `.ssh/config` are not allow to login
# (such as git).
# You can list these hosts to ignore them. just append a excalmatory(!) at
# start of each item.
!github.com
!bitbucket.org

#
# To config your hosts, you can append lines below.
#
# Fields:
# Alias    Address    User    Auth
#
# The 'Auth' can be a specified as below:
#     - A password: use base64 encoded
#     - An identity file: start with a dash (-)

# use default SSH identity
host1  192.168.1.1  root

# with password (eg. "123456")
host2  192.168.1.2  someuser  MTIzNDU2Cg==

# with a identity file
host3  192.168.1.3  user  -$HOME/.ssh/your-identity
```

### Command example

```shell
# login to a server
crabto alias

# login with X11 forward
crabto alias -X

# login with Wayland forward
crabto alias -Y

# login with tunnel
crabto alias -L 127.0.0.1:1000:127.0.0.1:100

# copy file to remote
crabcp ./localfile alias:~/

# copy file from remote
crabcp alias:~/remotefile ./

# copy directory
crabcp -r ./some_path alias:~/

# sftp login
crabtp alias

# use env CRAB_DRYRUN to show raw-command without execution
CRAB_DRYRUN=yes crabto alias
```

