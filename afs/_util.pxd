cdef extern from *:
    ctypedef long size_t

cdef extern from "errno.h":
    int errno

cdef extern from "string.h":
    char * strerror(int errnum)
    char * strncpy(char *s1, char *s2, size_t n)
    void * memset(void *b, int c, size_t n)
    void * memcpy(void *s1, void *s2, size_t n)
    size_t strlen(char *s)

cdef extern from "stdlib.h":
     void * malloc(size_t size)
     void free(void *)

cdef extern from "netinet/in.h":
    struct in_addr:
        int s_addr
    struct sockaddr_in:
        short sin_family
        unsigned short sin_port
        in_addr sin_addr
        char sin_zero[8]

# Note that these are in an "extern", so the resulting C code will use
# the actual type definitions in the header file.  The ctypedef here
# controls C<->Python conversion, ensuring afs_uint32 will turn into a
# Python long and afs_int32 will turn into a Python int.  This is
# really only relevant for 32-bit interpreters.
cdef extern from "afs/stds.h":
    ctypedef unsigned long afs_uint32
    ctypedef long afs_int32

cdef extern from "afs/dirpath.h":
    char * AFSDIR_CLIENT_ETC_DIRPATH

cdef extern from "afs/afs_consts.h":
    enum:
        AFS_PIOCTL_MAXSIZE
        AFS_MAXHOSTS

cdef extern from "afs/cellconfig.h":
    enum:
        MAXCELLCHARS
        MAXHOSTSPERCELL
        MAXHOSTCHARS

    # We just pass afsconf_dir structs around to other AFS functions,
    # so this can be treated as opaque
    struct afsconf_dir:
        pass

    # For afsconf_cell, on the other hand, we care about everything
    struct afsconf_cell:
        char name[MAXCELLCHARS]
        short numServers
        short flags
        sockaddr_in hostAddr[MAXHOSTSPERCELL]
        char hostName[MAXHOSTSPERCELL][MAXHOSTCHARS]
        char *linkedCell
        int timeout

    afsconf_dir *afsconf_Open(char *adir)
    int afsconf_GetCellInfo(afsconf_dir *adir,
                            char *acellName,
                            char *aservice,
                            afsconf_cell *acellInfo)

cdef extern from "rx/rxkad.h":
    ctypedef char rxkad_level

    enum:
        MAXKTCNAMELEN
        MAXKTCREALMLEN

    enum:
        rxkad_clear
        rxkad_crypt

    struct ktc_encryptionKey:
        pass

    struct ktc_principal:
        char name[MAXKTCNAMELEN]
        char instance[MAXKTCNAMELEN]
        char cell[MAXKTCREALMLEN]

    struct rx_securityClass:
        pass

    rx_securityClass *rxkad_NewClientSecurityObject(rxkad_level level,
                                                    ktc_encryptionKey *sessionKey,
                                                    afs_int32 kvno,
                                                    int ticketLen,
                                                    char *ticket)
    rx_securityClass *rxnull_NewClientSecurityObject()

    int rxs_Release(rx_securityClass *aobj)

cdef extern from "rx/rx.h":
    int rx_Init(int port)
    void rx_Finalize()

    struct rx_connection:
        pass

    rx_connection *rx_NewConnection(afs_uint32 shost,
                                    unsigned short sport,
                                    unsigned short sservice,
                                    rx_securityClass *securityObject,
                                    int serviceSecurityIndex)

cdef extern from "afs/auth.h":
    enum:
        MAXKTCTICKETLEN

    struct ktc_token:
        ktc_encryptionKey sessionKey
        short kvno
        int ticketLen
        char ticket[MAXKTCTICKETLEN]

    int ktc_GetToken(ktc_principal *server,
                     ktc_token *token,
                     int tokenLen,
                     ktc_principal *client)

cdef extern from "afs/prclient.h":
    enum:
        PRSRV

cdef extern from "ubik.h":
    enum:
        MAXSERVERS

    # ubik_client is an opaque struct, so we don't care about its members
    struct ubik_client:
        pass

    int ubik_ClientInit(rx_connection **serverconns,
                        ubik_client **aclient)
    afs_int32 ubik_ClientDestroy(ubik_client *aclient)

cdef extern from "afs/com_err.h":
    char * afs_error_message(int)

# All AFS error tables
cdef extern from "afs/auth.h":
    void initialize_KTC_error_table()
cdef extern from "afs/cellconfig.h":
    void initialize_ACFG_error_table()
cdef extern from "afs/pterror.h":
    void initialize_PT_error_table()
cdef extern from "rx/rxkad.h":
    void initialize_RXK_error_table()
cdef extern from "ubik.h":
    void initialize_U_error_table()

cdef extern from "afs/vice.h":
    struct ViceIoctl:
        void *cin "in"
        void *out
        unsigned short out_size
        unsigned short in_size

cdef extern from "afs/venus.h":
    enum:
        # PIOCTLS to Venus that we use
        VIOCGETAL, VIOC_GETVCXSTATUS2, VIOCSETAL, VIOC_FILE_CELL_NAME,
        VIOC_AFS_STAT_MT_PT, VIOCGETVOLSTAT, VIOCGETFID, VIOCWHEREIS,

# This is probably a terrible idea, since afsint.h is generated,
# Specifically, the "real" definition is in afsint.xg, but this
# should work across Linuxen
cdef extern from "afs/afsint.h":
    ctypedef struct VolumeStatus:
        afs_int32 Vid
        afs_int32 ParentId
        char Online
        char InService
        char Blessed
        char NeedsSalvage
        afs_int32 Type
        afs_int32 MinQuota
        afs_int32 MaxQuota
        afs_int32 BlocksInUse
        afs_int32 PartBlocksAvail
        afs_int32 PartMaxBlocks

    ctypedef struct AFSFid:
        afs_uint32 Volume
        afs_uint32 Vnode
        afs_uint32 Unique

# This is from afs.h, but it's in the kernel-only part
# and Pyrex/Cython is unhappy.  So we re-define it here,
# just like they do in venus/fs.c.
cdef struct VenusFid:
    afs_int32 Cell
    AFSFid Fid

# pioctl doesn't actually have a header, so we have to define it here
cdef extern int pioctl(char *, afs_int32, ViceIoctl *, afs_int32)
cdef int pioctl_read(char *, afs_int32, void *, unsigned short, afs_int32) except -1
cdef int pioctl_write(char *, afs_int32, char *, void *, afs_int32) except -1

