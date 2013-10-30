import logging

# Basic logging support for this package.
# Add a NullHandler to avoid "No handlers could be found" error
logging.getLogger('afs').addHandler(logging.NullHandler())
