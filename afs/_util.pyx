"""
General PyAFS utilities, such as error handling
"""

import sys
import logging

log = logging.getLogger('afs._util')

# otherwise certain headers are unhappy
cdef extern from "netinet/in.h": pass
cdef extern from "afs/vice.h": pass

cdef int _init = 0

# pioctl convenience wrappers

# Function for "reading" data from a pioctl
# "outbuffer" will get populated with the data in question
cdef extern int pioctl_read(char *path, afs_int32 op, void *outbuffer,
                            unsigned short size, afs_int32 follow) except -1:
    cdef ViceIoctl blob
    cdef afs_int32 code
    log.debug("pioctl_read() on %s with operation %d and size %d",
              path, op, size)
    blob.in_size  = 0
    blob.out_size = size
    blob.out = outbuffer
    code = pioctl(path, op, &blob, follow)
    log.debug("pioctl_read() returned %d", code)
    # This might work with the rest of OpenAFS, but I'm not convinced
    # the rest of it is consistent
    if code == -1:
        raise OSError(errno, strerror(errno))
    pyafs_error(code)
    return code

# Function for "writing" data to a pioctl
# "outbuffer" will get populated with the data in question
# Pass NULL for outbuffer in cases where we don't get anything
# back (e.g. VIOCSETAL)
# "outsize" will be ignored (forced to 0) if "outbuffer" is NULL
cdef extern int pioctl_write(char *path, afs_int32 op, char *inbuffer,
                             void *outbuffer, afs_int32 outsize,
                             afs_int32 follow) except -1:
    cdef ViceIoctl blob
    cdef afs_int32 code
    blob.cin = inbuffer
    blob.in_size = 1 + strlen(inbuffer)
    log.debug("pioctl_write() on %s with operation %d, and input '%s'",
              path, op, inbuffer)
    if outbuffer == NULL:
        log.debug("No output desired from pioctl_write()")
        blob.out_size = 0
    else:
        blob.out_size = outsize
        blob.out = outbuffer
    code = pioctl(path, op, &blob, follow)
    log.debug("pioctl_write() returned %d", code)
    # This might work with the rest of OpenAFS, but I'm not convinced
    # the rest of it is consistent
    if code == -1:
        raise OSError(errno, strerror(errno))
    pyafs_error(code)
    return code

# Error handling

class AFSException(Exception):
    def __init__(self, errno):
        self.errno = errno
        self.strerror = afs_error_message(errno)

    def __repr__(self):
        return "AFSException(%s)" % (self.errno)

    def __str__(self):
        return "[%s] %s" % (self.errno, self.strerror)

def pyafs_error(code):
    global _init
    if not _init:
        initialize_ACFG_error_table()
        initialize_KTC_error_table()
        initialize_PT_error_table()
        initialize_RXK_error_table()
        initialize_U_error_table()

        _init = 1

    if code != 0:
        raise AFSException(code)
