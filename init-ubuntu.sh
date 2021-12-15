#!/bin/bash
echo -n "Please enter password: "
read -s SUDO_PASSWORD
clear

function show_message {
    printf -- "-%.0s" {1..100}
    printf "\n\n $1 \n\n"
    printf -- "-%.0s" {1..100}
    printf "\n"
}

function asRoot {
    echo "$SUDO_PASSWORD" | sudo -S "$@"
}

function update_apt {
    show_message "Update packages"
    asRoot apt update
}

function install_snap_packages {
    show_message "Install snap packages"
    asRoot snap install inkscape
    asRoot snap install gimp
    asRoot snap install vlc
    asRoot snap install 1password
    asRoot snap install code --classic
    asRoot snap install postman
    asRoot snap install phpstorm --classic
    asRoot snap install slack --classic
    asRoot snap install mattermost-desktop
    asRoot snap install chromium
    asRoot snap install bitwarden
    asRoot snap install telegram-desktop
    asRoot snap install snap-store
}

function install_nvm {
    show_message "Install nvm"
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.profile
    nvm install node
}

function install_php {
    show_message "Install php"
    asRoot apt install software-properties-common -y
    asRoot add-apt-repository ppa:ondrej/php -y
    update_apt
    asRoot apt install php-cli php-xml php-zip php-gd php-soap -y
}

function install_composer {
    show_message "Install composer"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    asRoot mv composer.phar /usr/local/bin/composer
}

function install_docker {
    show_message "Install docker"
    asRoot apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  update_apt
  asRoot apt-get install docker-ce docker-ce-cli containerd.io -y
  asRoot usermod -aG docker $USER
}

function install_docker_compose {
    show_message "Install docker compose"
    asRoot curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    asRoot chmod +x /usr/local/bin/docker-compose
}

function install_zsh {
    show_message "Install zsh"
    asRoot apt install zsh -y
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}


function init_system {
    show_message "Install software"
    update_apt
    install_snap_packages
    install_nvm
    install_php
    install_composer
    install_docker
    install_docker_compose
    show_message "Finished"
}

if [$SUDO_PASSWORD == ""]; then
    show_message "No password was provided"
    exit
else
    init_system
fi
