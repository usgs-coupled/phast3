# Microsoft Developer Studio Generated NMAKE File, Based on phastinput.dsp
!IF "$(CFG)" == ""
CFG=phastinput - Win32 Debug
!MESSAGE No configuration specified. Defaulting to phastinput - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "phastinput - Win32 Release" && "$(CFG)" != "phastinput - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "phastinput.mak" CFG="phastinput - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "phastinput - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "phastinput - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "phastinput - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\phastinput.exe"


CLEAN :
	-@erase "$(INTDIR)\accumulate.obj"
	-@erase "$(INTDIR)\check.obj"
	-@erase "$(INTDIR)\getopt.obj"
	-@erase "$(INTDIR)\gpc.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\message.obj"
	-@erase "$(INTDIR)\phastinput.res"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\rivers.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\time.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\wells.obj"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(OUTDIR)\phastinput.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/compile_only /nologo /warn:nofileopt /module:"Release/" /object:"Release/" 
F90_OBJS=.\Release/
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\phastinput.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phastinput.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phastinput.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\phastinput.pdb" /machine:I386 /out:"$(OUTDIR)\phastinput.exe" /RELEASE 
LINK32_OBJS= \
	"$(INTDIR)\accumulate.obj" \
	"$(INTDIR)\check.obj" \
	"$(INTDIR)\getopt.obj" \
	"$(INTDIR)\gpc.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\message.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\rivers.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\time.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\wells.obj" \
	"$(INTDIR)\write.obj" \
	"$(INTDIR)\phastinput.res"

"$(OUTDIR)\phastinput.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phastinput - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\phastinput.exe"


CLEAN :
	-@erase "$(INTDIR)\accumulate.obj"
	-@erase "$(INTDIR)\check.obj"
	-@erase "$(INTDIR)\getopt.obj"
	-@erase "$(INTDIR)\gpc.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\message.obj"
	-@erase "$(INTDIR)\phastinput.res"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\rivers.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\time.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\wells.obj"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(OUTDIR)\phastinput.exe"
	-@erase "$(OUTDIR)\phastinput.ilk"
	-@erase "$(OUTDIR)\phastinput.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/check:bounds /compile_only /debug:full /nologo /traceback /warn:argument_checking /warn:nofileopt /module:"Debug/" /object:"Debug/" /pdbfile:"Debug/DF60.PDB" 
F90_OBJS=.\Debug/
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\phastinput.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phastinput.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phastinput.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\phastinput.pdb" /debug /machine:I386 /out:"$(OUTDIR)\phastinput.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\accumulate.obj" \
	"$(INTDIR)\check.obj" \
	"$(INTDIR)\getopt.obj" \
	"$(INTDIR)\gpc.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\message.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\rivers.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\time.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\wells.obj" \
	"$(INTDIR)\write.obj" \
	"$(INTDIR)\phastinput.res"

"$(OUTDIR)\phastinput.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.SUFFIXES: .fpp

.for{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f90{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.fpp{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("phastinput.dep")
!INCLUDE "phastinput.dep"
!ELSE 
!MESSAGE Warning: cannot find "phastinput.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "phastinput - Win32 Release" || "$(CFG)" == "phastinput - Win32 Debug"
SOURCE=..\accumulate.c

"$(INTDIR)\accumulate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\check.c

"$(INTDIR)\check.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\getopt.c

"$(INTDIR)\getopt.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\gpc.c

"$(INTDIR)\gpc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\main.c

"$(INTDIR)\main.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\message.c

"$(INTDIR)\message.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=.\phastinput.rc

"$(INTDIR)\phastinput.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=..\read.c

"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\rivers.c

"$(INTDIR)\rivers.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\structures.c

"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\time.c

"$(INTDIR)\time.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\utilities.c

"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\wells.c

"$(INTDIR)\wells.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\write.c

"$(INTDIR)\write.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)



!ENDIF 

