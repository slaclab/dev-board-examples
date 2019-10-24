# Setup environment
source /afs/slac.stanford.edu/g/reseng/rogue/anaconda/rogue_pre-release.sh

# Python Package directories
export FEB_DIR=${PWD}/../../firmware/common/python
export SURF_DIR=${PWD}/../../firmware/submodules/surf/python

# Setup python path
export PYTHONPATH=${SURF_DIR}:${FEB_DIR}:${PYTHONPATH}
