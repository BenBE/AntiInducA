Unit OVFSProtocolls;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Virtual File System Submodule
//
// This unit defines the standard access protocolls of the VFS to access the
// native file system of Windows and the VFS of Omorphia.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE -cVFS, Protocol : Implement the VFS Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the Win32 Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the Unix Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the MMF Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the TCP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the UDP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the HTTP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the HTTPS Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the FTP Protocol Handler
//  TODO -oBenBE -cVFS, Protocol : Implement the UNC Protocol Handler
//
// *****************************************************************************
// News:
//
// *****************************************************************************
// Bugs:
//
// *****************************************************************************
// Info:
//
// *****************************************************************************

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

Interface

Uses
    OVFSManager;

Implementation

Uses
    OVFSProtocolVFS,
    OVFSProtocolWin32;
    
End.
