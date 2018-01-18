#!/bin/bash
# script to bootstrap setting up a mac with ansible

function uninstall {

echo "WARNING : This will remove homebrew and all applications installed through it"
echo -n "are you sure you want to do that? [y/n] : "
read confirmation

if [ $confirmation == "y" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
    exit 0
else
  echo "keeping everything intact"
  exit 0
fi

}

if [ $1 == "uninstall" ]; then
    uninstall
fi

echo "==========================================="
echo "Setting up your mac using setupmac"
echo "==========================================="

echo "==========================================="
echo "Accept xcode build license"
echo "==========================================="
sudo xcodebuild -license accept

echo "==========================================="
echo "Installing homebrew and basic libraries"
echo "==========================================="
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo "*** Installing openssl"
brew install openssl
echo "*** Installing libyaml"
brew install libyaml

echo "==========================================="
echo "Installing pip, ansible and dependencies"
echo "==========================================="
sudo easy_install pip
env LDFLAGS="-L$(brew --prefix openssl)/lib" CFLAGS="-I$(brew --prefix openssl)/include" sudo pip install cryptography
sudo easy_install ansible

installdir="/tmp/setupmac-$RANDOM"
mkdir $installdir

git clone https://github.com/jason-mcglade/setupmac.git $installdir
if [ ! -d $installdir ]; then
    echo "failed to find setupmac."
    echo "git cloned failed"
    exit 1
else
    cd $installdir
    ansible-playbook -i ./hosts playbook.yml --verbose
fi

echo "cleaning up..."

rm -Rfv /tmp/$installdir

echo "and we are done! Enjoy!"

exit 0
