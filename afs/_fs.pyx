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

def _volume_status(char* path):
    """
    _volume_status(path) -> tuple()

    Get information about the volume and path, and return it.
    Returns a tuple with 3 items:
     - a string containing the human-readable volume name
     - a string containing the offline message, if any
     - a dict() whose keys mirror the names of the
       OpenAFS VolumeStatus struct
    """
    cdef VolumeStatus *volstat
    cdef char volstat_buf[AFS_PIOCTL_MAXSIZE]
    cdef char *name, *offmsg
    cdef object py_volstat

    pioctl_read(path, VIOCGETVOLSTAT, volstat_buf, sizeof(volstat_buf), 1)
    volstat = <VolumeStatus *>volstat_buf
    # You can't assign a char * to a temporary Python string
    # (e.g. an array slice)
    # because it will be deallocated immediately
    name_slice = volstat_buf[sizeof(VolumeStatus):]
    name = name_slice
    offmsg_slice = name_slice[strlen(name) + 1:]
    offmsg = offmsg_slice
    # There _has_ to be a better way to turn structs
    # into objects.
    py_volstat = dict()
    py_volstat['Vid'] = volstat.Vid
    py_volstat['ParentId'] = volstat.ParentId
    py_volstat['Online'] = volstat.Online
    py_volstat['InService'] = volstat.InService
    py_volstat['Blessed'] = volstat.Blessed
    py_volstat['NeedsSalvage'] = volstat.NeedsSalvage
    py_volstat['Type'] = volstat.Type
    py_volstat['MinQuota'] = volstat.MinQuota
    py_volstat['MaxQuota'] = volstat.MaxQuota
    py_volstat['BlocksInUse'] = volstat.BlocksInUse
    py_volstat['PartBlocksAvail'] = volstat.PartBlocksAvail
    py_volstat['PartMaxBlocks'] = volstat.PartMaxBlocks
    return (name, offmsg, py_volstat)

def _fid(char *path):
    """
    _fid(path) -> dict()

    Return a dict with the VenusFid data for a given path
    """
    cdef VenusFid vfid
    cdef object py_fid

    pioctl_read(path, VIOCGETFID, <char *>&vfid, sizeof(VenusFid), 1)
    py_fid = dict()
    py_fid['Volume'] = vfid.Fid.Volume
    py_fid['Vnode'] = vfid.Fid.Vnode
    py_fid['Unique'] = vfid.Fid.Unique
    py_fid['Cell'] = vfid.Cell
    return py_fid
