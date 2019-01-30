
# Setup environment
source /afs/slac/g/reseng/rogue/pre-release/setup_rogue.csh

# Python Package directories
setenv FEB_DIR    ${PWD}/../../firmware/common/python
setenv SURF_DIR   ${PWD}/../../firmware/submodules/surf/python

# Setup python path
setenv PYTHONPATH ${SURF_DIR}:${FEB_DIR}:${PYTHONPATH}

