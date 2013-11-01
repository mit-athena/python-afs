import errno
import os.path
import socket
import logging
import math
import sys

from afs import _fs
log = logging.getLogger('afs.fs')

class AFSVolumeStatus(object):
    def __init__(self, volstat):
        if type(volstat) is not tuple or len(volstat) != 3:
            raise TypeError("AFSVolumeStatus takes a tuple of (str,str,dict)")
        if [type(x) for x in volstat] != [str,str,dict]:
            raise TypeError("AFSVolumeStatus takes a tuple of (str,str,dict)")
        self.name = volstat[0]
        self.offline_message = volstat[1]
        for k,v in volstat[2].items():
            setattr(self, k, v)

    def __repr__(self):
        return self.__class__.__name__ + ': ' + repr(self.__dict__)

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
    except OSError as e:
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

def examine(path):
    """
    Given a path in AFS, tells you about the path and volume that
    contains it.  Returns a tuple (volumestatus, fid) where
    "volumestatus" is an object (with attributes matching the struct
    VolumeStatus in OpenAFS), as well as some extra attributes, like
    the volume name, and the offline message.  "fid" is a dict with
    keys matching the VenusFid struct in OpenAFS, or None if the call
    failed.
    """
    try:
        _volstat = _fs._volume_status(path)
    except OSError as e:
        if e.errno == errno.EINVAL:
            return None
        else:
            raise
    _fid = None
    try:
        _fid = _fs._fid(path)
    except:
        pass
    return (AFSVolumeStatus(_volstat), _fid)

def _reverse_lookup(ip):
    """
    Convenience function to provide best-effort reverse-resolution
    """
    try:
        return socket.gethostbyaddr(ip)[0]
    except socket.herror as e:
        log.debug("Failed to reverse-resolve %s: %s", ip, e)
        return ip
    except IndexError:
        log.warning("IndexError while reverse-resolving IP, shouldn't happen")
        return ip

def whereis(path, dns=True):
    """
    Return a list of hostnames and/or IP addresses representing
    the AFS file servers where the path can be found.

    Pass dns=False to disable hostname lookup
    """
    addrs = []
    try:
        addrs = _fs._whereis(path)
        if dns:
            return [_reverse_lookup(x) for x in addrs]
        else:
            return addrs
    except OSError as e:
        if e.errno == errno.EINVAL:
            return None
        else:
            raise
