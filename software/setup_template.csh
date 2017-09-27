
# Python Package directories
setenv COM_DIR    ${PWD}/../firmware/common
setenv TARGET_DIR    ${PWD}/../firmware/targets/XilinxKCU105DevBoard/Kcu105Pgp3
setenv SURF_DIR   ${PWD}/../firmware/submodules/surf
setenv ROGUE_DIR  ${PWD}/rogue

# Setup enivorment
# with SLAC AFS access
source /afs/slac.stanford.edu/g/reseng/python/3.6.1/settings.csh
source /afs/slac.stanford.edu/g/reseng/boost/1.64.0/settings.csh

# with local installations
#source /path/to/python/3.5.2/settings.csh
#source /path/to/boost/1.62.0/settings.csh

# Setup python path
setenv PYTHONPATH ${PWD}/python:${SURF_DIR}/python:${COM_DIR}/python:${ROGUE_DIR}/python:${TARGET_DIR}/python

# Setup library path
setenv LD_LIBRARY_PATH ${ROGUE_DIR}/python::${LD_LIBRARY_PATH}

