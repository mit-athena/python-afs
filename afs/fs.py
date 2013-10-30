import errno
import os.path
from afs import _fs

def whichcell(path):
    """Return the cell name or None if the path is not in AFS"""
    try:
        return _fs.whichcell(path)
    except OSError as e:
        if e.errno == errno.EINVAL:
            return None
        else:
            raise

def inafs(path):
    """Return True if a path is in AFS."""
    try:
        _fs.whichcell(path)
    except OSError, e:
        if e.errno in (errno.EINVAL, errno.ENOENT):
            return False

    return True

def lsmount(path):
    """Return a volume name for a mountpoint."""
    # os.path.realpath will take care of ensuring we don't
    # get back anything that ends in . or .., and will
    # strip off any trailing slash
    (dirname, basename) = os.path.split(os.path.realpath(path))
    try:
        return _fs._lsmount(dirname, basename)
    except OSError as e:
        if e.errno == errno.EINVAL:
            return None
        else:
            raise
