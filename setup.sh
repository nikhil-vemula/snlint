#!/bin/bash
version="v0.1";

#Helper funtions

info() {
echo "
           _ _       _   
 ___ _ __ | (_)_ __ | |_ 
/ __| '_ \| | | '_ \| __|
\__ \ | | | | | | | | |_ 
|___/_| |_|_|_|_| |_|\__|                       
";
    echo "Version: $version";
    echo "Usage: $0 [install <git-directory>| uninstall | update]";
    echo "  help : Display help";
    echo "  install : Install snlint";
    echo "  uninstall : Uninstall snlint";    
    echo "  update : Update snlint";    
}

install() {
    echo "Installing snlint..."
    # Npm install
    cd ~/snlint
    npm install .
    # Modify git hook default directory.
    git config --global core.hooksPath ~/snlint/snhooks
    # Create soft link
    if [ ! -f /usr/local/bin/snlint ]; then
        ln -s ~/snlint/setup.sh /usr/local/bin/snlint
    fi;
}
update() {
    echo "Updating snlint..."
    npm install
}
checkForUpdates() {
    git remote update
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        echo "Up-to-date"
    elif [ $LOCAL = $BASE ]; then
        echo "Update available"
        echo "Updating..."
        git pull --quiet
    elif [ $REMOTE = $BASE ]; then
        echo "Need to push"
    else
        echo "Diverged"
    fi
}

cd ~

#Print Info
if [ "$1" = "help" ];then
    info;
# Install
elif [ -z "$1" ] || $1 = "install" ] || [ $1 = "update" ]; then 
    if [ ! -d snlint ]; then
        git clone https://code.devsnc.com/srinivasa-vemula/snlint.git
        install;
    else
        cd snlint
        echo "Checking for updates....";
        checkForUpdates;
        update;
    fi;
#Uninstall
elif [ $1 = "uninstall" ]; then
    echo "Uninstalling snlint..."
    git config --global --unset core.hooksPath
    rm /usr/local/bin/snlint
    rm -rf ~/snlint
fi;


