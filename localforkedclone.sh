#!/bin/sh

# Automatic configuration for local Git repository from a project fork
#
# Requirements:
# 1. working git installation
# 2. project fork repository on GitHub
# 
# Usage:
# setup_local_git [GitHub account name] [forked project name in your account] [account name of original forked project]
#
# This script will create a local clone of the forked project Git
# repository located on GitHub.  The specified project fork will be
# added as an addtional remote repository and a new "dev" branch created to
# track local development.
#
# After the script is executed:
# "git push" will push local commits to your dev branch
# "git pull" will pull changes from the original project master branch into your local project
#
# Original author: long @ insoshi who wrote a nice blog post about this at:
# http://blog.insoshi.com/2008/10/14/setting-up-your-git-repositories-for-open-source-projects-at-github/
#
# Modifications by: Colin Surprenant, http://github.com/colinsurprenant, http://eventuallyconsistent.com/blog/


# Verify number of arguments to script
#
if [ $# -ne "3" ]
then
  echo "Usage: setup_local_git [GitHub account name] [forked project name in your account] [account name of original forked project]"
  exit 1
fi

GITHUB_ACCOUNT="$1"
MAIN_USER="$3"
MAIN_PROJECT="$2"
MAIN_REPOSITORY="git://github.com/$MAIN_USER/$MAIN_PROJECT.git"
REMOTE="$GITHUB_ACCOUNT"
REMOTE_URL="git@github.com:$GITHUB_ACCOUNT/$MAIN_PROJECT.git"
BRANCH="dev"

# Error handling function
catch_error() {
  if [ $1 -ne "0" ]
  then
    echo "ERROR encountered $2"
    exit 1
  fi
}

# Clone official $MAIN_PROJECT repository
#
# This sets the local master branch to be equal to the official $MAIN_PROJECT
# master
#
echo "Cloning official [$MAIN_PROJECT] repository..."
git clone $MAIN_REPOSITORY
catch_error $? "cloning official $MAIN_PROJECT repository"

echo

# Change directory into local $MAIN_PROJECT repository
#
cd $MAIN_PROJECT

# Create a local branch based off master
#
echo "Creating local branch [$BRANCH]..."
git branch $BRANCH master
catch_error $? "creating local branch [$BRANCH]"

git checkout $BRANCH
catch_error $? "checking out local branch [$BRANCH]"

echo

# Add forked repository as a remote repository connection
#
# The GitHub account name will be used to refer to this repository
#
echo "Adding remote [$REMOTE] to forked repository..."
git remote add $REMOTE $REMOTE_URL
catch_error $? "adding remote [$REMOTE]"

echo

# Fetch branch information
#
echo "Fetching remote branch information from [$REMOTE]..."
git fetch $REMOTE
catch_error $? "fetching branches from remote [$REMOTE]"

echo

# Create the matching remote branch on the forked repository
#
# We need to explicitly create the branch via a push command
#
echo "Pushing local branch [$BRANCH] to remote [$REMOTE]..."
git push $REMOTE $BRANCH:refs/heads/$BRANCH
catch_error $? "pushing local branch [$BRANCH] to remote [$REMOTE]"

echo

# Configure the remote connection for the local branch
#
echo "Configuring remote [$REMOTE] for local branch [$BRANCH]..."

git config branch.$BRANCH.remote $REMOTE
catch_error $? "configuring remote [$REMOTE] for local branch [$BRANCH]"

git config branch.$BRANCH.merge refs/heads/$BRANCH
catch_error $? "configuring merge tracking for local branch [$BRANCH]"

exit 0
