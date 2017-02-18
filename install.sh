#!/usr/bin/env bash



OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)

dialog="You are using: $'\n' OS: $OS $'\n' ARCH: x$ARCH $'\n' VER: $VER /n is this correct?"

function installDocker {
cat << "EOF"
             *
       *   *
     *    \* / *
       * --.:. *
      *   * :\ -
        .*  | \
       * *     \
     .  *       \
      ..        /\.
     *          |\)|
   .   *         \ |
  . . *           |/\
     .* *         /  \
   *              \ / \
 *  .  *           \   \
    * .
   *    *
  .   *    *




██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ ███╗   ███╗ █████╗  ██████╗ ██╗ ██████╗██╗  ██╗
██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔════╝ ██║██╔════╝██║ ██╔╝
██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝██╔████╔██║███████║██║  ███╗██║██║     █████╔╝
██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║   ██║██║██║     ██╔═██╗
██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝██║╚██████╗██║  ██╗
╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝

EOF

{
    echo "XXX"
    echo "0"
    echo "Installing libs"
    echo "XXX"
    sudo apt-get update -y
    sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

    echo "XXX"
    echo "20"
    echo "Adding docker to apt repo"
    echo "XXX"
    curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
    sudo add-apt-repository -y "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
    sudo apt-get update

    echo "XXX"
    echo "40"
    echo "Installing docker"
    echo "XXX"
    sudo apt-get -y install docker-engine

    echo "XXX"
    echo "60"
    echo "Installing docker compose"
    echo "XXX"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  >> /dev/null 2>&1
    sudo chmod +x /usr/local/bin/docker-compose

    echo "XXX"
    echo "80"
    echo "Starting docker if not happenend"
    echo "XXX"
    sudo service docker restart


    echo "100"
} | whiptail --gauge "Please wait while installing" 6 60 0

}

function installServer {

cat << "EOF"
                    ##        .
              ## ## ##       ==
           ## ## ## ##      ===
       /""""""""""""""""\___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \______ o          __/
         \    \        __/
          \____\______/

          |          |
       __ |  __   __ | _  __   _
      /  \| /  \ /   |/  / _\ |
      \__/| \__/ \__ |\_ \__  |

EOF

{

echo "XXX"
echo "0"
echo "Creating update-folder"
echo "XXX"
mkdir ./factorio/update-folder >> /dev/null 2>&1

echo "XXX"
echo "5"
echo "Downloading Serverfiles"
echo "XXX"
wget --directory-prefix=factorio/update-folder/ --quiet --content-disposition https://www.factorio.com/get-download/0.14.22/headless/linux64

echo "XXX"
echo "10"
echo "Downloading Serverfiles"
echo "XXX"
filename=$(ls ./factorio/update-folder | grep tar.gz)
echo $filename

echo "XXX"
echo "15"
echo "Installing factorio"
echo "XXX"
./factorio/firstinstall.sh $filename >> /dev/null 2>&1

echo "XXX"
echo "20"
echo "Creating folders"
echo "XXX"
mkdir factorio/saves >> /dev/null 2>&1

echo "XXX"
echo "40"
echo "Starting up"
echo "XXX"
docker-compose up --build -d >> /dev/null 2>&1

echo "XXX"
echo "50"
echo "Install adminpanel"
echo "XXX"
docker-compose exec --user 1000 php composer install --no-interaction -d /var/www/symfony/ >> /dev/null 2>&1

echo "XXX"
echo "60"
echo "Creating database"
echo "XXX"
docker-compose exec --user 1000 php /var/www/symfony/install-db.sh >> /dev/null 2>&1

echo "XXX"
echo "70"
echo "Starting gameserver"
echo "XXX"
docker-compose exec factorio supervisorctl restart factorio >> /dev/null 2>&1

echo "XXX"
echo "90"
echo "Creating Factorio serverfiles"
echo "XXX"

cp factorio/data/map-gen-settings.example.json factorio/data/map-gen-settings.json
cp factorio/data/server-settings.example.json factorio/data/server-settings.json


echo "XXX"
echo "100"
echo "Nearly done"
echo "XXX"
sleep 3

} | whiptail --gauge "Please wait while installing" 6 60 0
}

function doInstall {
    if (whiptail --title "Docker" --yesno "Should i install docker for you?" 10 60) then
        installDocker
        installServer
    else
        installServer
    fi
}

if (whiptail --title "Example Dialog" --yesno "$dialog" 12 78) then
    doInstall
else
   exit;
fi