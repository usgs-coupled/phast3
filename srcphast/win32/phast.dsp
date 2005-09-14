# Microsoft Developer Studio Project File - Name="phast" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=phast - Win32 ser_debug_mem
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "phast.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "phast.mak" CFG="phast - Win32 ser_debug_mem"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "phast - Win32 ser" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 ser_debug" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 mpich_debug" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 mpich_no_hdf_debug" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 mpich" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 mpich_profile" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 merge" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 merge_debug" (based on "Win32 (x86) Console Application")
!MESSAGE "phast - Win32 ser_debug_mem" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "phast - Win32 ser"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "ser"
# PROP BASE Intermediate_Dir "ser"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "ser"
# PROP Intermediate_Dir "ser"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /compile_only /nologo /warn:nofileopt
# ADD F90 /assume:underscore /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /warn:nofileopt
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /Zi /O2 /Op /I "$(DEV_HDF5_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /libpath:"$(DEV_HDF5_LIB)" /RELEASE
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "ser_debug"
# PROP BASE Intermediate_Dir "ser_debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "ser_debug"
# PROP Intermediate_Dir "ser_debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /check:bounds /compile_only /debug:full /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /assume:underscore /browser /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /FR /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libc.lib" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)"
# SUBTRACT LINK32 /verbose /nodefaultlib

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "phast___Win32_mpich_debug"
# PROP BASE Intermediate_Dir "phast___Win32_mpich_debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "mpich_debug"
# PROP Intermediate_Dir "mpich_debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /assume:underscore /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libc.lib" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)"
# SUBTRACT BASE LINK32 /nodefaultlib
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)"
# SUBTRACT LINK32 /incremental:no /nodefaultlib

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "phast___Win32_mpich_no_hdf_debug"
# PROP BASE Intermediate_Dir "phast___Win32_mpich_no_hdf_debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "mpich_no_hdf_debug"
# PROP Intermediate_Dir "mpich_no_hdf_debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /check:bounds /compile_only /debug:full /define:"MPICH_NAME" /define:"USE_MPI" /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /assume:underscore /check:bounds /compile_only /debug:full /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /incremental:no /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)"
# SUBTRACT BASE LINK32 /nodefaultlib
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /incremental:no /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB_D)"
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "phast___Win32_mpich"
# PROP BASE Intermediate_Dir "phast___Win32_mpich"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "mpich"
# PROP Intermediate_Dir "mpich"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /compile_only /define:"HDF5_CREATE" /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /warn:nofileopt
# ADD F90 /assume:underscore /compile_only /debug:full /define:"HDF5_CREATE" /define:"USE_MPI" /define:"MPICH_NAME" /fpp /fpscomp:nolibs /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /warn:nofileopt
# SUBTRACT F90 /fpscomp:general
# ADD BASE CPP /nologo /W3 /GX /O2 /I "$(DEV_HDF5_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /Zi /O2 /Op /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386 /libpath:"$(DEV_HDF5_LIB)"
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /machine:I386 /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)" /RELEASE
# SUBTRACT LINK32 /pdb:none /debug

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "phast___Win32_mpich_profile"
# PROP BASE Intermediate_Dir "phast___Win32_mpich_profile"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "mpich_profile"
# PROP Intermediate_Dir "mpich_profile"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /compile_only /debug:full /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt
# ADD F90 /assume:underscore /compile_only /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt
# ADD BASE CPP /nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /debug /machine:I386 /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)"
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /profile /debug /machine:I386 /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "phast___Win32_merge"
# PROP BASE Intermediate_Dir "phast___Win32_merge"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "merge"
# PROP Intermediate_Dir "merge"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /compile_only /debug:full /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt
# ADD F90 /assume:underscore /compile_only /debug:full /define:"MERGE_FILES" /define:"HDF5_CREATE" /define:"USE_MPI" /define:"MPICH_NAME" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt
# ADD BASE CPP /nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /Zi /O2 /Op /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "MERGE_FILES" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /debug /machine:I386 /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)"
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /debug /machine:I386 /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "phast___Win32_merge_debug"
# PROP BASE Intermediate_Dir "phast___Win32_merge_debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "merge_debug"
# PROP Intermediate_Dir "merge_debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /assume:underscore /browser /check:bounds /compile_only /debug:full /define:"MERGE_FILES" /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "MERGE_FILES" /D "USE_MPI" /D "HDF5_CREATE" /FR /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)"
# SUBTRACT BASE LINK32 /incremental:no /nodefaultlib
# ADD LINK32 dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)"
# SUBTRACT LINK32 /incremental:no /nodefaultlib

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "phast___Win32_ser_debug_mem"
# PROP BASE Intermediate_Dir "phast___Win32_ser_debug_mem"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "ser_debug_mem"
# PROP Intermediate_Dir "ser_debug_mem"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /assume:underscore /browser /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /assume:underscore /browser /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /FR /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "WIN32_MEMORY_DEBUG" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /FR /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libc.lib" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)"
# SUBTRACT BASE LINK32 /verbose /nodefaultlib
# ADD LINK32 dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libc.lib" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)"
# SUBTRACT LINK32 /verbose /nodefaultlib

!ENDIF 

# Begin Target

# Name "phast - Win32 ser"
# Name "phast - Win32 ser_debug"
# Name "phast - Win32 mpich_debug"
# Name "phast - Win32 mpich_no_hdf_debug"
# Name "phast - Win32 mpich"
# Name "phast - Win32 mpich_profile"
# Name "phast - Win32 merge"
# Name "phast - Win32 merge_debug"
# Name "phast - Win32 ser_debug_mem"
# Begin Group "COMMON_COBJS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\phreeqc\advection.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\basic.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\basicsubs.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\cl1.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\cvdense.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\cvode.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\dense.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\dw.c
# End Source File
# Begin Source File

SOURCE=..\hst.c
# End Source File
# Begin Source File

SOURCE=..\hstsubs.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\input.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\integrate.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\inverse.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\isotopes.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\kinetics.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\mainsubs.c
# End Source File
# Begin Source File

SOURCE=..\mix.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\model.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\nvector.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\nvector_serial.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\output.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\p2clib.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\parse.c
# End Source File
# Begin Source File

SOURCE=..\phast_files.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\phqalloc.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\pitzer.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\pitzer_structures.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\prep.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\print.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\read.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\readtr.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\smalldense.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\spread.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\step.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\structures.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\sundialsmath.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\tally.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\tidy.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\transport.c
# End Source File
# Begin Source File

SOURCE=..\phreeqc\utilities.c
# End Source File
# End Group
# Begin Group "COMMON_FOBJS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\abmult.f90
DEP_F90_ABMUL=\
	".\ser\machine_constants.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\aplbce.f90
DEP_F90_APLBC=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\aplbce_ss_flow.f90
DEP_F90_APLBCE=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\aplbci.f90
DEP_F90_APLBCI=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\armult.f90
DEP_F90_ARMUL=\
	".\ser\machine_constants.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\asembl.f90
DEP_F90_ASEMB=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\asmslc.f90
DEP_F90_ASMSL=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	".\ser\mcs2.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\asmslp.f90
DEP_F90_ASMSLP=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcs2.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\asmslp_ss_flow.f90
DEP_F90_ASMSLP_=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcs2.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\bsode.f90
DEP_F90_BSODE=\
	".\ser\machine_constants.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\calc_velocity.f90
DEP_F90_CALC_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\calcc.f90
DEP_F90_CALCC=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcp.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\clog.f90
DEP_F90_CLOG_=\
	".\ser\f_units.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\closef.F90
DEP_F90_CLOSE=\
	".\ser\f_units.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcs2.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
NODEP_F90_CLOSE=\
	".\ser\mpi_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\coeff.f90
DEP_F90_COEFF=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\coeff_ss_flow.f90
DEP_F90_COEFF_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\crsdsp.f90
DEP_F90_CRSDS=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\d4ord.f90
DEP_F90_D4ORD=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\d4zord.f90
DEP_F90_D4ZOR=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\dbmult.f90
DEP_F90_DBMUL=\
	".\ser\machine_constants.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\dump.f90
DEP_F90_DUMP_=\
	".\ser\f_units.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\efact.f90
DEP_F90_EFACT=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ehoftp.f90
DEP_F90_EHOFT=\
	".\ser\machine_constants.mod"\
	".\ser\mcp.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\el1slv.f90
DEP_F90_EL1SL=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\elslv.f90
DEP_F90_ELSLV=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\error1.f90
DEP_F90_ERROR=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\error2.f90
DEP_F90_ERROR2=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\error3.f90
DEP_F90_ERROR3=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\error4.f90
DEP_F90_ERROR4=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\errprt.f90
DEP_F90_ERRPR=\
	".\ser\mcc.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\etom1.f90
DEP_F90_ETOM1=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\etom2.f90
DEP_F90_ETOM2=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mg3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\euslv.f90
DEP_F90_EUSLV=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\formr.f90
DEP_F90_FORMR=\
	".\ser\machine_constants.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\gcgris.f90
DEP_F90_GCGRI=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\hunt.f90
DEP_F90_HUNT_=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\incidx.f90
DEP_F90_INCID=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\indx_rewi.f90
DEP_F90_INDX_=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\indx_rewi_bc.f90
DEP_F90_INDX_R=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init1.f90
DEP_F90_INIT1=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init2_1.f90
DEP_F90_INIT2=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcs2.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init2_2.f90
DEP_F90_INIT2_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init2_3.f90
DEP_F90_INIT2_3=\
	".\ser\machine_constants.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init2_post_ss.f90
DEP_F90_INIT2_P=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\init3.f90
DEP_F90_INIT3=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\mg3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\interp.f90
DEP_F90_INTER=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\irewi.f90
DEP_F90_IREWI=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldchar.f90
DEP_F90_LDCHA=\
	".\ser\machine_constants.mod"\
	".\ser\mcg.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldci.f90
DEP_F90_LDCI_=\
	".\ser\mcg.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldcir.f90
DEP_F90_LDCIR=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldind.f90
DEP_F90_LDIND=\
	".\ser\mcg.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldipen.f90
DEP_F90_LDIPE=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\ldmar1.f90
DEP_F90_LDMAR=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\load_indx_bc.f90
DEP_F90_LOAD_=\
	".\ser\machine_constants.mod"\
	".\ser\mcv.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\lsolv.f90
DEP_F90_LSOLV=\
	".\ser\machine_constants.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\modules.f90
# End Source File
# Begin Source File

SOURCE=..\mtoijk.f90
# End Source File
# Begin Source File

SOURCE=..\nintrp.f90
DEP_F90_NINTR=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\openf.F90
DEP_F90_OPENF=\
	".\ser\f_units.mod"\
	".\ser\mcch.mod"\
	
NODEP_F90_OPENF=\
	".\ser\mpi_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\phast.F90
DEP_F90_PHAST=\
	".\ser\mcch.mod"\
	
NODEP_F90_PHAST=\
	".\ser\mpi_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\phast_root.F90
DEP_F90_PHAST_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\prchar.f90
DEP_F90_PRCHA=\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\print_control_mod.f90
DEP_F90_PRINT=\
	".\ser\machine_constants.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\prntar.f90
DEP_F90_PRNTA=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rbord.f90
DEP_F90_RBORD=\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\read1.f90
DEP_F90_READ1=\
	".\ser\f_units.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcs.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\read2.f90
DEP_F90_READ2=\
	"..\ifrd.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\read3.f90
DEP_F90_READ3=\
	"..\ifrd.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\reordr.f90
DEP_F90_REORD=\
	".\ser\mcg.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rewi.f90
DEP_F90_REWI_=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rewi3.f90
DEP_F90_REWI3=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mct.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rfact.f90
DEP_F90_RFACT=\
	".\ser\machine_constants.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rfactm.f90
DEP_F90_RFACTM=\
	".\ser\machine_constants.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rhsn.f90
DEP_F90_RHSN_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\rhsn_ss_flow.f90
DEP_F90_RHSN_S=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\sbcflo.f90
DEP_F90_SBCFL=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\scale_jds.f90
DEP_F90_SCALE=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\simulate_ss_flow.f90
DEP_F90_SIMUL=\
	".\ser\mcc.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\stonb.f90
# End Source File
# Begin Source File

SOURCE=..\sumcal1.f90
DEP_F90_SUMCA=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\sumcal2.f90
DEP_F90_SUMCAL=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\sumcal_ss_flow.f90
DEP_F90_SUMCAL_=\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\terminate_phast.F90
DEP_F90_TERMI=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mg2.mod"\
	
NODEP_F90_TERMI=\
	".\ser\mpi_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\tfrds.f90
DEP_F90_TFRDS=\
	".\ser\machine_constants.mod"\
	".\ser\mcm.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\timstp.f90
DEP_F90_TIMST=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\timstp_ss_flow.f90
DEP_F90_TIMSTP=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\update_print_flags.f90
DEP_F90_UPDAT=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\usolv.f90
DEP_F90_USOLV=\
	".\ser\machine_constants.mod"\
	".\ser\mcs.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\viscos.f90
DEP_F90_VISCO=\
	".\ser\machine_constants.mod"\
	".\ser\mcp.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\vpsv.f90
DEP_F90_VPSV_=\
	".\ser\machine_constants.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wbbal.f90
DEP_F90_WBBAL=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wbcflo.f90
DEP_F90_WBCFL=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wellsc.f90
DEP_F90_WELLS=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wellsc_ss_flow.f90
DEP_F90_WELLSC=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcm.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wellsr.f90
DEP_F90_WELLSR=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wellsr_ss_flow.f90
DEP_F90_WELLSR_=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\welris.f90
DEP_F90_WELRI=\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\wfdydz.f90
DEP_F90_WFDYD=\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcp.mod"\
	".\ser\mcw.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write1.f90
DEP_F90_WRITE=\
	".\ser\f_units.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write2_1.f90
DEP_F90_WRITE2=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcs.mod"\
	".\ser\mct.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write2_2.f90
DEP_F90_WRITE2_=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\phys_const.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write3.f90
DEP_F90_WRITE3=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\mg3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write3_ss_flow.f90
DEP_F90_WRITE3_=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcp.mod"\
	".\ser\mcw.mod"\
	".\ser\mg3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write4.f90
DEP_F90_WRITE4=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write5.f90
DEP_F90_WRITE5=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write5_ss_flow.f90
DEP_F90_WRITE5_=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mct.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\write6.f90
DEP_F90_WRITE6=\
	"..\ifwr.inc"\
	".\ser\f_units.mod"\
	".\ser\machine_constants.mod"\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\print_control_mod.mod"\
	
# End Source File
# End Group
# Begin Group "HDF_OBJS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\hdf.c

!IF  "$(CFG)" == "phast - Win32 ser"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\hdf_f.f90
DEP_F90_HDF_F=\
	".\ser\mcb.mod"\
	".\ser\mcc.mod"\
	".\ser\mcch.mod"\
	".\ser\mcg.mod"\
	".\ser\mcn.mod"\
	".\ser\mcp.mod"\
	".\ser\mcv.mod"\
	".\ser\mcw.mod"\
	".\ser\mg2.mod"\
	

!IF  "$(CFG)" == "phast - Win32 ser"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

!ENDIF 

# End Source File
# End Group
# Begin Group "MPI_OBJS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\mpimod.F90

!IF  "$(CFG)" == "phast - Win32 ser"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\phast_slave.F90

!IF  "$(CFG)" == "phast - Win32 ser"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

!ENDIF 

# End Source File
# End Group
# Begin Group "MERGE_OBJS"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\merge.c

!IF  "$(CFG)" == "phast - Win32 ser"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

# PROP BASE Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

# PROP BASE Exclude_From_Build 1
# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# End Group
# Begin Source File

SOURCE=.\phast.rc
# End Source File
# End Target
# End Project
