
# Setup environment
source /afs/slac/g/reseng/rogue/master/setup_env.csh
# source /afs/slac/g/reseng/rogue/v2.2.0/setup_env.csh

# Python Package directories
setenv FEB_DIR    ${PWD}/../../firmware/common/python
setenv SURF_DIR   ${PWD}/../../firmware/submodules/surf/python

# Setup python path
setenv PYTHONPATH ${SURF_DIR}:${FEB_DIR}:${PYTHONPATH}

