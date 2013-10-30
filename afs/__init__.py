import logging
# Make the submodules trivally available when
# you type "import afs"
import afs.fs
import afs.acl
import afs.pts

# Basic logging support for this package.
# Add a NullHandler to avoid "No handlers could be found" error
logging.getLogger('afs').addHandler(logging.NullHandler())
