# Microsoft Developer Studio Generated NMAKE File, Based on phast.dsp
!IF "$(CFG)" == ""
CFG=phast - Win32 ser_debug_mem
!MESSAGE No configuration specified. Defaulting to phast - Win32 ser_debug_mem.
!ENDIF 

!IF "$(CFG)" != "phast - Win32 ser" && "$(CFG)" != "phast - Win32 ser_debug" && "$(CFG)" != "phast - Win32 mpich_debug" && "$(CFG)" != "phast - Win32 mpich_no_hdf_debug" && "$(CFG)" != "phast - Win32 mpich" && "$(CFG)" != "phast - Win32 mpich_profile" && "$(CFG)" != "phast - Win32 merge" && "$(CFG)" != "phast - Win32 merge_debug" && "$(CFG)" != "phast - Win32 ser_debug_mem"
!MESSAGE Invalid configuration "$(CFG)" specified.
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

!IF  "$(CFG)" == "phast - Win32 ser"

OUTDIR=.\ser
INTDIR=.\ser
# Begin Custom Macros
OutDir=.\ser
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /compile_only /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /warn:nofileopt /module:"ser/" /object:"ser/" 
F90_OBJS=.\ser/
CPP_PROJ=/nologo /ML /W3 /GX /O2 /I "$(DEV_HDF5_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\phast.pdb" /machine:I386 /out:"$(OUTDIR)\phast.exe" /libpath:"$(DEV_HDF5_LIB)" /RELEASE 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

OUTDIR=.\ser_debug
INTDIR=.\ser_debug
# Begin Custom Macros
OutDir=.\ser_debug
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe" "$(OUTDIR)\phast.bsc"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\abmult.sbr"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\advection.sbr"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce.sbr"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.sbr"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\aplbci.sbr"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\armult.sbr"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asembl.sbr"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslc.sbr"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp.sbr"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.sbr"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basic.sbr"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\basicsubs.sbr"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\bsode.sbr"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calc_velocity.sbr"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\calcc.sbr"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\cl1.sbr"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\clog.sbr"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\closef.sbr"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff.sbr"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.sbr"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\crsdsp.sbr"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvdense.sbr"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\cvode.sbr"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4ord.sbr"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\d4zord.sbr"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dbmult.sbr"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dense.sbr"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\dump.sbr"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\efact.sbr"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\ehoftp.sbr"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\el1slv.sbr"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\elslv.sbr"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error1.sbr"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error2.sbr"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error3.sbr"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\error4.sbr"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\errprt.sbr"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom1.sbr"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\etom2.sbr"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\euslv.sbr"
	-@erase "$(INTDIR)\f_units.mod"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\formr.sbr"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\gcgris.sbr"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf.sbr"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hdf_f.sbr"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hst.sbr"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hstsubs.sbr"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\hunt.sbr"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\incidx.sbr"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi.sbr"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.sbr"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init1.sbr"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_1.sbr"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_2.sbr"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_3.sbr"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init2_post_ss.sbr"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\init3.sbr"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\input.sbr"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\integrate.sbr"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\interp.sbr"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\inverse.sbr"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\irewi.sbr"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\isotopes.sbr"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\kinetics.sbr"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldchar.sbr"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldci.sbr"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldcir.sbr"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldind.sbr"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldipen.sbr"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\ldmar1.sbr"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\load_indx_bc.sbr"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\lsolv.sbr"
	-@erase "$(INTDIR)\machine_constants.mod"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mainsubs.sbr"
	-@erase "$(INTDIR)\mcb.mod"
	-@erase "$(INTDIR)\mcc.mod"
	-@erase "$(INTDIR)\mcch.mod"
	-@erase "$(INTDIR)\mcg.mod"
	-@erase "$(INTDIR)\mcm.mod"
	-@erase "$(INTDIR)\mcn.mod"
	-@erase "$(INTDIR)\mcp.mod"
	-@erase "$(INTDIR)\mcs.mod"
	-@erase "$(INTDIR)\mcs2.mod"
	-@erase "$(INTDIR)\mct.mod"
	-@erase "$(INTDIR)\mcv.mod"
	-@erase "$(INTDIR)\mcw.mod"
	-@erase "$(INTDIR)\mg2.mod"
	-@erase "$(INTDIR)\mg3.mod"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\mix.sbr"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\model.sbr"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\modules.sbr"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\mtoijk.sbr"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nintrp.sbr"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector.sbr"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\nvector_serial.sbr"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\openf.sbr"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\output.sbr"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\p2clib.sbr"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\parse.sbr"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast.sbr"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phast_files.sbr"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\phqalloc.sbr"
	-@erase "$(INTDIR)\phys_const.mod"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prchar.sbr"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\prep.sbr"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print.sbr"
	-@erase "$(INTDIR)\print_control_mod.mod"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\print_control_mod.sbr"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\prntar.sbr"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\rbord.sbr"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read.sbr"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read1.sbr"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read2.sbr"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\read3.sbr"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\readtr.sbr"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\reordr.sbr"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi.sbr"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rewi3.sbr"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfact.sbr"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rfactm.sbr"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn.sbr"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.sbr"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\sbcflo.sbr"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.sbr"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\smalldense.sbr"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\spread.sbr"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\step.sbr"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\stonb.sbr"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\structures.sbr"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal1.sbr"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal2.sbr"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.sbr"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\sundialsmath.sbr"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\tally.sbr"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\terminate_phast.sbr"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tfrds.sbr"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\tidy.sbr"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp.sbr"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.sbr"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\transport.sbr"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\update_print_flags.sbr"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\usolv.sbr"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\utilities.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\viscos.sbr"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\vpsv.sbr"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbbal.sbr"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wbcflo.sbr"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc.sbr"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.sbr"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr.sbr"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.sbr"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\welris.sbr"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\wfdydz.sbr"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write1.sbr"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_1.sbr"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write2_2.sbr"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3.sbr"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write3_ss_flow.sbr"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write4.sbr"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5.sbr"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write5_ss_flow.sbr"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(INTDIR)\write6.sbr"
	-@erase "$(OUTDIR)\phast.bsc"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.ilk"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /browser:"ser_debug/" /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt /module:"ser_debug/" /object:"ser_debug/" /pdbfile:"ser_debug/DF60.PDB" 
F90_OBJS=.\ser_debug/
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /FR"$(INTDIR)\\" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\abmult.sbr" \
	"$(INTDIR)\aplbce.sbr" \
	"$(INTDIR)\aplbce_ss_flow.sbr" \
	"$(INTDIR)\aplbci.sbr" \
	"$(INTDIR)\armult.sbr" \
	"$(INTDIR)\asembl.sbr" \
	"$(INTDIR)\asmslc.sbr" \
	"$(INTDIR)\asmslp.sbr" \
	"$(INTDIR)\asmslp_ss_flow.sbr" \
	"$(INTDIR)\bsode.sbr" \
	"$(INTDIR)\calc_velocity.sbr" \
	"$(INTDIR)\calcc.sbr" \
	"$(INTDIR)\clog.sbr" \
	"$(INTDIR)\closef.sbr" \
	"$(INTDIR)\coeff.sbr" \
	"$(INTDIR)\coeff_ss_flow.sbr" \
	"$(INTDIR)\crsdsp.sbr" \
	"$(INTDIR)\d4ord.sbr" \
	"$(INTDIR)\d4zord.sbr" \
	"$(INTDIR)\dbmult.sbr" \
	"$(INTDIR)\dump.sbr" \
	"$(INTDIR)\efact.sbr" \
	"$(INTDIR)\ehoftp.sbr" \
	"$(INTDIR)\el1slv.sbr" \
	"$(INTDIR)\elslv.sbr" \
	"$(INTDIR)\error1.sbr" \
	"$(INTDIR)\error2.sbr" \
	"$(INTDIR)\error3.sbr" \
	"$(INTDIR)\error4.sbr" \
	"$(INTDIR)\errprt.sbr" \
	"$(INTDIR)\etom1.sbr" \
	"$(INTDIR)\etom2.sbr" \
	"$(INTDIR)\euslv.sbr" \
	"$(INTDIR)\formr.sbr" \
	"$(INTDIR)\gcgris.sbr" \
	"$(INTDIR)\hunt.sbr" \
	"$(INTDIR)\incidx.sbr" \
	"$(INTDIR)\indx_rewi.sbr" \
	"$(INTDIR)\indx_rewi_bc.sbr" \
	"$(INTDIR)\init1.sbr" \
	"$(INTDIR)\init2_1.sbr" \
	"$(INTDIR)\init2_2.sbr" \
	"$(INTDIR)\init2_3.sbr" \
	"$(INTDIR)\init2_post_ss.sbr" \
	"$(INTDIR)\init3.sbr" \
	"$(INTDIR)\interp.sbr" \
	"$(INTDIR)\irewi.sbr" \
	"$(INTDIR)\ldchar.sbr" \
	"$(INTDIR)\ldci.sbr" \
	"$(INTDIR)\ldcir.sbr" \
	"$(INTDIR)\ldind.sbr" \
	"$(INTDIR)\ldipen.sbr" \
	"$(INTDIR)\ldmar1.sbr" \
	"$(INTDIR)\load_indx_bc.sbr" \
	"$(INTDIR)\lsolv.sbr" \
	"$(INTDIR)\modules.sbr" \
	"$(INTDIR)\mtoijk.sbr" \
	"$(INTDIR)\nintrp.sbr" \
	"$(INTDIR)\openf.sbr" \
	"$(INTDIR)\phast.sbr" \
	"$(INTDIR)\prchar.sbr" \
	"$(INTDIR)\print_control_mod.sbr" \
	"$(INTDIR)\prntar.sbr" \
	"$(INTDIR)\rbord.sbr" \
	"$(INTDIR)\read1.sbr" \
	"$(INTDIR)\read2.sbr" \
	"$(INTDIR)\read3.sbr" \
	"$(INTDIR)\reordr.sbr" \
	"$(INTDIR)\rewi.sbr" \
	"$(INTDIR)\rewi3.sbr" \
	"$(INTDIR)\rfact.sbr" \
	"$(INTDIR)\rfactm.sbr" \
	"$(INTDIR)\rhsn.sbr" \
	"$(INTDIR)\rhsn_ss_flow.sbr" \
	"$(INTDIR)\sbcflo.sbr" \
	"$(INTDIR)\simulate_ss_flow.sbr" \
	"$(INTDIR)\stonb.sbr" \
	"$(INTDIR)\sumcal1.sbr" \
	"$(INTDIR)\sumcal2.sbr" \
	"$(INTDIR)\sumcal_ss_flow.sbr" \
	"$(INTDIR)\terminate_phast.sbr" \
	"$(INTDIR)\tfrds.sbr" \
	"$(INTDIR)\timstp.sbr" \
	"$(INTDIR)\timstp_ss_flow.sbr" \
	"$(INTDIR)\update_print_flags.sbr" \
	"$(INTDIR)\usolv.sbr" \
	"$(INTDIR)\viscos.sbr" \
	"$(INTDIR)\vpsv.sbr" \
	"$(INTDIR)\wbbal.sbr" \
	"$(INTDIR)\wbcflo.sbr" \
	"$(INTDIR)\wellsc.sbr" \
	"$(INTDIR)\wellsc_ss_flow.sbr" \
	"$(INTDIR)\wellsr.sbr" \
	"$(INTDIR)\wellsr_ss_flow.sbr" \
	"$(INTDIR)\welris.sbr" \
	"$(INTDIR)\wfdydz.sbr" \
	"$(INTDIR)\write1.sbr" \
	"$(INTDIR)\write2_1.sbr" \
	"$(INTDIR)\write2_2.sbr" \
	"$(INTDIR)\write3.sbr" \
	"$(INTDIR)\write3_ss_flow.sbr" \
	"$(INTDIR)\write4.sbr" \
	"$(INTDIR)\write5.sbr" \
	"$(INTDIR)\write5_ss_flow.sbr" \
	"$(INTDIR)\write6.sbr" \
	"$(INTDIR)\hdf_f.sbr" \
	"$(INTDIR)\advection.sbr" \
	"$(INTDIR)\basic.sbr" \
	"$(INTDIR)\basicsubs.sbr" \
	"$(INTDIR)\cl1.sbr" \
	"$(INTDIR)\hst.sbr" \
	"$(INTDIR)\hstsubs.sbr" \
	"$(INTDIR)\integrate.sbr" \
	"$(INTDIR)\inverse.sbr" \
	"$(INTDIR)\isotopes.sbr" \
	"$(INTDIR)\kinetics.sbr" \
	"$(INTDIR)\mainsubs.sbr" \
	"$(INTDIR)\mix.sbr" \
	"$(INTDIR)\model.sbr" \
	"$(INTDIR)\p2clib.sbr" \
	"$(INTDIR)\parse.sbr" \
	"$(INTDIR)\phqalloc.sbr" \
	"$(INTDIR)\prep.sbr" \
	"$(INTDIR)\print.sbr" \
	"$(INTDIR)\read.sbr" \
	"$(INTDIR)\readtr.sbr" \
	"$(INTDIR)\spread.sbr" \
	"$(INTDIR)\step.sbr" \
	"$(INTDIR)\structures.sbr" \
	"$(INTDIR)\tidy.sbr" \
	"$(INTDIR)\transport.sbr" \
	"$(INTDIR)\utilities.sbr" \
	"$(INTDIR)\hdf.sbr" \
	"$(INTDIR)\cvdense.sbr" \
	"$(INTDIR)\cvode.sbr" \
	"$(INTDIR)\dense.sbr" \
	"$(INTDIR)\input.sbr" \
	"$(INTDIR)\nvector.sbr" \
	"$(INTDIR)\nvector_serial.sbr" \
	"$(INTDIR)\output.sbr" \
	"$(INTDIR)\phast_files.sbr" \
	"$(INTDIR)\smalldense.sbr" \
	"$(INTDIR)\sundialsmath.sbr" \
	"$(INTDIR)\tally.sbr"

"$(OUTDIR)\phast.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /nodefaultlib:"libc.lib" /out:"$(OUTDIR)\phast.exe" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

OUTDIR=.\mpich_debug
INTDIR=.\mpich_debug
# Begin Custom Macros
OutDir=.\mpich_debug
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.ilk"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt /module:"mpich_debug/" /object:"mpich_debug/" /pdbfile:"mpich_debug/DF60.PDB" 
F90_OBJS=.\mpich_debug/
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /out:"$(OUTDIR)\phast.exe" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

OUTDIR=.\mpich_no_hdf_debug
INTDIR=.\mpich_no_hdf_debug
# Begin Custom Macros
OutDir=.\mpich_no_hdf_debug
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /check:bounds /compile_only /debug:full /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt /module:"mpich_no_hdf_debug/" /object:"mpich_no_hdf_debug/" /pdbfile:"mpich_no_hdf_debug/DF60.PDB" 
F90_OBJS=.\mpich_no_hdf_debug/
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /out:"$(OUTDIR)\phast.exe" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB_D)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

OUTDIR=.\mpich
INTDIR=.\mpich
# Begin Custom Macros
OutDir=.\mpich
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /compile_only /define:"HDF5_CREATE" /define:"USE_MPI" /define:"MPICH_NAME" /fpp /fpscomp:nolibs /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /warn:nofileopt /module:"mpich/" /object:"mpich/" 
F90_OBJS=.\mpich/
CPP_PROJ=/nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\phast.pdb" /machine:I386 /out:"$(OUTDIR)\phast.exe" /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)" /RELEASE 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

OUTDIR=.\mpich_profile
INTDIR=.\mpich_profile
# Begin Custom Macros
OutDir=.\mpich_profile
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /compile_only /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt /module:"mpich_profile/" /object:"mpich_profile/" 
F90_OBJS=.\mpich_profile/
CPP_PROJ=/nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "USE_MPI" /D "HDF5_CREATE" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /profile /debug /machine:I386 /out:"$(OUTDIR)\phast.exe" /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 merge"

OUTDIR=.\merge
INTDIR=.\merge
# Begin Custom Macros
OutDir=.\merge
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /compile_only /debug:full /define:"MERGE_FILES" /define:"HDF5_CREATE" /define:"USE_MPI" /define:"MPICH_NAME" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /threads /warn:nofileopt /module:"merge/" /object:"merge/" /pdbfile:"merge/DF60.PDB" 
F90_OBJS=.\merge/
CPP_PROJ=/nologo /MT /W3 /GX /Zi /O2 /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "MERGE_FILES" /D "USE_MPI" /D "HDF5_CREATE" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpich.lib ws2_32.lib hdf5dll.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /out:"$(OUTDIR)\phast.exe" /libpath:"$(DEV_HDF5_LIBDLL)" /libpath:"$(DEV_MPICH_LIB)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

OUTDIR=.\merge_debug
INTDIR=.\merge_debug
# Begin Custom Macros
OutDir=.\merge_debug
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe" "$(OUTDIR)\phast.bsc"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\abmult.sbr"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\advection.sbr"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce.sbr"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.sbr"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\aplbci.sbr"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\armult.sbr"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asembl.sbr"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslc.sbr"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp.sbr"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.sbr"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basic.sbr"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\basicsubs.sbr"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\bsode.sbr"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calc_velocity.sbr"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\calcc.sbr"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\cl1.sbr"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\clog.sbr"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\closef.sbr"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff.sbr"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.sbr"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\crsdsp.sbr"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvdense.sbr"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\cvode.sbr"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4ord.sbr"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\d4zord.sbr"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dbmult.sbr"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dense.sbr"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\dump.sbr"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\efact.sbr"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\ehoftp.sbr"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\el1slv.sbr"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\elslv.sbr"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error1.sbr"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error2.sbr"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error3.sbr"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\error4.sbr"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\errprt.sbr"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom1.sbr"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\etom2.sbr"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\euslv.sbr"
	-@erase "$(INTDIR)\f_units.mod"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\formr.sbr"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\gcgris.sbr"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf.sbr"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hdf_f.sbr"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hst.sbr"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hstsubs.sbr"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\hunt.sbr"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\incidx.sbr"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi.sbr"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.sbr"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init1.sbr"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_1.sbr"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_2.sbr"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_3.sbr"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init2_post_ss.sbr"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\init3.sbr"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\input.sbr"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\integrate.sbr"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\interp.sbr"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\inverse.sbr"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\irewi.sbr"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\isotopes.sbr"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\kinetics.sbr"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldchar.sbr"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldci.sbr"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldcir.sbr"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldind.sbr"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldipen.sbr"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\ldmar1.sbr"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\load_indx_bc.sbr"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\lsolv.sbr"
	-@erase "$(INTDIR)\machine_constants.mod"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mainsubs.sbr"
	-@erase "$(INTDIR)\mcb.mod"
	-@erase "$(INTDIR)\mcc.mod"
	-@erase "$(INTDIR)\mcch.mod"
	-@erase "$(INTDIR)\mcg.mod"
	-@erase "$(INTDIR)\mcm.mod"
	-@erase "$(INTDIR)\mcn.mod"
	-@erase "$(INTDIR)\mcp.mod"
	-@erase "$(INTDIR)\mcs.mod"
	-@erase "$(INTDIR)\mcs2.mod"
	-@erase "$(INTDIR)\mct.mod"
	-@erase "$(INTDIR)\mcv.mod"
	-@erase "$(INTDIR)\mcw.mod"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\merge.sbr"
	-@erase "$(INTDIR)\mg2.mod"
	-@erase "$(INTDIR)\mg3.mod"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\mix.sbr"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\model.sbr"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\modules.sbr"
	-@erase "$(INTDIR)\mpimod.obj"
	-@erase "$(INTDIR)\mpimod.sbr"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\mtoijk.sbr"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nintrp.sbr"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector.sbr"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\nvector_serial.sbr"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\openf.sbr"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\output.sbr"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\p2clib.sbr"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\parse.sbr"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast.sbr"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phast_files.sbr"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\phqalloc.sbr"
	-@erase "$(INTDIR)\phys_const.mod"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prchar.sbr"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\prep.sbr"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print.sbr"
	-@erase "$(INTDIR)\print_control_mod.mod"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\print_control_mod.sbr"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\prntar.sbr"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\rbord.sbr"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read.sbr"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read1.sbr"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read2.sbr"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\read3.sbr"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\readtr.sbr"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\reordr.sbr"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi.sbr"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rewi3.sbr"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfact.sbr"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rfactm.sbr"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn.sbr"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.sbr"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\sbcflo.sbr"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.sbr"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\smalldense.sbr"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\spread.sbr"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\step.sbr"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\stonb.sbr"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\structures.sbr"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal1.sbr"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal2.sbr"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.sbr"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\sundialsmath.sbr"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\tally.sbr"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\terminate_phast.sbr"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tfrds.sbr"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\tidy.sbr"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp.sbr"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.sbr"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\transport.sbr"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\update_print_flags.sbr"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\usolv.sbr"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\utilities.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\viscos.sbr"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\vpsv.sbr"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbbal.sbr"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wbcflo.sbr"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc.sbr"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.sbr"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr.sbr"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.sbr"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\welris.sbr"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\wfdydz.sbr"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write1.sbr"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_1.sbr"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write2_2.sbr"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3.sbr"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write3_ss_flow.sbr"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write4.sbr"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5.sbr"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write5_ss_flow.sbr"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(INTDIR)\write6.sbr"
	-@erase "$(OUTDIR)\phast.bsc"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.ilk"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /browser:"merge_debug/" /check:bounds /compile_only /debug:full /define:"MERGE_FILES" /define:"HDF5_CREATE" /define:"MPICH_NAME" /define:"USE_MPI" /fpp /fpscomp:general /iface:nomixed_str_len_arg /iface:cref /include:"$(DEV_MPICH_INC)" /names:lowercase /nologo /threads /traceback /warn:argument_checking /warn:nofileopt /module:"merge_debug/" /object:"merge_debug/" /pdbfile:"merge_debug/DF60.PDB" 
F90_OBJS=.\merge_debug/
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /I "$(DEV_MPICH_INC)" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "MERGE_FILES" /D "USE_MPI" /D "HDF5_CREATE" /FR"$(INTDIR)\\" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\advection.sbr" \
	"$(INTDIR)\basic.sbr" \
	"$(INTDIR)\basicsubs.sbr" \
	"$(INTDIR)\cl1.sbr" \
	"$(INTDIR)\hst.sbr" \
	"$(INTDIR)\hstsubs.sbr" \
	"$(INTDIR)\integrate.sbr" \
	"$(INTDIR)\inverse.sbr" \
	"$(INTDIR)\isotopes.sbr" \
	"$(INTDIR)\kinetics.sbr" \
	"$(INTDIR)\mainsubs.sbr" \
	"$(INTDIR)\mix.sbr" \
	"$(INTDIR)\model.sbr" \
	"$(INTDIR)\p2clib.sbr" \
	"$(INTDIR)\parse.sbr" \
	"$(INTDIR)\phqalloc.sbr" \
	"$(INTDIR)\prep.sbr" \
	"$(INTDIR)\print.sbr" \
	"$(INTDIR)\read.sbr" \
	"$(INTDIR)\readtr.sbr" \
	"$(INTDIR)\spread.sbr" \
	"$(INTDIR)\step.sbr" \
	"$(INTDIR)\structures.sbr" \
	"$(INTDIR)\tidy.sbr" \
	"$(INTDIR)\transport.sbr" \
	"$(INTDIR)\utilities.sbr" \
	"$(INTDIR)\abmult.sbr" \
	"$(INTDIR)\aplbce.sbr" \
	"$(INTDIR)\aplbce_ss_flow.sbr" \
	"$(INTDIR)\aplbci.sbr" \
	"$(INTDIR)\armult.sbr" \
	"$(INTDIR)\asembl.sbr" \
	"$(INTDIR)\asmslc.sbr" \
	"$(INTDIR)\asmslp.sbr" \
	"$(INTDIR)\asmslp_ss_flow.sbr" \
	"$(INTDIR)\bsode.sbr" \
	"$(INTDIR)\calc_velocity.sbr" \
	"$(INTDIR)\calcc.sbr" \
	"$(INTDIR)\clog.sbr" \
	"$(INTDIR)\closef.sbr" \
	"$(INTDIR)\coeff.sbr" \
	"$(INTDIR)\coeff_ss_flow.sbr" \
	"$(INTDIR)\crsdsp.sbr" \
	"$(INTDIR)\d4ord.sbr" \
	"$(INTDIR)\d4zord.sbr" \
	"$(INTDIR)\dbmult.sbr" \
	"$(INTDIR)\dump.sbr" \
	"$(INTDIR)\efact.sbr" \
	"$(INTDIR)\ehoftp.sbr" \
	"$(INTDIR)\el1slv.sbr" \
	"$(INTDIR)\elslv.sbr" \
	"$(INTDIR)\error1.sbr" \
	"$(INTDIR)\error2.sbr" \
	"$(INTDIR)\error3.sbr" \
	"$(INTDIR)\error4.sbr" \
	"$(INTDIR)\errprt.sbr" \
	"$(INTDIR)\etom1.sbr" \
	"$(INTDIR)\etom2.sbr" \
	"$(INTDIR)\euslv.sbr" \
	"$(INTDIR)\formr.sbr" \
	"$(INTDIR)\gcgris.sbr" \
	"$(INTDIR)\hunt.sbr" \
	"$(INTDIR)\incidx.sbr" \
	"$(INTDIR)\indx_rewi.sbr" \
	"$(INTDIR)\indx_rewi_bc.sbr" \
	"$(INTDIR)\init1.sbr" \
	"$(INTDIR)\init2_1.sbr" \
	"$(INTDIR)\init2_2.sbr" \
	"$(INTDIR)\init2_3.sbr" \
	"$(INTDIR)\init2_post_ss.sbr" \
	"$(INTDIR)\init3.sbr" \
	"$(INTDIR)\interp.sbr" \
	"$(INTDIR)\irewi.sbr" \
	"$(INTDIR)\ldchar.sbr" \
	"$(INTDIR)\ldci.sbr" \
	"$(INTDIR)\ldcir.sbr" \
	"$(INTDIR)\ldind.sbr" \
	"$(INTDIR)\ldipen.sbr" \
	"$(INTDIR)\ldmar1.sbr" \
	"$(INTDIR)\load_indx_bc.sbr" \
	"$(INTDIR)\lsolv.sbr" \
	"$(INTDIR)\modules.sbr" \
	"$(INTDIR)\mtoijk.sbr" \
	"$(INTDIR)\nintrp.sbr" \
	"$(INTDIR)\openf.sbr" \
	"$(INTDIR)\phast.sbr" \
	"$(INTDIR)\prchar.sbr" \
	"$(INTDIR)\print_control_mod.sbr" \
	"$(INTDIR)\prntar.sbr" \
	"$(INTDIR)\rbord.sbr" \
	"$(INTDIR)\read1.sbr" \
	"$(INTDIR)\read2.sbr" \
	"$(INTDIR)\read3.sbr" \
	"$(INTDIR)\reordr.sbr" \
	"$(INTDIR)\rewi.sbr" \
	"$(INTDIR)\rewi3.sbr" \
	"$(INTDIR)\rfact.sbr" \
	"$(INTDIR)\rfactm.sbr" \
	"$(INTDIR)\rhsn.sbr" \
	"$(INTDIR)\rhsn_ss_flow.sbr" \
	"$(INTDIR)\sbcflo.sbr" \
	"$(INTDIR)\simulate_ss_flow.sbr" \
	"$(INTDIR)\stonb.sbr" \
	"$(INTDIR)\sumcal1.sbr" \
	"$(INTDIR)\sumcal2.sbr" \
	"$(INTDIR)\sumcal_ss_flow.sbr" \
	"$(INTDIR)\terminate_phast.sbr" \
	"$(INTDIR)\tfrds.sbr" \
	"$(INTDIR)\timstp.sbr" \
	"$(INTDIR)\timstp_ss_flow.sbr" \
	"$(INTDIR)\update_print_flags.sbr" \
	"$(INTDIR)\usolv.sbr" \
	"$(INTDIR)\viscos.sbr" \
	"$(INTDIR)\vpsv.sbr" \
	"$(INTDIR)\wbbal.sbr" \
	"$(INTDIR)\wbcflo.sbr" \
	"$(INTDIR)\wellsc.sbr" \
	"$(INTDIR)\wellsc_ss_flow.sbr" \
	"$(INTDIR)\wellsr.sbr" \
	"$(INTDIR)\wellsr_ss_flow.sbr" \
	"$(INTDIR)\welris.sbr" \
	"$(INTDIR)\wfdydz.sbr" \
	"$(INTDIR)\write1.sbr" \
	"$(INTDIR)\write2_1.sbr" \
	"$(INTDIR)\write2_2.sbr" \
	"$(INTDIR)\write3.sbr" \
	"$(INTDIR)\write3_ss_flow.sbr" \
	"$(INTDIR)\write4.sbr" \
	"$(INTDIR)\write5.sbr" \
	"$(INTDIR)\write5_ss_flow.sbr" \
	"$(INTDIR)\write6.sbr" \
	"$(INTDIR)\hdf.sbr" \
	"$(INTDIR)\hdf_f.sbr" \
	"$(INTDIR)\merge.sbr" \
	"$(INTDIR)\cvdense.sbr" \
	"$(INTDIR)\cvode.sbr" \
	"$(INTDIR)\dense.sbr" \
	"$(INTDIR)\input.sbr" \
	"$(INTDIR)\nvector.sbr" \
	"$(INTDIR)\nvector_serial.sbr" \
	"$(INTDIR)\output.sbr" \
	"$(INTDIR)\phast_files.sbr" \
	"$(INTDIR)\smalldense.sbr" \
	"$(INTDIR)\sundialsmath.sbr" \
	"$(INTDIR)\tally.sbr" \
	"$(INTDIR)\mpimod.sbr"

"$(OUTDIR)\phast.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=dformt.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib mpichd.lib ws2_32.lib hdf5ddll.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd" /nodefaultlib:"libc" /out:"$(OUTDIR)\phast.exe" /pdbtype:sept /libpath:"$(DEV_HDF5_LIBDLL_D)" /libpath:"$(DEV_MPICH_LIB)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\mpimod.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

OUTDIR=.\ser_debug_mem
INTDIR=.\ser_debug_mem
# Begin Custom Macros
OutDir=.\ser_debug_mem
# End Custom Macros

ALL : "$(OUTDIR)\phast.exe" "$(OUTDIR)\phast.bsc"


CLEAN :
	-@erase "$(INTDIR)\abmult.obj"
	-@erase "$(INTDIR)\abmult.sbr"
	-@erase "$(INTDIR)\advection.obj"
	-@erase "$(INTDIR)\advection.sbr"
	-@erase "$(INTDIR)\aplbce.obj"
	-@erase "$(INTDIR)\aplbce.sbr"
	-@erase "$(INTDIR)\aplbce_ss_flow.obj"
	-@erase "$(INTDIR)\aplbce_ss_flow.sbr"
	-@erase "$(INTDIR)\aplbci.obj"
	-@erase "$(INTDIR)\aplbci.sbr"
	-@erase "$(INTDIR)\armult.obj"
	-@erase "$(INTDIR)\armult.sbr"
	-@erase "$(INTDIR)\asembl.obj"
	-@erase "$(INTDIR)\asembl.sbr"
	-@erase "$(INTDIR)\asmslc.obj"
	-@erase "$(INTDIR)\asmslc.sbr"
	-@erase "$(INTDIR)\asmslp.obj"
	-@erase "$(INTDIR)\asmslp.sbr"
	-@erase "$(INTDIR)\asmslp_ss_flow.obj"
	-@erase "$(INTDIR)\asmslp_ss_flow.sbr"
	-@erase "$(INTDIR)\basic.obj"
	-@erase "$(INTDIR)\basic.sbr"
	-@erase "$(INTDIR)\basicsubs.obj"
	-@erase "$(INTDIR)\basicsubs.sbr"
	-@erase "$(INTDIR)\bsode.obj"
	-@erase "$(INTDIR)\bsode.sbr"
	-@erase "$(INTDIR)\calc_velocity.obj"
	-@erase "$(INTDIR)\calc_velocity.sbr"
	-@erase "$(INTDIR)\calcc.obj"
	-@erase "$(INTDIR)\calcc.sbr"
	-@erase "$(INTDIR)\cl1.obj"
	-@erase "$(INTDIR)\cl1.sbr"
	-@erase "$(INTDIR)\clog.obj"
	-@erase "$(INTDIR)\clog.sbr"
	-@erase "$(INTDIR)\closef.obj"
	-@erase "$(INTDIR)\closef.sbr"
	-@erase "$(INTDIR)\coeff.obj"
	-@erase "$(INTDIR)\coeff.sbr"
	-@erase "$(INTDIR)\coeff_ss_flow.obj"
	-@erase "$(INTDIR)\coeff_ss_flow.sbr"
	-@erase "$(INTDIR)\crsdsp.obj"
	-@erase "$(INTDIR)\crsdsp.sbr"
	-@erase "$(INTDIR)\cvdense.obj"
	-@erase "$(INTDIR)\cvdense.sbr"
	-@erase "$(INTDIR)\cvode.obj"
	-@erase "$(INTDIR)\cvode.sbr"
	-@erase "$(INTDIR)\d4ord.obj"
	-@erase "$(INTDIR)\d4ord.sbr"
	-@erase "$(INTDIR)\d4zord.obj"
	-@erase "$(INTDIR)\d4zord.sbr"
	-@erase "$(INTDIR)\dbmult.obj"
	-@erase "$(INTDIR)\dbmult.sbr"
	-@erase "$(INTDIR)\dense.obj"
	-@erase "$(INTDIR)\dense.sbr"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\dump.obj"
	-@erase "$(INTDIR)\dump.sbr"
	-@erase "$(INTDIR)\efact.obj"
	-@erase "$(INTDIR)\efact.sbr"
	-@erase "$(INTDIR)\ehoftp.obj"
	-@erase "$(INTDIR)\ehoftp.sbr"
	-@erase "$(INTDIR)\el1slv.obj"
	-@erase "$(INTDIR)\el1slv.sbr"
	-@erase "$(INTDIR)\elslv.obj"
	-@erase "$(INTDIR)\elslv.sbr"
	-@erase "$(INTDIR)\error1.obj"
	-@erase "$(INTDIR)\error1.sbr"
	-@erase "$(INTDIR)\error2.obj"
	-@erase "$(INTDIR)\error2.sbr"
	-@erase "$(INTDIR)\error3.obj"
	-@erase "$(INTDIR)\error3.sbr"
	-@erase "$(INTDIR)\error4.obj"
	-@erase "$(INTDIR)\error4.sbr"
	-@erase "$(INTDIR)\errprt.obj"
	-@erase "$(INTDIR)\errprt.sbr"
	-@erase "$(INTDIR)\etom1.obj"
	-@erase "$(INTDIR)\etom1.sbr"
	-@erase "$(INTDIR)\etom2.obj"
	-@erase "$(INTDIR)\etom2.sbr"
	-@erase "$(INTDIR)\euslv.obj"
	-@erase "$(INTDIR)\euslv.sbr"
	-@erase "$(INTDIR)\f_units.mod"
	-@erase "$(INTDIR)\formr.obj"
	-@erase "$(INTDIR)\formr.sbr"
	-@erase "$(INTDIR)\gcgris.obj"
	-@erase "$(INTDIR)\gcgris.sbr"
	-@erase "$(INTDIR)\hdf.obj"
	-@erase "$(INTDIR)\hdf.sbr"
	-@erase "$(INTDIR)\hdf_f.obj"
	-@erase "$(INTDIR)\hdf_f.sbr"
	-@erase "$(INTDIR)\hst.obj"
	-@erase "$(INTDIR)\hst.sbr"
	-@erase "$(INTDIR)\hstsubs.obj"
	-@erase "$(INTDIR)\hstsubs.sbr"
	-@erase "$(INTDIR)\hunt.obj"
	-@erase "$(INTDIR)\hunt.sbr"
	-@erase "$(INTDIR)\incidx.obj"
	-@erase "$(INTDIR)\incidx.sbr"
	-@erase "$(INTDIR)\indx_rewi.obj"
	-@erase "$(INTDIR)\indx_rewi.sbr"
	-@erase "$(INTDIR)\indx_rewi_bc.obj"
	-@erase "$(INTDIR)\indx_rewi_bc.sbr"
	-@erase "$(INTDIR)\init1.obj"
	-@erase "$(INTDIR)\init1.sbr"
	-@erase "$(INTDIR)\init2_1.obj"
	-@erase "$(INTDIR)\init2_1.sbr"
	-@erase "$(INTDIR)\init2_2.obj"
	-@erase "$(INTDIR)\init2_2.sbr"
	-@erase "$(INTDIR)\init2_3.obj"
	-@erase "$(INTDIR)\init2_3.sbr"
	-@erase "$(INTDIR)\init2_post_ss.obj"
	-@erase "$(INTDIR)\init2_post_ss.sbr"
	-@erase "$(INTDIR)\init3.obj"
	-@erase "$(INTDIR)\init3.sbr"
	-@erase "$(INTDIR)\input.obj"
	-@erase "$(INTDIR)\input.sbr"
	-@erase "$(INTDIR)\integrate.obj"
	-@erase "$(INTDIR)\integrate.sbr"
	-@erase "$(INTDIR)\interp.obj"
	-@erase "$(INTDIR)\interp.sbr"
	-@erase "$(INTDIR)\inverse.obj"
	-@erase "$(INTDIR)\inverse.sbr"
	-@erase "$(INTDIR)\irewi.obj"
	-@erase "$(INTDIR)\irewi.sbr"
	-@erase "$(INTDIR)\isotopes.obj"
	-@erase "$(INTDIR)\isotopes.sbr"
	-@erase "$(INTDIR)\kinetics.obj"
	-@erase "$(INTDIR)\kinetics.sbr"
	-@erase "$(INTDIR)\ldchar.obj"
	-@erase "$(INTDIR)\ldchar.sbr"
	-@erase "$(INTDIR)\ldci.obj"
	-@erase "$(INTDIR)\ldci.sbr"
	-@erase "$(INTDIR)\ldcir.obj"
	-@erase "$(INTDIR)\ldcir.sbr"
	-@erase "$(INTDIR)\ldind.obj"
	-@erase "$(INTDIR)\ldind.sbr"
	-@erase "$(INTDIR)\ldipen.obj"
	-@erase "$(INTDIR)\ldipen.sbr"
	-@erase "$(INTDIR)\ldmar1.obj"
	-@erase "$(INTDIR)\ldmar1.sbr"
	-@erase "$(INTDIR)\load_indx_bc.obj"
	-@erase "$(INTDIR)\load_indx_bc.sbr"
	-@erase "$(INTDIR)\lsolv.obj"
	-@erase "$(INTDIR)\lsolv.sbr"
	-@erase "$(INTDIR)\machine_constants.mod"
	-@erase "$(INTDIR)\mainsubs.obj"
	-@erase "$(INTDIR)\mainsubs.sbr"
	-@erase "$(INTDIR)\mcb.mod"
	-@erase "$(INTDIR)\mcc.mod"
	-@erase "$(INTDIR)\mcch.mod"
	-@erase "$(INTDIR)\mcg.mod"
	-@erase "$(INTDIR)\mcm.mod"
	-@erase "$(INTDIR)\mcn.mod"
	-@erase "$(INTDIR)\mcp.mod"
	-@erase "$(INTDIR)\mcs.mod"
	-@erase "$(INTDIR)\mcs2.mod"
	-@erase "$(INTDIR)\mct.mod"
	-@erase "$(INTDIR)\mcv.mod"
	-@erase "$(INTDIR)\mcw.mod"
	-@erase "$(INTDIR)\mg2.mod"
	-@erase "$(INTDIR)\mg3.mod"
	-@erase "$(INTDIR)\mix.obj"
	-@erase "$(INTDIR)\mix.sbr"
	-@erase "$(INTDIR)\model.obj"
	-@erase "$(INTDIR)\model.sbr"
	-@erase "$(INTDIR)\modules.obj"
	-@erase "$(INTDIR)\modules.sbr"
	-@erase "$(INTDIR)\mtoijk.obj"
	-@erase "$(INTDIR)\mtoijk.sbr"
	-@erase "$(INTDIR)\nintrp.obj"
	-@erase "$(INTDIR)\nintrp.sbr"
	-@erase "$(INTDIR)\nvector.obj"
	-@erase "$(INTDIR)\nvector.sbr"
	-@erase "$(INTDIR)\nvector_serial.obj"
	-@erase "$(INTDIR)\nvector_serial.sbr"
	-@erase "$(INTDIR)\openf.obj"
	-@erase "$(INTDIR)\openf.sbr"
	-@erase "$(INTDIR)\output.obj"
	-@erase "$(INTDIR)\output.sbr"
	-@erase "$(INTDIR)\p2clib.obj"
	-@erase "$(INTDIR)\p2clib.sbr"
	-@erase "$(INTDIR)\parse.obj"
	-@erase "$(INTDIR)\parse.sbr"
	-@erase "$(INTDIR)\phast.obj"
	-@erase "$(INTDIR)\phast.res"
	-@erase "$(INTDIR)\phast.sbr"
	-@erase "$(INTDIR)\phast_files.obj"
	-@erase "$(INTDIR)\phast_files.sbr"
	-@erase "$(INTDIR)\phqalloc.obj"
	-@erase "$(INTDIR)\phqalloc.sbr"
	-@erase "$(INTDIR)\phys_const.mod"
	-@erase "$(INTDIR)\prchar.obj"
	-@erase "$(INTDIR)\prchar.sbr"
	-@erase "$(INTDIR)\prep.obj"
	-@erase "$(INTDIR)\prep.sbr"
	-@erase "$(INTDIR)\print.obj"
	-@erase "$(INTDIR)\print.sbr"
	-@erase "$(INTDIR)\print_control_mod.mod"
	-@erase "$(INTDIR)\print_control_mod.obj"
	-@erase "$(INTDIR)\print_control_mod.sbr"
	-@erase "$(INTDIR)\prntar.obj"
	-@erase "$(INTDIR)\prntar.sbr"
	-@erase "$(INTDIR)\rbord.obj"
	-@erase "$(INTDIR)\rbord.sbr"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\read.sbr"
	-@erase "$(INTDIR)\read1.obj"
	-@erase "$(INTDIR)\read1.sbr"
	-@erase "$(INTDIR)\read2.obj"
	-@erase "$(INTDIR)\read2.sbr"
	-@erase "$(INTDIR)\read3.obj"
	-@erase "$(INTDIR)\read3.sbr"
	-@erase "$(INTDIR)\readtr.obj"
	-@erase "$(INTDIR)\readtr.sbr"
	-@erase "$(INTDIR)\reordr.obj"
	-@erase "$(INTDIR)\reordr.sbr"
	-@erase "$(INTDIR)\rewi.obj"
	-@erase "$(INTDIR)\rewi.sbr"
	-@erase "$(INTDIR)\rewi3.obj"
	-@erase "$(INTDIR)\rewi3.sbr"
	-@erase "$(INTDIR)\rfact.obj"
	-@erase "$(INTDIR)\rfact.sbr"
	-@erase "$(INTDIR)\rfactm.obj"
	-@erase "$(INTDIR)\rfactm.sbr"
	-@erase "$(INTDIR)\rhsn.obj"
	-@erase "$(INTDIR)\rhsn.sbr"
	-@erase "$(INTDIR)\rhsn_ss_flow.obj"
	-@erase "$(INTDIR)\rhsn_ss_flow.sbr"
	-@erase "$(INTDIR)\sbcflo.obj"
	-@erase "$(INTDIR)\sbcflo.sbr"
	-@erase "$(INTDIR)\simulate_ss_flow.obj"
	-@erase "$(INTDIR)\simulate_ss_flow.sbr"
	-@erase "$(INTDIR)\smalldense.obj"
	-@erase "$(INTDIR)\smalldense.sbr"
	-@erase "$(INTDIR)\spread.obj"
	-@erase "$(INTDIR)\spread.sbr"
	-@erase "$(INTDIR)\step.obj"
	-@erase "$(INTDIR)\step.sbr"
	-@erase "$(INTDIR)\stonb.obj"
	-@erase "$(INTDIR)\stonb.sbr"
	-@erase "$(INTDIR)\structures.obj"
	-@erase "$(INTDIR)\structures.sbr"
	-@erase "$(INTDIR)\sumcal1.obj"
	-@erase "$(INTDIR)\sumcal1.sbr"
	-@erase "$(INTDIR)\sumcal2.obj"
	-@erase "$(INTDIR)\sumcal2.sbr"
	-@erase "$(INTDIR)\sumcal_ss_flow.obj"
	-@erase "$(INTDIR)\sumcal_ss_flow.sbr"
	-@erase "$(INTDIR)\sundialsmath.obj"
	-@erase "$(INTDIR)\sundialsmath.sbr"
	-@erase "$(INTDIR)\tally.obj"
	-@erase "$(INTDIR)\tally.sbr"
	-@erase "$(INTDIR)\terminate_phast.obj"
	-@erase "$(INTDIR)\terminate_phast.sbr"
	-@erase "$(INTDIR)\tfrds.obj"
	-@erase "$(INTDIR)\tfrds.sbr"
	-@erase "$(INTDIR)\tidy.obj"
	-@erase "$(INTDIR)\tidy.sbr"
	-@erase "$(INTDIR)\timstp.obj"
	-@erase "$(INTDIR)\timstp.sbr"
	-@erase "$(INTDIR)\timstp_ss_flow.obj"
	-@erase "$(INTDIR)\timstp_ss_flow.sbr"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\transport.sbr"
	-@erase "$(INTDIR)\update_print_flags.obj"
	-@erase "$(INTDIR)\update_print_flags.sbr"
	-@erase "$(INTDIR)\usolv.obj"
	-@erase "$(INTDIR)\usolv.sbr"
	-@erase "$(INTDIR)\utilities.obj"
	-@erase "$(INTDIR)\utilities.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\viscos.obj"
	-@erase "$(INTDIR)\viscos.sbr"
	-@erase "$(INTDIR)\vpsv.obj"
	-@erase "$(INTDIR)\vpsv.sbr"
	-@erase "$(INTDIR)\wbbal.obj"
	-@erase "$(INTDIR)\wbbal.sbr"
	-@erase "$(INTDIR)\wbcflo.obj"
	-@erase "$(INTDIR)\wbcflo.sbr"
	-@erase "$(INTDIR)\wellsc.obj"
	-@erase "$(INTDIR)\wellsc.sbr"
	-@erase "$(INTDIR)\wellsc_ss_flow.obj"
	-@erase "$(INTDIR)\wellsc_ss_flow.sbr"
	-@erase "$(INTDIR)\wellsr.obj"
	-@erase "$(INTDIR)\wellsr.sbr"
	-@erase "$(INTDIR)\wellsr_ss_flow.obj"
	-@erase "$(INTDIR)\wellsr_ss_flow.sbr"
	-@erase "$(INTDIR)\welris.obj"
	-@erase "$(INTDIR)\welris.sbr"
	-@erase "$(INTDIR)\wfdydz.obj"
	-@erase "$(INTDIR)\wfdydz.sbr"
	-@erase "$(INTDIR)\write1.obj"
	-@erase "$(INTDIR)\write1.sbr"
	-@erase "$(INTDIR)\write2_1.obj"
	-@erase "$(INTDIR)\write2_1.sbr"
	-@erase "$(INTDIR)\write2_2.obj"
	-@erase "$(INTDIR)\write2_2.sbr"
	-@erase "$(INTDIR)\write3.obj"
	-@erase "$(INTDIR)\write3.sbr"
	-@erase "$(INTDIR)\write3_ss_flow.obj"
	-@erase "$(INTDIR)\write3_ss_flow.sbr"
	-@erase "$(INTDIR)\write4.obj"
	-@erase "$(INTDIR)\write4.sbr"
	-@erase "$(INTDIR)\write5.obj"
	-@erase "$(INTDIR)\write5.sbr"
	-@erase "$(INTDIR)\write5_ss_flow.obj"
	-@erase "$(INTDIR)\write5_ss_flow.sbr"
	-@erase "$(INTDIR)\write6.obj"
	-@erase "$(INTDIR)\write6.sbr"
	-@erase "$(OUTDIR)\phast.bsc"
	-@erase "$(OUTDIR)\phast.exe"
	-@erase "$(OUTDIR)\phast.ilk"
	-@erase "$(OUTDIR)\phast.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90_PROJ=/assume:underscore /browser:"ser_debug_mem/" /check:bounds /compile_only /debug:full /define:"HDF5_CREATE" /fpp /iface:nomixed_str_len_arg /iface:cref /names:lowercase /nologo /traceback /warn:argument_checking /warn:nofileopt /module:"ser_debug_mem/" /object:"ser_debug_mem/" /pdbfile:"ser_debug_mem/DF60.PDB" 
F90_OBJS=.\ser_debug_mem/
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /ZI /Od /I "$(DEV_HDF5_INC)" /D "WIN32_MEMORY_DEBUG" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "HDF5_CREATE" /FR"$(INTDIR)\\" /Fp"$(INTDIR)\phast.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
RSC_PROJ=/l 0x409 /fo"$(INTDIR)\phast.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\phast.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\advection.sbr" \
	"$(INTDIR)\basic.sbr" \
	"$(INTDIR)\basicsubs.sbr" \
	"$(INTDIR)\cl1.sbr" \
	"$(INTDIR)\hst.sbr" \
	"$(INTDIR)\hstsubs.sbr" \
	"$(INTDIR)\integrate.sbr" \
	"$(INTDIR)\inverse.sbr" \
	"$(INTDIR)\isotopes.sbr" \
	"$(INTDIR)\kinetics.sbr" \
	"$(INTDIR)\mainsubs.sbr" \
	"$(INTDIR)\mix.sbr" \
	"$(INTDIR)\model.sbr" \
	"$(INTDIR)\p2clib.sbr" \
	"$(INTDIR)\parse.sbr" \
	"$(INTDIR)\phqalloc.sbr" \
	"$(INTDIR)\prep.sbr" \
	"$(INTDIR)\print.sbr" \
	"$(INTDIR)\read.sbr" \
	"$(INTDIR)\readtr.sbr" \
	"$(INTDIR)\spread.sbr" \
	"$(INTDIR)\step.sbr" \
	"$(INTDIR)\structures.sbr" \
	"$(INTDIR)\tidy.sbr" \
	"$(INTDIR)\transport.sbr" \
	"$(INTDIR)\utilities.sbr" \
	"$(INTDIR)\abmult.sbr" \
	"$(INTDIR)\aplbce.sbr" \
	"$(INTDIR)\aplbce_ss_flow.sbr" \
	"$(INTDIR)\aplbci.sbr" \
	"$(INTDIR)\armult.sbr" \
	"$(INTDIR)\asembl.sbr" \
	"$(INTDIR)\asmslc.sbr" \
	"$(INTDIR)\asmslp.sbr" \
	"$(INTDIR)\asmslp_ss_flow.sbr" \
	"$(INTDIR)\bsode.sbr" \
	"$(INTDIR)\calc_velocity.sbr" \
	"$(INTDIR)\calcc.sbr" \
	"$(INTDIR)\clog.sbr" \
	"$(INTDIR)\closef.sbr" \
	"$(INTDIR)\coeff.sbr" \
	"$(INTDIR)\coeff_ss_flow.sbr" \
	"$(INTDIR)\crsdsp.sbr" \
	"$(INTDIR)\d4ord.sbr" \
	"$(INTDIR)\d4zord.sbr" \
	"$(INTDIR)\dbmult.sbr" \
	"$(INTDIR)\dump.sbr" \
	"$(INTDIR)\efact.sbr" \
	"$(INTDIR)\ehoftp.sbr" \
	"$(INTDIR)\el1slv.sbr" \
	"$(INTDIR)\elslv.sbr" \
	"$(INTDIR)\error1.sbr" \
	"$(INTDIR)\error2.sbr" \
	"$(INTDIR)\error3.sbr" \
	"$(INTDIR)\error4.sbr" \
	"$(INTDIR)\errprt.sbr" \
	"$(INTDIR)\etom1.sbr" \
	"$(INTDIR)\etom2.sbr" \
	"$(INTDIR)\euslv.sbr" \
	"$(INTDIR)\formr.sbr" \
	"$(INTDIR)\gcgris.sbr" \
	"$(INTDIR)\hunt.sbr" \
	"$(INTDIR)\incidx.sbr" \
	"$(INTDIR)\indx_rewi.sbr" \
	"$(INTDIR)\indx_rewi_bc.sbr" \
	"$(INTDIR)\init1.sbr" \
	"$(INTDIR)\init2_1.sbr" \
	"$(INTDIR)\init2_2.sbr" \
	"$(INTDIR)\init2_3.sbr" \
	"$(INTDIR)\init2_post_ss.sbr" \
	"$(INTDIR)\init3.sbr" \
	"$(INTDIR)\interp.sbr" \
	"$(INTDIR)\irewi.sbr" \
	"$(INTDIR)\ldchar.sbr" \
	"$(INTDIR)\ldci.sbr" \
	"$(INTDIR)\ldcir.sbr" \
	"$(INTDIR)\ldind.sbr" \
	"$(INTDIR)\ldipen.sbr" \
	"$(INTDIR)\ldmar1.sbr" \
	"$(INTDIR)\load_indx_bc.sbr" \
	"$(INTDIR)\lsolv.sbr" \
	"$(INTDIR)\modules.sbr" \
	"$(INTDIR)\mtoijk.sbr" \
	"$(INTDIR)\nintrp.sbr" \
	"$(INTDIR)\openf.sbr" \
	"$(INTDIR)\phast.sbr" \
	"$(INTDIR)\prchar.sbr" \
	"$(INTDIR)\print_control_mod.sbr" \
	"$(INTDIR)\prntar.sbr" \
	"$(INTDIR)\rbord.sbr" \
	"$(INTDIR)\read1.sbr" \
	"$(INTDIR)\read2.sbr" \
	"$(INTDIR)\read3.sbr" \
	"$(INTDIR)\reordr.sbr" \
	"$(INTDIR)\rewi.sbr" \
	"$(INTDIR)\rewi3.sbr" \
	"$(INTDIR)\rfact.sbr" \
	"$(INTDIR)\rfactm.sbr" \
	"$(INTDIR)\rhsn.sbr" \
	"$(INTDIR)\rhsn_ss_flow.sbr" \
	"$(INTDIR)\sbcflo.sbr" \
	"$(INTDIR)\simulate_ss_flow.sbr" \
	"$(INTDIR)\stonb.sbr" \
	"$(INTDIR)\sumcal1.sbr" \
	"$(INTDIR)\sumcal2.sbr" \
	"$(INTDIR)\sumcal_ss_flow.sbr" \
	"$(INTDIR)\terminate_phast.sbr" \
	"$(INTDIR)\tfrds.sbr" \
	"$(INTDIR)\timstp.sbr" \
	"$(INTDIR)\timstp_ss_flow.sbr" \
	"$(INTDIR)\update_print_flags.sbr" \
	"$(INTDIR)\usolv.sbr" \
	"$(INTDIR)\viscos.sbr" \
	"$(INTDIR)\vpsv.sbr" \
	"$(INTDIR)\wbbal.sbr" \
	"$(INTDIR)\wbcflo.sbr" \
	"$(INTDIR)\wellsc.sbr" \
	"$(INTDIR)\wellsc_ss_flow.sbr" \
	"$(INTDIR)\wellsr.sbr" \
	"$(INTDIR)\wellsr_ss_flow.sbr" \
	"$(INTDIR)\welris.sbr" \
	"$(INTDIR)\wfdydz.sbr" \
	"$(INTDIR)\write1.sbr" \
	"$(INTDIR)\write2_1.sbr" \
	"$(INTDIR)\write2_2.sbr" \
	"$(INTDIR)\write3.sbr" \
	"$(INTDIR)\write3_ss_flow.sbr" \
	"$(INTDIR)\write4.sbr" \
	"$(INTDIR)\write5.sbr" \
	"$(INTDIR)\write5_ss_flow.sbr" \
	"$(INTDIR)\write6.sbr" \
	"$(INTDIR)\hdf.sbr" \
	"$(INTDIR)\hdf_f.sbr" \
	"$(INTDIR)\cvdense.sbr" \
	"$(INTDIR)\cvode.sbr" \
	"$(INTDIR)\dense.sbr" \
	"$(INTDIR)\input.sbr" \
	"$(INTDIR)\nvector.sbr" \
	"$(INTDIR)\nvector_serial.sbr" \
	"$(INTDIR)\output.sbr" \
	"$(INTDIR)\phast_files.sbr" \
	"$(INTDIR)\smalldense.sbr" \
	"$(INTDIR)\sundialsmath.sbr" \
	"$(INTDIR)\tally.sbr"

"$(OUTDIR)\phast.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=dfor.lib hdf5.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\phast.pdb" /debug /machine:I386 /nodefaultlib:"libc.lib" /out:"$(OUTDIR)\phast.exe" /pdbtype:sept /libpath:"$(DEV_HDF5_LIB_D)" 
LINK32_OBJS= \
	"$(INTDIR)\advection.obj" \
	"$(INTDIR)\basic.obj" \
	"$(INTDIR)\basicsubs.obj" \
	"$(INTDIR)\cl1.obj" \
	"$(INTDIR)\hst.obj" \
	"$(INTDIR)\hstsubs.obj" \
	"$(INTDIR)\integrate.obj" \
	"$(INTDIR)\inverse.obj" \
	"$(INTDIR)\isotopes.obj" \
	"$(INTDIR)\kinetics.obj" \
	"$(INTDIR)\mainsubs.obj" \
	"$(INTDIR)\mix.obj" \
	"$(INTDIR)\model.obj" \
	"$(INTDIR)\p2clib.obj" \
	"$(INTDIR)\parse.obj" \
	"$(INTDIR)\phqalloc.obj" \
	"$(INTDIR)\prep.obj" \
	"$(INTDIR)\print.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\readtr.obj" \
	"$(INTDIR)\spread.obj" \
	"$(INTDIR)\step.obj" \
	"$(INTDIR)\structures.obj" \
	"$(INTDIR)\tidy.obj" \
	"$(INTDIR)\transport.obj" \
	"$(INTDIR)\utilities.obj" \
	"$(INTDIR)\abmult.obj" \
	"$(INTDIR)\aplbce.obj" \
	"$(INTDIR)\aplbce_ss_flow.obj" \
	"$(INTDIR)\aplbci.obj" \
	"$(INTDIR)\armult.obj" \
	"$(INTDIR)\asembl.obj" \
	"$(INTDIR)\asmslc.obj" \
	"$(INTDIR)\asmslp.obj" \
	"$(INTDIR)\asmslp_ss_flow.obj" \
	"$(INTDIR)\bsode.obj" \
	"$(INTDIR)\calc_velocity.obj" \
	"$(INTDIR)\calcc.obj" \
	"$(INTDIR)\clog.obj" \
	"$(INTDIR)\closef.obj" \
	"$(INTDIR)\coeff.obj" \
	"$(INTDIR)\coeff_ss_flow.obj" \
	"$(INTDIR)\crsdsp.obj" \
	"$(INTDIR)\d4ord.obj" \
	"$(INTDIR)\d4zord.obj" \
	"$(INTDIR)\dbmult.obj" \
	"$(INTDIR)\dump.obj" \
	"$(INTDIR)\efact.obj" \
	"$(INTDIR)\ehoftp.obj" \
	"$(INTDIR)\el1slv.obj" \
	"$(INTDIR)\elslv.obj" \
	"$(INTDIR)\error1.obj" \
	"$(INTDIR)\error2.obj" \
	"$(INTDIR)\error3.obj" \
	"$(INTDIR)\error4.obj" \
	"$(INTDIR)\errprt.obj" \
	"$(INTDIR)\etom1.obj" \
	"$(INTDIR)\etom2.obj" \
	"$(INTDIR)\euslv.obj" \
	"$(INTDIR)\formr.obj" \
	"$(INTDIR)\gcgris.obj" \
	"$(INTDIR)\hunt.obj" \
	"$(INTDIR)\incidx.obj" \
	"$(INTDIR)\indx_rewi.obj" \
	"$(INTDIR)\indx_rewi_bc.obj" \
	"$(INTDIR)\init1.obj" \
	"$(INTDIR)\init2_1.obj" \
	"$(INTDIR)\init2_2.obj" \
	"$(INTDIR)\init2_3.obj" \
	"$(INTDIR)\init2_post_ss.obj" \
	"$(INTDIR)\init3.obj" \
	"$(INTDIR)\interp.obj" \
	"$(INTDIR)\irewi.obj" \
	"$(INTDIR)\ldchar.obj" \
	"$(INTDIR)\ldci.obj" \
	"$(INTDIR)\ldcir.obj" \
	"$(INTDIR)\ldind.obj" \
	"$(INTDIR)\ldipen.obj" \
	"$(INTDIR)\ldmar1.obj" \
	"$(INTDIR)\load_indx_bc.obj" \
	"$(INTDIR)\lsolv.obj" \
	"$(INTDIR)\modules.obj" \
	"$(INTDIR)\mtoijk.obj" \
	"$(INTDIR)\nintrp.obj" \
	"$(INTDIR)\openf.obj" \
	"$(INTDIR)\phast.obj" \
	"$(INTDIR)\prchar.obj" \
	"$(INTDIR)\print_control_mod.obj" \
	"$(INTDIR)\prntar.obj" \
	"$(INTDIR)\rbord.obj" \
	"$(INTDIR)\read1.obj" \
	"$(INTDIR)\read2.obj" \
	"$(INTDIR)\read3.obj" \
	"$(INTDIR)\reordr.obj" \
	"$(INTDIR)\rewi.obj" \
	"$(INTDIR)\rewi3.obj" \
	"$(INTDIR)\rfact.obj" \
	"$(INTDIR)\rfactm.obj" \
	"$(INTDIR)\rhsn.obj" \
	"$(INTDIR)\rhsn_ss_flow.obj" \
	"$(INTDIR)\sbcflo.obj" \
	"$(INTDIR)\simulate_ss_flow.obj" \
	"$(INTDIR)\stonb.obj" \
	"$(INTDIR)\sumcal1.obj" \
	"$(INTDIR)\sumcal2.obj" \
	"$(INTDIR)\sumcal_ss_flow.obj" \
	"$(INTDIR)\terminate_phast.obj" \
	"$(INTDIR)\tfrds.obj" \
	"$(INTDIR)\timstp.obj" \
	"$(INTDIR)\timstp_ss_flow.obj" \
	"$(INTDIR)\update_print_flags.obj" \
	"$(INTDIR)\usolv.obj" \
	"$(INTDIR)\viscos.obj" \
	"$(INTDIR)\vpsv.obj" \
	"$(INTDIR)\wbbal.obj" \
	"$(INTDIR)\wbcflo.obj" \
	"$(INTDIR)\wellsc.obj" \
	"$(INTDIR)\wellsc_ss_flow.obj" \
	"$(INTDIR)\wellsr.obj" \
	"$(INTDIR)\wellsr_ss_flow.obj" \
	"$(INTDIR)\welris.obj" \
	"$(INTDIR)\wfdydz.obj" \
	"$(INTDIR)\write1.obj" \
	"$(INTDIR)\write2_1.obj" \
	"$(INTDIR)\write2_2.obj" \
	"$(INTDIR)\write3.obj" \
	"$(INTDIR)\write3_ss_flow.obj" \
	"$(INTDIR)\write4.obj" \
	"$(INTDIR)\write5.obj" \
	"$(INTDIR)\write5_ss_flow.obj" \
	"$(INTDIR)\write6.obj" \
	"$(INTDIR)\hdf.obj" \
	"$(INTDIR)\hdf_f.obj" \
	"$(INTDIR)\cvdense.obj" \
	"$(INTDIR)\cvode.obj" \
	"$(INTDIR)\dense.obj" \
	"$(INTDIR)\input.obj" \
	"$(INTDIR)\nvector.obj" \
	"$(INTDIR)\nvector_serial.obj" \
	"$(INTDIR)\output.obj" \
	"$(INTDIR)\phast.res" \
	"$(INTDIR)\phast_files.obj" \
	"$(INTDIR)\smalldense.obj" \
	"$(INTDIR)\sundialsmath.obj" \
	"$(INTDIR)\tally.obj"

"$(OUTDIR)\phast.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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
!IF EXISTS("phast.dep")
!INCLUDE "phast.dep"
!ELSE 
!MESSAGE Warning: cannot find "phast.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "phast - Win32 ser" || "$(CFG)" == "phast - Win32 ser_debug" || "$(CFG)" == "phast - Win32 mpich_debug" || "$(CFG)" == "phast - Win32 mpich_no_hdf_debug" || "$(CFG)" == "phast - Win32 mpich" || "$(CFG)" == "phast - Win32 mpich_profile" || "$(CFG)" == "phast - Win32 merge" || "$(CFG)" == "phast - Win32 merge_debug" || "$(CFG)" == "phast - Win32 ser_debug_mem"
SOURCE=..\advection.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\advection.obj"	"$(INTDIR)\advection.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\advection.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\advection.obj"	"$(INTDIR)\advection.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\advection.obj"	"$(INTDIR)\advection.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\basic.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\basic.obj"	"$(INTDIR)\basic.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\basic.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\basic.obj"	"$(INTDIR)\basic.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\basic.obj"	"$(INTDIR)\basic.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\basicsubs.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\basicsubs.obj"	"$(INTDIR)\basicsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\basicsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\basicsubs.obj"	"$(INTDIR)\basicsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\basicsubs.obj"	"$(INTDIR)\basicsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\cl1.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\cl1.obj"	"$(INTDIR)\cl1.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\cl1.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\cl1.obj"	"$(INTDIR)\cl1.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\cl1.obj"	"$(INTDIR)\cl1.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\hst.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\hst.obj"	"$(INTDIR)\hst.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\hst.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\hst.obj"	"$(INTDIR)\hst.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\hst.obj"	"$(INTDIR)\hst.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\hstsubs.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\hstsubs.obj"	"$(INTDIR)\hstsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\hstsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\hstsubs.obj"	"$(INTDIR)\hstsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\hstsubs.obj"	"$(INTDIR)\hstsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\integrate.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\integrate.obj"	"$(INTDIR)\integrate.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\integrate.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\integrate.obj"	"$(INTDIR)\integrate.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\integrate.obj"	"$(INTDIR)\integrate.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\inverse.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\inverse.obj"	"$(INTDIR)\inverse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\inverse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\inverse.obj"	"$(INTDIR)\inverse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\inverse.obj"	"$(INTDIR)\inverse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\isotopes.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\isotopes.obj"	"$(INTDIR)\isotopes.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\isotopes.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\isotopes.obj"	"$(INTDIR)\isotopes.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\isotopes.obj"	"$(INTDIR)\isotopes.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\kinetics.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\kinetics.obj"	"$(INTDIR)\kinetics.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\kinetics.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\kinetics.obj"	"$(INTDIR)\kinetics.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\kinetics.obj"	"$(INTDIR)\kinetics.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\mainsubs.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\mainsubs.obj"	"$(INTDIR)\mainsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\mainsubs.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\mainsubs.obj"	"$(INTDIR)\mainsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\mainsubs.obj"	"$(INTDIR)\mainsubs.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\mix.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\mix.obj"	"$(INTDIR)\mix.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\mix.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\mix.obj"	"$(INTDIR)\mix.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\mix.obj"	"$(INTDIR)\mix.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\model.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\model.obj"	"$(INTDIR)\model.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\model.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\model.obj"	"$(INTDIR)\model.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\model.obj"	"$(INTDIR)\model.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\p2clib.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\p2clib.obj"	"$(INTDIR)\p2clib.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\p2clib.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\p2clib.obj"	"$(INTDIR)\p2clib.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\p2clib.obj"	"$(INTDIR)\p2clib.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\parse.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\parse.obj"	"$(INTDIR)\parse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\parse.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\parse.obj"	"$(INTDIR)\parse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\parse.obj"	"$(INTDIR)\parse.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\phqalloc.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\phqalloc.obj"	"$(INTDIR)\phqalloc.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\phqalloc.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\phqalloc.obj"	"$(INTDIR)\phqalloc.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\phqalloc.obj"	"$(INTDIR)\phqalloc.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\prep.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\prep.obj"	"$(INTDIR)\prep.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\prep.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\prep.obj"	"$(INTDIR)\prep.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\prep.obj"	"$(INTDIR)\prep.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\print.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\print.obj"	"$(INTDIR)\print.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\print.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\print.obj"	"$(INTDIR)\print.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\print.obj"	"$(INTDIR)\print.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\read.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\read.obj"	"$(INTDIR)\read.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\read.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\read.obj"	"$(INTDIR)\read.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\read.obj"	"$(INTDIR)\read.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\readtr.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\readtr.obj"	"$(INTDIR)\readtr.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\readtr.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\readtr.obj"	"$(INTDIR)\readtr.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\readtr.obj"	"$(INTDIR)\readtr.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\spread.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\spread.obj"	"$(INTDIR)\spread.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\spread.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\spread.obj"	"$(INTDIR)\spread.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\spread.obj"	"$(INTDIR)\spread.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\step.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\step.obj"	"$(INTDIR)\step.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\step.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\step.obj"	"$(INTDIR)\step.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\step.obj"	"$(INTDIR)\step.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\structures.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\structures.obj"	"$(INTDIR)\structures.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\structures.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\structures.obj"	"$(INTDIR)\structures.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\structures.obj"	"$(INTDIR)\structures.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\tidy.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\tidy.obj"	"$(INTDIR)\tidy.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\tidy.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\tidy.obj"	"$(INTDIR)\tidy.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\tidy.obj"	"$(INTDIR)\tidy.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\transport.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\transport.obj"	"$(INTDIR)\transport.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\transport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\transport.obj"	"$(INTDIR)\transport.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\transport.obj"	"$(INTDIR)\transport.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\utilities.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\utilities.obj"	"$(INTDIR)\utilities.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\utilities.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\utilities.obj"	"$(INTDIR)\utilities.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\utilities.obj"	"$(INTDIR)\utilities.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\abmult.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\abmult.obj"	"$(INTDIR)\abmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\abmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\abmult.obj"	"$(INTDIR)\abmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\abmult.obj"	"$(INTDIR)\abmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\aplbce.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\aplbce.obj"	"$(INTDIR)\aplbce.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\aplbce.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\aplbce.obj"	"$(INTDIR)\aplbce.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\aplbce.obj"	"$(INTDIR)\aplbce.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\aplbce_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\aplbce_ss_flow.obj"	"$(INTDIR)\aplbce_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\aplbce_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\aplbce_ss_flow.obj"	"$(INTDIR)\aplbce_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\aplbce_ss_flow.obj"	"$(INTDIR)\aplbce_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\aplbci.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\aplbci.obj"	"$(INTDIR)\aplbci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\aplbci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\aplbci.obj"	"$(INTDIR)\aplbci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\aplbci.obj"	"$(INTDIR)\aplbci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\armult.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\armult.obj"	"$(INTDIR)\armult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\armult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\armult.obj"	"$(INTDIR)\armult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\armult.obj"	"$(INTDIR)\armult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\asembl.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\asembl.obj"	"$(INTDIR)\asembl.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\asembl.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\asembl.obj"	"$(INTDIR)\asembl.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\asembl.obj"	"$(INTDIR)\asembl.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\asmslc.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\asmslc.obj"	"$(INTDIR)\asmslc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\asmslc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\asmslc.obj"	"$(INTDIR)\asmslc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\asmslc.obj"	"$(INTDIR)\asmslc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\asmslp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\asmslp.obj"	"$(INTDIR)\asmslp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\asmslp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\asmslp.obj"	"$(INTDIR)\asmslp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\asmslp.obj"	"$(INTDIR)\asmslp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\asmslp_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\asmslp_ss_flow.obj"	"$(INTDIR)\asmslp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\asmslp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\asmslp_ss_flow.obj"	"$(INTDIR)\asmslp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\asmslp_ss_flow.obj"	"$(INTDIR)\asmslp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\bsode.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\bsode.obj"	"$(INTDIR)\bsode.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\bsode.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\bsode.obj"	"$(INTDIR)\bsode.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\bsode.obj"	"$(INTDIR)\bsode.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\calc_velocity.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\calc_velocity.obj"	"$(INTDIR)\calc_velocity.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\calc_velocity.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\calc_velocity.obj"	"$(INTDIR)\calc_velocity.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\calc_velocity.obj"	"$(INTDIR)\calc_velocity.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\calcc.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\calcc.obj"	"$(INTDIR)\calcc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\calcc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\calcc.obj"	"$(INTDIR)\calcc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\calcc.obj"	"$(INTDIR)\calcc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\clog.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\clog.obj"	"$(INTDIR)\clog.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\clog.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\clog.obj"	"$(INTDIR)\clog.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\clog.obj"	"$(INTDIR)\clog.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\closef.F90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\closef.obj"	"$(INTDIR)\closef.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\closef.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\closef.obj"	"$(INTDIR)\closef.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\closef.obj"	"$(INTDIR)\closef.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\coeff.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\coeff.obj"	"$(INTDIR)\coeff.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\coeff.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\coeff.obj"	"$(INTDIR)\coeff.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\coeff.obj"	"$(INTDIR)\coeff.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\coeff_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\coeff_ss_flow.obj"	"$(INTDIR)\coeff_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\coeff_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\coeff_ss_flow.obj"	"$(INTDIR)\coeff_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\coeff_ss_flow.obj"	"$(INTDIR)\coeff_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\crsdsp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\crsdsp.obj"	"$(INTDIR)\crsdsp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\crsdsp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\crsdsp.obj"	"$(INTDIR)\crsdsp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\crsdsp.obj"	"$(INTDIR)\crsdsp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\d4ord.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\d4ord.obj"	"$(INTDIR)\d4ord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\d4ord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\d4ord.obj"	"$(INTDIR)\d4ord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\d4ord.obj"	"$(INTDIR)\d4ord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\d4zord.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\d4zord.obj"	"$(INTDIR)\d4zord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\d4zord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\d4zord.obj"	"$(INTDIR)\d4zord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\d4zord.obj"	"$(INTDIR)\d4zord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\dbmult.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\dbmult.obj"	"$(INTDIR)\dbmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\dbmult.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\dbmult.obj"	"$(INTDIR)\dbmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\dbmult.obj"	"$(INTDIR)\dbmult.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\dump.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\dump.obj"	"$(INTDIR)\dump.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\dump.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\dump.obj"	"$(INTDIR)\dump.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\dump.obj"	"$(INTDIR)\dump.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\efact.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\efact.obj"	"$(INTDIR)\efact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\efact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\efact.obj"	"$(INTDIR)\efact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\efact.obj"	"$(INTDIR)\efact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ehoftp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ehoftp.obj"	"$(INTDIR)\ehoftp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ehoftp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ehoftp.obj"	"$(INTDIR)\ehoftp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ehoftp.obj"	"$(INTDIR)\ehoftp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\el1slv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\el1slv.obj"	"$(INTDIR)\el1slv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\el1slv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\el1slv.obj"	"$(INTDIR)\el1slv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\el1slv.obj"	"$(INTDIR)\el1slv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\elslv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\elslv.obj"	"$(INTDIR)\elslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\elslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\elslv.obj"	"$(INTDIR)\elslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\elslv.obj"	"$(INTDIR)\elslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\error1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\error1.obj"	"$(INTDIR)\error1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\error1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\error1.obj"	"$(INTDIR)\error1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\error1.obj"	"$(INTDIR)\error1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\error2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\error2.obj"	"$(INTDIR)\error2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\error2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\error2.obj"	"$(INTDIR)\error2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\error2.obj"	"$(INTDIR)\error2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\error3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\error3.obj"	"$(INTDIR)\error3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\error3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\error3.obj"	"$(INTDIR)\error3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\error3.obj"	"$(INTDIR)\error3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\error4.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\error4.obj"	"$(INTDIR)\error4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\error4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\error4.obj"	"$(INTDIR)\error4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\error4.obj"	"$(INTDIR)\error4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\errprt.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\errprt.obj"	"$(INTDIR)\errprt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\errprt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\errprt.obj"	"$(INTDIR)\errprt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\errprt.obj"	"$(INTDIR)\errprt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\etom1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\etom1.obj"	"$(INTDIR)\etom1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\etom1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\etom1.obj"	"$(INTDIR)\etom1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\etom1.obj"	"$(INTDIR)\etom1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\etom2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\etom2.obj"	"$(INTDIR)\etom2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\etom2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\etom2.obj"	"$(INTDIR)\etom2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\etom2.obj"	"$(INTDIR)\etom2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\euslv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\euslv.obj"	"$(INTDIR)\euslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\euslv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\euslv.obj"	"$(INTDIR)\euslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\euslv.obj"	"$(INTDIR)\euslv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\formr.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\formr.obj"	"$(INTDIR)\formr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\formr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\formr.obj"	"$(INTDIR)\formr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\formr.obj"	"$(INTDIR)\formr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\gcgris.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\gcgris.obj"	"$(INTDIR)\gcgris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\print_control_mod.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\gcgris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\gcgris.obj"	"$(INTDIR)\gcgris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\gcgris.obj"	"$(INTDIR)\gcgris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\print_control_mod.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\hunt.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\hunt.obj"	"$(INTDIR)\hunt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\hunt.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\hunt.obj"	"$(INTDIR)\hunt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\hunt.obj"	"$(INTDIR)\hunt.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\incidx.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\incidx.obj"	"$(INTDIR)\incidx.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\incidx.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\incidx.obj"	"$(INTDIR)\incidx.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\incidx.obj"	"$(INTDIR)\incidx.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\indx_rewi.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\indx_rewi.obj"	"$(INTDIR)\indx_rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\indx_rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\indx_rewi.obj"	"$(INTDIR)\indx_rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\indx_rewi.obj"	"$(INTDIR)\indx_rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\indx_rewi_bc.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\indx_rewi_bc.obj"	"$(INTDIR)\indx_rewi_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\indx_rewi_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\indx_rewi_bc.obj"	"$(INTDIR)\indx_rewi_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\indx_rewi_bc.obj"	"$(INTDIR)\indx_rewi_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init1.obj"	"$(INTDIR)\init1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init1.obj"	"$(INTDIR)\init1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init1.obj"	"$(INTDIR)\init1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init2_1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init2_1.obj"	"$(INTDIR)\init2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init2_1.obj"	"$(INTDIR)\init2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init2_1.obj"	"$(INTDIR)\init2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcs2.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init2_2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init2_2.obj"	"$(INTDIR)\init2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init2_2.obj"	"$(INTDIR)\init2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init2_2.obj"	"$(INTDIR)\init2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init2_3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init2_3.obj"	"$(INTDIR)\init2_3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init2_3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init2_3.obj"	"$(INTDIR)\init2_3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init2_3.obj"	"$(INTDIR)\init2_3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init2_post_ss.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init2_post_ss.obj"	"$(INTDIR)\init2_post_ss.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init2_post_ss.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init2_post_ss.obj"	"$(INTDIR)\init2_post_ss.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init2_post_ss.obj"	"$(INTDIR)\init2_post_ss.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\init3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\init3.obj"	"$(INTDIR)\init3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\init3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\init3.obj"	"$(INTDIR)\init3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\init3.obj"	"$(INTDIR)\init3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\interp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\interp.obj"	"$(INTDIR)\interp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\interp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\interp.obj"	"$(INTDIR)\interp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\interp.obj"	"$(INTDIR)\interp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\irewi.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\irewi.obj"	"$(INTDIR)\irewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\irewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\irewi.obj"	"$(INTDIR)\irewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\irewi.obj"	"$(INTDIR)\irewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldchar.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldchar.obj"	"$(INTDIR)\ldchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldchar.obj"	"$(INTDIR)\ldchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldchar.obj"	"$(INTDIR)\ldchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldci.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldci.obj"	"$(INTDIR)\ldci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldci.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldci.obj"	"$(INTDIR)\ldci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldci.obj"	"$(INTDIR)\ldci.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldcir.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldcir.obj"	"$(INTDIR)\ldcir.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldcir.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldcir.obj"	"$(INTDIR)\ldcir.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldcir.obj"	"$(INTDIR)\ldcir.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldind.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldind.obj"	"$(INTDIR)\ldind.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldind.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldind.obj"	"$(INTDIR)\ldind.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldind.obj"	"$(INTDIR)\ldind.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldipen.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldipen.obj"	"$(INTDIR)\ldipen.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldipen.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldipen.obj"	"$(INTDIR)\ldipen.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldipen.obj"	"$(INTDIR)\ldipen.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\ldmar1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\ldmar1.obj"	"$(INTDIR)\ldmar1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\ldmar1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\ldmar1.obj"	"$(INTDIR)\ldmar1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\ldmar1.obj"	"$(INTDIR)\ldmar1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\load_indx_bc.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\load_indx_bc.obj"	"$(INTDIR)\load_indx_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\load_indx_bc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\load_indx_bc.obj"	"$(INTDIR)\load_indx_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\load_indx_bc.obj"	"$(INTDIR)\load_indx_bc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\lsolv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\lsolv.obj"	"$(INTDIR)\lsolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\lsolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\lsolv.obj"	"$(INTDIR)\lsolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\lsolv.obj"	"$(INTDIR)\lsolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\modules.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

F90_MODOUT=\
	"f_units" \
	"machine_constants" \
	"mcb" \
	"mcc" \
	"mcch" \
	"mcg" \
	"mcm" \
	"mcn" \
	"mcp" \
	"mcs" \
	"mcs2" \
	"mct" \
	"mcv" \
	"mcw" \
	"mg2" \
	"mg3" \
	"phys_const"


"$(INTDIR)\modules.obj"	"$(INTDIR)\modules.sbr"	"$(INTDIR)\f_units.mod"	"$(INTDIR)\machine_constants.mod"	"$(INTDIR)\mcb.mod"	"$(INTDIR)\mcc.mod"	"$(INTDIR)\mcch.mod"	"$(INTDIR)\mcg.mod"	"$(INTDIR)\mcm.mod"	"$(INTDIR)\mcn.mod"	"$(INTDIR)\mcp.mod"	"$(INTDIR)\mcs.mod"	"$(INTDIR)\mcs2.mod"	"$(INTDIR)\mct.mod"	"$(INTDIR)\mcv.mod"	"$(INTDIR)\mcw.mod"	"$(INTDIR)\mg2.mod"	"$(INTDIR)\mg3.mod"	"$(INTDIR)\phys_const.mod" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\modules.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

F90_MODOUT=\
	"f_units" \
	"machine_constants" \
	"mcb" \
	"mcc" \
	"mcch" \
	"mcg" \
	"mcm" \
	"mcn" \
	"mcp" \
	"mcs" \
	"mcs2" \
	"mct" \
	"mcv" \
	"mcw" \
	"mg2" \
	"mg3" \
	"phys_const"


"$(INTDIR)\modules.obj"	"$(INTDIR)\modules.sbr"	"$(INTDIR)\f_units.mod"	"$(INTDIR)\machine_constants.mod"	"$(INTDIR)\mcb.mod"	"$(INTDIR)\mcc.mod"	"$(INTDIR)\mcch.mod"	"$(INTDIR)\mcg.mod"	"$(INTDIR)\mcm.mod"	"$(INTDIR)\mcn.mod"	"$(INTDIR)\mcp.mod"	"$(INTDIR)\mcs.mod"	"$(INTDIR)\mcs2.mod"	"$(INTDIR)\mct.mod"	"$(INTDIR)\mcv.mod"	"$(INTDIR)\mcw.mod"	"$(INTDIR)\mg2.mod"	"$(INTDIR)\mg3.mod"	"$(INTDIR)\phys_const.mod" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

F90_MODOUT=\
	"f_units" \
	"machine_constants" \
	"mcb" \
	"mcc" \
	"mcch" \
	"mcg" \
	"mcm" \
	"mcn" \
	"mcp" \
	"mcs" \
	"mcs2" \
	"mct" \
	"mcv" \
	"mcw" \
	"mg2" \
	"mg3" \
	"phys_const"


"$(INTDIR)\modules.obj"	"$(INTDIR)\modules.sbr"	"$(INTDIR)\f_units.mod"	"$(INTDIR)\machine_constants.mod"	"$(INTDIR)\mcb.mod"	"$(INTDIR)\mcc.mod"	"$(INTDIR)\mcch.mod"	"$(INTDIR)\mcg.mod"	"$(INTDIR)\mcm.mod"	"$(INTDIR)\mcn.mod"	"$(INTDIR)\mcp.mod"	"$(INTDIR)\mcs.mod"	"$(INTDIR)\mcs2.mod"	"$(INTDIR)\mct.mod"	"$(INTDIR)\mcv.mod"	"$(INTDIR)\mcw.mod"	"$(INTDIR)\mg2.mod"	"$(INTDIR)\mg3.mod"	"$(INTDIR)\phys_const.mod" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\mtoijk.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\mtoijk.obj"	"$(INTDIR)\mtoijk.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\mtoijk.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\mtoijk.obj"	"$(INTDIR)\mtoijk.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\mtoijk.obj"	"$(INTDIR)\mtoijk.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\nintrp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\nintrp.obj"	"$(INTDIR)\nintrp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\nintrp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\nintrp.obj"	"$(INTDIR)\nintrp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\nintrp.obj"	"$(INTDIR)\nintrp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\openf.F90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\openf.obj"	"$(INTDIR)\openf.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcch.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\openf.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\openf.obj"	"$(INTDIR)\openf.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcch.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\openf.obj"	"$(INTDIR)\openf.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcch.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\phast.F90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\phast.obj"	"$(INTDIR)\phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\phast.obj"	"$(INTDIR)\phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\phast.obj"	"$(INTDIR)\phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\prchar.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\prchar.obj"	"$(INTDIR)\prchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\prchar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\prchar.obj"	"$(INTDIR)\prchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\prchar.obj"	"$(INTDIR)\prchar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\print_control_mod.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

F90_MODOUT=\
	"print_control_mod"


"$(INTDIR)\print_control_mod.obj"	"$(INTDIR)\print_control_mod.sbr"	"$(INTDIR)\print_control_mod.mod" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\print_control_mod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"

F90_MODOUT=\
	"print_control_mod"


"$(INTDIR)\print_control_mod.obj"	"$(INTDIR)\print_control_mod.sbr"	"$(INTDIR)\print_control_mod.mod" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

F90_MODOUT=\
	"print_control_mod"


"$(INTDIR)\print_control_mod.obj"	"$(INTDIR)\print_control_mod.sbr"	"$(INTDIR)\print_control_mod.mod" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\prntar.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\prntar.obj"	"$(INTDIR)\prntar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\prntar.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\prntar.obj"	"$(INTDIR)\prntar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\prntar.obj"	"$(INTDIR)\prntar.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rbord.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rbord.obj"	"$(INTDIR)\rbord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rbord.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rbord.obj"	"$(INTDIR)\rbord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rbord.obj"	"$(INTDIR)\rbord.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\read1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\read1.obj"	"$(INTDIR)\read1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\read1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\read1.obj"	"$(INTDIR)\read1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\read1.obj"	"$(INTDIR)\read1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\read2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\read2.obj"	"$(INTDIR)\read2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\read2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\read2.obj"	"$(INTDIR)\read2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\read2.obj"	"$(INTDIR)\read2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\read3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\read3.obj"	"$(INTDIR)\read3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\read3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\read3.obj"	"$(INTDIR)\read3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\read3.obj"	"$(INTDIR)\read3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\reordr.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\reordr.obj"	"$(INTDIR)\reordr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\reordr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\reordr.obj"	"$(INTDIR)\reordr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\reordr.obj"	"$(INTDIR)\reordr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rewi.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rewi.obj"	"$(INTDIR)\rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rewi.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rewi.obj"	"$(INTDIR)\rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rewi.obj"	"$(INTDIR)\rewi.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rewi3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rewi3.obj"	"$(INTDIR)\rewi3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rewi3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rewi3.obj"	"$(INTDIR)\rewi3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rewi3.obj"	"$(INTDIR)\rewi3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mct.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rfact.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rfact.obj"	"$(INTDIR)\rfact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rfact.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rfact.obj"	"$(INTDIR)\rfact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rfact.obj"	"$(INTDIR)\rfact.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rfactm.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rfactm.obj"	"$(INTDIR)\rfactm.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rfactm.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rfactm.obj"	"$(INTDIR)\rfactm.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rfactm.obj"	"$(INTDIR)\rfactm.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rhsn.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rhsn.obj"	"$(INTDIR)\rhsn.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rhsn.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rhsn.obj"	"$(INTDIR)\rhsn.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rhsn.obj"	"$(INTDIR)\rhsn.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\rhsn_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\rhsn_ss_flow.obj"	"$(INTDIR)\rhsn_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\rhsn_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\rhsn_ss_flow.obj"	"$(INTDIR)\rhsn_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\rhsn_ss_flow.obj"	"$(INTDIR)\rhsn_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\sbcflo.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\sbcflo.obj"	"$(INTDIR)\sbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\sbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\sbcflo.obj"	"$(INTDIR)\sbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\sbcflo.obj"	"$(INTDIR)\sbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\simulate_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\simulate_ss_flow.obj"	"$(INTDIR)\simulate_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\simulate_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\simulate_ss_flow.obj"	"$(INTDIR)\simulate_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\simulate_ss_flow.obj"	"$(INTDIR)\simulate_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\stonb.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\stonb.obj"	"$(INTDIR)\stonb.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\stonb.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\stonb.obj"	"$(INTDIR)\stonb.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\stonb.obj"	"$(INTDIR)\stonb.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\sumcal1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\sumcal1.obj"	"$(INTDIR)\sumcal1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\sumcal1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\sumcal1.obj"	"$(INTDIR)\sumcal1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\sumcal1.obj"	"$(INTDIR)\sumcal1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\sumcal2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\sumcal2.obj"	"$(INTDIR)\sumcal2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\sumcal2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\sumcal2.obj"	"$(INTDIR)\sumcal2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\sumcal2.obj"	"$(INTDIR)\sumcal2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\sumcal_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\sumcal_ss_flow.obj"	"$(INTDIR)\sumcal_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\sumcal_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\sumcal_ss_flow.obj"	"$(INTDIR)\sumcal_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\sumcal_ss_flow.obj"	"$(INTDIR)\sumcal_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\terminate_phast.F90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\terminate_phast.obj"	"$(INTDIR)\terminate_phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\terminate_phast.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\terminate_phast.obj"	"$(INTDIR)\terminate_phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\terminate_phast.obj"	"$(INTDIR)\terminate_phast.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\tfrds.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\tfrds.obj"	"$(INTDIR)\tfrds.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\tfrds.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\tfrds.obj"	"$(INTDIR)\tfrds.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\tfrds.obj"	"$(INTDIR)\tfrds.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\timstp.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\timstp.obj"	"$(INTDIR)\timstp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\timstp.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\timstp.obj"	"$(INTDIR)\timstp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\timstp.obj"	"$(INTDIR)\timstp.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\timstp_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\timstp_ss_flow.obj"	"$(INTDIR)\timstp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\timstp_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\timstp_ss_flow.obj"	"$(INTDIR)\timstp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\timstp_ss_flow.obj"	"$(INTDIR)\timstp_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\update_print_flags.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\update_print_flags.obj"	"$(INTDIR)\update_print_flags.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\update_print_flags.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\update_print_flags.obj"	"$(INTDIR)\update_print_flags.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\update_print_flags.obj"	"$(INTDIR)\update_print_flags.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\usolv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\usolv.obj"	"$(INTDIR)\usolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\usolv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\usolv.obj"	"$(INTDIR)\usolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\usolv.obj"	"$(INTDIR)\usolv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcs.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\viscos.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\viscos.obj"	"$(INTDIR)\viscos.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\viscos.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\viscos.obj"	"$(INTDIR)\viscos.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\viscos.obj"	"$(INTDIR)\viscos.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcp.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\vpsv.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\vpsv.obj"	"$(INTDIR)\vpsv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\vpsv.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\vpsv.obj"	"$(INTDIR)\vpsv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\vpsv.obj"	"$(INTDIR)\vpsv.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wbbal.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wbbal.obj"	"$(INTDIR)\wbbal.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wbbal.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wbbal.obj"	"$(INTDIR)\wbbal.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wbbal.obj"	"$(INTDIR)\wbbal.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wbcflo.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wbcflo.obj"	"$(INTDIR)\wbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wbcflo.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wbcflo.obj"	"$(INTDIR)\wbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wbcflo.obj"	"$(INTDIR)\wbcflo.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wellsc.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wellsc.obj"	"$(INTDIR)\wellsc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wellsc.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wellsc.obj"	"$(INTDIR)\wellsc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wellsc.obj"	"$(INTDIR)\wellsc.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wellsc_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wellsc_ss_flow.obj"	"$(INTDIR)\wellsc_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wellsc_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wellsc_ss_flow.obj"	"$(INTDIR)\wellsc_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wellsc_ss_flow.obj"	"$(INTDIR)\wellsc_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcm.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wellsr.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wellsr.obj"	"$(INTDIR)\wellsr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wellsr.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wellsr.obj"	"$(INTDIR)\wellsr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wellsr.obj"	"$(INTDIR)\wellsr.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wellsr_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wellsr_ss_flow.obj"	"$(INTDIR)\wellsr_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wellsr_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wellsr_ss_flow.obj"	"$(INTDIR)\wellsr_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wellsr_ss_flow.obj"	"$(INTDIR)\wellsr_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\welris.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\welris.obj"	"$(INTDIR)\welris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\welris.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\welris.obj"	"$(INTDIR)\welris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\welris.obj"	"$(INTDIR)\welris.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\wfdydz.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\wfdydz.obj"	"$(INTDIR)\wfdydz.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\wfdydz.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\wfdydz.obj"	"$(INTDIR)\wfdydz.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\wfdydz.obj"	"$(INTDIR)\wfdydz.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write1.obj"	"$(INTDIR)\write1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write1.obj"	"$(INTDIR)\write1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write1.obj"	"$(INTDIR)\write1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write2_1.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write2_1.obj"	"$(INTDIR)\write2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write2_1.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write2_1.obj"	"$(INTDIR)\write2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write2_1.obj"	"$(INTDIR)\write2_1.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write2_2.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write2_2.obj"	"$(INTDIR)\write2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write2_2.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write2_2.obj"	"$(INTDIR)\write2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write2_2.obj"	"$(INTDIR)\write2_2.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\phys_const.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write3.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write3.obj"	"$(INTDIR)\write3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write3.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write3.obj"	"$(INTDIR)\write3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write3.obj"	"$(INTDIR)\write3.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write3_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write3_ss_flow.obj"	"$(INTDIR)\write3_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write3_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write3_ss_flow.obj"	"$(INTDIR)\write3_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write3_ss_flow.obj"	"$(INTDIR)\write3_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod" "$(INTDIR)\mg3.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write4.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write4.obj"	"$(INTDIR)\write4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write4.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write4.obj"	"$(INTDIR)\write4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write4.obj"	"$(INTDIR)\write4.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcs.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write5.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write5.obj"	"$(INTDIR)\write5.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write5.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write5.obj"	"$(INTDIR)\write5.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write5.obj"	"$(INTDIR)\write5.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write5_ss_flow.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write5_ss_flow.obj"	"$(INTDIR)\write5_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write5_ss_flow.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write5_ss_flow.obj"	"$(INTDIR)\write5_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write5_ss_flow.obj"	"$(INTDIR)\write5_ss_flow.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mct.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\write6.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\write6.obj"	"$(INTDIR)\write6.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\write6.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\write6.obj"	"$(INTDIR)\write6.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\write6.obj"	"$(INTDIR)\write6.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\print_control_mod.mod" "$(INTDIR)\f_units.mod" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\hdf.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\hdf.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\hdf.obj"	"$(INTDIR)\hdf.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\hdf.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\hdf.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\hdf.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\hdf.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\hdf.obj"	"$(INTDIR)\hdf.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\hdf.obj"	"$(INTDIR)\hdf.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\hdf_f.f90

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\hdf_f.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\hdf_f.obj"	"$(INTDIR)\hdf_f.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\hdf_f.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\hdf_f.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\hdf_f.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\hdf_f.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\hdf_f.obj"	"$(INTDIR)\hdf_f.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\hdf_f.obj"	"$(INTDIR)\hdf_f.sbr" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\machine_constants.mod" "$(INTDIR)\mcb.mod" "$(INTDIR)\mcc.mod" "$(INTDIR)\mcch.mod" "$(INTDIR)\mcg.mod" "$(INTDIR)\mcn.mod" "$(INTDIR)\mcp.mod" "$(INTDIR)\mcv.mod" "$(INTDIR)\mcw.mod" "$(INTDIR)\mg2.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\mpimod.F90

!IF  "$(CFG)" == "phast - Win32 ser"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\mpimod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\mpimod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\mpimod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\mpimod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\mpimod.obj" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\mpimod.obj"	"$(INTDIR)\mpimod.sbr" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

!ENDIF 

SOURCE=..\merge.c

!IF  "$(CFG)" == "phast - Win32 ser"

!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich"

!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"

!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\merge.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\merge.obj"	"$(INTDIR)\merge.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"

!ENDIF 

SOURCE=..\cvdense.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\cvdense.obj"	"$(INTDIR)\cvdense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\cvdense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\cvdense.obj"	"$(INTDIR)\cvdense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\cvdense.obj"	"$(INTDIR)\cvdense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\cvode.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\cvode.obj"	"$(INTDIR)\cvode.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\cvode.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\cvode.obj"	"$(INTDIR)\cvode.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\cvode.obj"	"$(INTDIR)\cvode.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\dense.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\dense.obj"	"$(INTDIR)\dense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\dense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\dense.obj"	"$(INTDIR)\dense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\dense.obj"	"$(INTDIR)\dense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\input.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\input.obj"	"$(INTDIR)\input.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\input.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\input.obj"	"$(INTDIR)\input.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\input.obj"	"$(INTDIR)\input.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\nvector.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\nvector.obj"	"$(INTDIR)\nvector.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\nvector.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\nvector.obj"	"$(INTDIR)\nvector.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\nvector.obj"	"$(INTDIR)\nvector.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\nvector_serial.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\nvector_serial.obj"	"$(INTDIR)\nvector_serial.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\nvector_serial.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\nvector_serial.obj"	"$(INTDIR)\nvector_serial.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\nvector_serial.obj"	"$(INTDIR)\nvector_serial.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\output.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\output.obj"	"$(INTDIR)\output.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\output.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\output.obj"	"$(INTDIR)\output.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\output.obj"	"$(INTDIR)\output.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=.\phast.rc

"$(INTDIR)\phast.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=..\phast_files.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\phast_files.obj"	"$(INTDIR)\phast_files.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\phast_files.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\phast_files.obj"	"$(INTDIR)\phast_files.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\phast_files.obj"	"$(INTDIR)\phast_files.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\smalldense.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\smalldense.obj"	"$(INTDIR)\smalldense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\smalldense.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\smalldense.obj"	"$(INTDIR)\smalldense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\smalldense.obj"	"$(INTDIR)\smalldense.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\sundialsmath.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\sundialsmath.obj"	"$(INTDIR)\sundialsmath.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\sundialsmath.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\sundialsmath.obj"	"$(INTDIR)\sundialsmath.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\sundialsmath.obj"	"$(INTDIR)\sundialsmath.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=..\tally.c

!IF  "$(CFG)" == "phast - Win32 ser"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug"


"$(INTDIR)\tally.obj"	"$(INTDIR)\tally.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_debug"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_no_hdf_debug"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 mpich_profile"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge"


"$(INTDIR)\tally.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 merge_debug"


"$(INTDIR)\tally.obj"	"$(INTDIR)\tally.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "phast - Win32 ser_debug_mem"


"$(INTDIR)\tally.obj"	"$(INTDIR)\tally.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 


!ENDIF 

