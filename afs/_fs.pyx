from afs._util cimport *
from afs._util import pyafs_error

__all__ = ['whichcell',
           '_lsmount',
           ]

def whichcell(char* path):
    """Determine which AFS cell a particular path is in."""
    cdef char cell[MAXCELLCHARS]

    pioctl_read(path, VIOC_FILE_CELL_NAME, cell, sizeof(cell), 1)
    return cell

def _lsmount(char* parent, char* path):
    """
    lsmount(parent, path) -> str

    Given the parent directory, and a path, return the name of the
    volume.  Raises OSError.
    """
    cdef char mtpt[AFS_PIOCTL_MAXSIZE]

    pioctl_write(parent, VIOC_AFS_STAT_MT_PT, path, mtpt, 1)
    return mtpt
