#!/usr/bin/env bash

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



if [ "$1" == "--docker" ]; then
{
    echo "Installing libs"
    sudo apt-get update -y
    sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

    echo "Adding docker to apt repo"
    echo "20"
    curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
    sudo add-apt-repository -y "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
    sudo apt-get update


    echo "Installing docker"
    echo "40"
    sudo apt-get -y install docker-engine

    echo "Installing docker compose"
    echo "60"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Starting docker if not happenend"
    echo "80"
    sudo service docker restart


    echo "100"
} | whiptail --gauge "Please wait while installing" 6 60 0

fi

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
echo "Creating update-folder"
echo "0"
echo "XXX"
mkdir ./factorio/update-folder >> /dev/null 2>&1

echo "XXX"
echo "Downloading Serverfiles"
echo "5"
echo "XXX"
wget --directory-prefix=factorio/update-folder/ --quiet --content-disposition https://www.factorio.com/get-download/0.14.22/headless/linux64

echo "XXX"
echo "Downloading Serverfiles"
echo "10"
echo "XXX"
filename=$(ls ./factorio/update-folder | grep tar.gz)
echo $filename

echo "XXX"
echo "Installing factorio"
echo "15"
echo "XXX"
./factorio/firstinstall.sh $filename >> /dev/null 2>&1

echo "XXX"
echo "Creating folders"
echo "20"
echo "XXX"
mkdir factorio/saves >> /dev/null 2>&1

echo "XXX"
echo "Starting up"
echo "40"
echo "XXX"
docker-compose up --build -d >> /dev/null 2>&1

echo "XXX"
echo "Install adminpanel"
echo "50"
echo "XXX"
docker-compose exec --user 1000 php composer install --no-interaction -d /var/www/symfony/ >> /dev/null 2>&1

echo "XXX"
echo "Creating database"
echo "60"
echo "XXX"
docker-compose exec --user 1000 php /var/www/symfony/install-db.sh >> /dev/null 2>&1

echo "XXX"
echo "Starting gameserver"
echo "70"
echo "XXX"
docker-compose exec factorio supervisorctl restart factorio >> /dev/null 2>&1

echo "XXX"
echo "Creating Factorio serverfiles"
echo "90"
echo "XXX"

cp factorio/data/map-gen-settings.example.json factorio/data/map-gen-settings.json >> /dev/null 2>&1
cp factorio/data/server-settings.example.json factorio/data/server-settings.json >> /dev/null 2>&1


echo "100"
} | whiptail --gauge "Please wait while installing" --title "Application" 6 60 0