#!/bin/bash

if [ `id -u` -ne 0 ]; then
   echo "This script. must be run as root"
   exit 1
fi

USER=${HOME##*/}
DISTRO=$(lsb_release -c -s)

# change to aliyun repository
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list <<-EOF
deb http://mirrors.aliyun.com/ubuntu/ $DISTRO main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-backports main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ $DISTRO main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${DISTRO}-backports main restricted universe multiverse
EOF
apt-get update
apt-get upgrade -yq

# install mono
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list
apt-get update
apt-get install mono-complete libmono-system2.0-cil -yq

# install powershell and some modules
if [ -z `command -v powershell` ]; then
  curl -fsSL https://raw.githubusercontent.com/PowerShell/PowerShell/v6.0.0-alpha.13/tools/download.sh | bash
  Set-PSRepository PSGallery -InstallationPolicy Trusted
  Install-Module AWSPowerShell
fi

# install openssh-server
apt-get install openssh-server -yq

# install vim
apt-get install vim vim-nox -yq

# install mysql
apt-get install mysql-server libmysqlclient-dev -yq

# install memcached and redis
apt-get install memcached redis-server -yq

# install mongodb
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb http://repo.mongodb.org/apt/ubuntu $DISTRO/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
apt-get update
apt-get install mongodb-org -yq
systemctl enable mongod
systemctl start mongod

# install libjpeg8-dev
apt-get install libjpeg8-dev -yq

# install libssl-dev libffi-dev
apt-get install libssl-dev libffi-dev -yq

# install git and zsh
apt-get install git zsh curl -yq

# config git
if ! git config --global --list | grep -q 'user.name'; then
  read -p "Enter your github username: " USERNAME
  git config --global user.name "$USERNAME"
fi
if ! git config --global --list | grep -q 'user.email'; then
  read -p "Enter your github email: " EMAIL
  git config --global user.email "$EMAIL"
fi
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple

# install oh-my-zsh
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
chown -R $USER:$USER ~/.oh-my-zsh

# install zsh prompt: pure
PURE=~/.pure
if [ -d $PURE ]; then
  printf "You already have pure installed.\n"
  printf "You'll need to remove $PURE if you want to re-install.\n"
else
  git clone https://github.com/sindresorhus/pure $PURE
  chown -R $USER:$USER $PURE
  ln -s $PURE/pure.zsh /usr/local/share/zsh/site-functions/prompt_pure_setup
  ln -s $PURE/async.zsh /usr/local/share/zsh/site-functions/async
  cat >> ~/.zshrc <<-EOF

autoload -U promptinit; promptinit
prompt pure
EOF
fi

# install nodejs
if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
  curl -sL https://deb.nodesource.com/setup_7.x | bash
fi
apt-get install nodejs -yq

# install and config pip
apt-get install python-pip -yq
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<-EOF
[global]
index-url = https://pypi.douban.com/simple

[list]
format = columns
EOF
chown -R $USER:$USER ~/.pip
pip install --upgrade pip

# install ipython
pip install --upgrade ipython

# install virtualenv and virtualenvwrapper
pip install --upgrade virtualenv virtualenvwrapper
if ! grep -q 'source /usr/local/bin/virtualenvwrapper.sh' ~/.zshrc; then
  cat >> ~/.zshrc <<-EOF

export WORKON_HOME="~/.virtualenvs"
source /usr/local/bin/virtualenvwrapper.sh
EOF
fi

# install autoenv
pip install --upgrade autoenv
if ! grep -q 'source /usr/local/bin/activate.sh' ~/.zshrc; then
  cat >> ~/.zshrc <<-EOF

source /usr/local/bin/activate.sh
EOF
fi

# install python plugins
pip install --upgrade httpie django flask Mako mysql-python SQLAlchemy Flask-SQLAlchemy python-magic Pillow cropresize2 short_url blinker flask-login flask-script flask-debugtoolbar Flask-Migrate Flask-WTF flask-security flask-restful Flask-Admin webassets flask-assets jsmin cssmin pyscss Werkzeug tornado gunicorn uwsgi libmc redis pymongo mongoengine supervisor fabric

# install babel
npm install --global babel-cli babel-preset-es2015

# install nginx
curl -s http://nginx.org/keys/nginx_signing.key | apt-key add
DISTRO=$(lsb_release -c -s)
cat > /etc/apt/sources.list.d/nginx.list <<-EOF
deb http://nginx.org/packages/ubuntu/ $DISTRO nginx
deb-src http://nginx.org/packages/ubuntu/ $DISTRO nginx
EOF
apt-get update
apt-get install nginx -yq

exec zsh --login
