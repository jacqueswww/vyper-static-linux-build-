#!/usr/bin/bash

python="/usr/bin/python3"
REPO_DIR="./vyper"
OUTPUT_DIR="./bin/"
VYPER_VIRTUAL_ENV="env"
STATICX_VIRTUAL_ENV="env2"
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ ! -d $REPO_DIR ]
then
    git clone https://github.com/ethereum/vyper.git vyper
else
    echo -e "* ${GREEN} Pulling updates${NC}"
    cd $REPO_DIR
    git fetch --tags
fi

tags=("v0.1.0-beta.7" "v0.1.0-beta.8")

function make_virtualenv {
    virtualenv=$1
    if [ ! -d $virtualenv ]
    then
        echo -e "* ${GREEN} Creating virtualenv: ${NC} $1"
        $python -m venv $virtualenv
    fi
}

# Setup vyper
make_virtualenv $VYPER_VIRTUAL_ENV
make_virtualenv $STATICX_VIRTUAL_ENV

source $VYPER_VIRTUAL_ENV/bin/activate
pip install -e .
pip install pyinstaller
source $STATICX_VIRTUAL_ENV/bin/activate
pip install staticx

# Build tags
for tag in ${tags[@]}
do
    source $VYPER_VIRTUAL_ENV/bin/activate
    echo "* ${GREEN} Compiling:${NC} $tag"
    git checkout tags/$tag
    pyinstaller -y bin/vyper
    cd ../
    deactivate
    source $STATICX_VIRTUAL_ENV/bin/activate
    staticx $REPO_DIR/dist/bin/vyper $(umod)
done
