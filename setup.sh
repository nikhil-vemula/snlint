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
        workingDir=$(pwd)
        #Find the git folders and install pre-commit
        echo "Installing snlint in $gitDir"
        # Ignore config file in git commit
        echo ".pre-commit-config.yaml" >> ~/.gitignore_global
        git config --global core.excludesfile ~/.gitignore_global
        for dir in $(find $gitDir -name ".git")
        do
            cd $dir
            cd ..
            echo "Copying configuration file to $(pwd)"
            cp ~/snlint/.pre-commit-config.yaml .pre-commit-config.yaml
            git rm --cached ./.pre-commit-config.yaml > /dev/null 2>&1
            pre-commit install
            # pre-commit install --hook-type pre-push
        done
        if [ ! -f /usr/local/bin/snlint ]; then
            ln -s ~/snlint/setup.sh /usr/local/bin/snlint
        fi;
        cd $workingDir
}
update() {
    echo "Updating snlint at $gitDir..."
    for file in $(find ~/git -name ".pre-commit-config.yaml")
    do
        cd $(dirname $file)
        echo "Updating the pre-commit hooks...."
        pre-commit autoupdate
    done
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

#Print Info
gitDir=$(pwd)

if [ "$1" = "help" ];then
    info;
# Install
elif [ -z "$1" ] || $1 = "install" ] || [ $1 = "update" ]; then 
    if [ ! -d snlint ]; then
        git clone https://code.devsnc.com/srinivasa-vemula/snlint.git
        install;
    else
        echo "Snlint is already installed";
        cd snlint
        echo "Checking for updates....";
        checkForUpdates;
        install;
        update;
    fi;
#Uninstall
elif [ $1 = "uninstall" ]; then
    echo "Uninstalling snlint from $gitDir...."
    for file in $(find ~/git -name ".pre-commit-config.yaml")
    do
        cd $(dirname $file)
        echo "Uninstalling the pre-commit hooks...."
        pre-commit uninstall
        # pre-commit install -t pre-push
        echo "Deleting config file $file"
        rm $file
    done
    rm /usr/local/bin/snlint
fi;


