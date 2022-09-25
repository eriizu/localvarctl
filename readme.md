Having some programs aggressively read and right to someone's home directory while it's served by a distant NFS can lead to very big performance drops and some denials of service.

This script helps manage big programs state by using symlinks and puting it to directories that aren't served by NFS.
