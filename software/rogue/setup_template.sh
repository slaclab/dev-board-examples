
# Setup environment
source /afs/slac/g/reseng/rogue/master/setup_env.sh
# source /afs/slac/g/reseng/rogue/v2.2.0/setup_env.sh

# Python Package directories
export FEB_DIR=${PWD}/../firmware/common/python
export SURF_DIR=${PWD}/../firmware/submodules/surf/python

# Setup python path
export PYTHONPATH=${SURF_DIR}:${FEB_DIR}:${PYTHONPATH}

