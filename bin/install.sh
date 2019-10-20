#!/bin/bash
######################################## HELPER FUNCTIONS

addIfMissingInSudoers () {
    entry=$1
    isEntry=$(sudo grep "$entry" /etc/sudoers)

    if [ -z "$isEntry" ]
    then
        sudo echo "$entry" | sudo EDITOR="tee -a" visudo
    else
        echo -e "\nThe following entry already exists in /etc/sudoers:"
        echo -e "'$entry'"
    fi
}

######################################## MAIN SCRIPT

echo -e "\n>>> INSTALLING OS DEPENDENCIES..."
while read -r dependency; do
  sudo apt-get install -y "$dependency"
done < requirements_linux.txt

echo -e "\n>>> CREATING A PYTHON VIRTUAL ENVIRONMENT AND INSTALLING ITS DEPENDENCIES..."
python3 -m venv virtual
source ./virtual/bin/activate
yes | pip install -r requirements_python.txt

echo -e "\n>>> CREATING A DAEMON USER 'AROUNDTHECLOCK'"
sudo useradd -r aroundtheclock -s /bin/false

echo -e "\n>>> INSTALLING AROUNDTHECLOCK AS A DAEMON..."
PATH_SRC=./config/aroundtheclock.service
PATH_DST=/lib/systemd/system/aroundtheclock.service
sudo cp "$PATH_SRC" "$PATH_DST"
sudo sed -i "s|<PATH_TO_PROJECT_ROOT>|$(pwd)|g" "$PATH_DST"

echo -e "\n>>> INSTALLING AROUNDTHECLOCK EXECUTABLE..."
PATH_SRC=./bin/aroundtheclock
PATH_DST=/usr/local/bin/aroundtheclock
sudo chown root:root "$PATH_SRC"
sudo chmod u+rwx,g-rwx,o-rwx "$PATH_SRC"
sudo cp "$PATH_SRC" "$PATH_DST"

echo -e "\n>>> CHANGING PERMISSIONS ON AROUNDTHECLOCK PROJECT..."
sudo chown -R aroundtheclock:aroundtheclock .
sudo chmod u+x bin/run.sh

echo -e "\n>>> GIVING AROUNDTHECLOCK DAEMON THE NEEDED PERMISSIONS..."
entry1="# Automatically generated by 'project_aroundtheclock'"
entry2="Cmnd_Alias AROUNDTHECLOCK_CMDS = /usr/local/bin/aroundtheclock"
entry3="aroundtheclock ALL=(ALL) NOPASSWD: AROUNDTHECLOCK_CMDS"
addIfMissingInSudoers "$entry1"
addIfMissingInSudoers "$entry2"
addIfMissingInSudoers "$entry3"

echo -e "\n>>> ENABLING AROUNDTHECLOCK DAEMON..."
sudo systemctl enable aroundtheclock.service
sudo systemctl start aroundtheclock.service
