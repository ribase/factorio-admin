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

    echo "Installing libs"
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

    echo "Adding docker to apt repo"
    curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
    sudo add-apt-repository -y "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
    sudo apt-get update


    echo "Installing docker"


    sudo apt-get -y install docker-engine

    echo "Installing docker compose"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Starting docker if not happenend"
    sudo service docker restart

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

echo "Creating update-folder"
mkdir ./factorio/update-folder

echo "Downloading Serverfiles"
wget --directory-prefix=factorio/update-folder/ --quiet --content-disposition https://www.factorio.com/get-download/0.14.22/headless/linux64

echo "Downloading Serverfiles"
filename=$(ls ./factorio/update-folder | grep tar.gz)
echo $filename

echo "Installing factorio "
./factorio/firstinstall.sh $filename

echo "Creating folders"
mkdir factorio/saves

echo "Starting up"
docker-compose up --build -d

echo "Install adminpanel"
docker-compose exec --user 1000 php composer install --no-interaction -d /var/www/symfony/

echo "Creating database"
docker-compose exec --user 1000 php /var/www/symfony/install-db.sh

echo "Starting gameserver"
docker-compose exec --user 1000 factorio supervisorctl restart factorio

echo "Creating Factorio serverfiles"
cp factorio/data/map-gen-settings.example.json factorio/data/map-gen-settings.json
cp factorio/data/server-settings.example.json factorio/data/server-settings.json