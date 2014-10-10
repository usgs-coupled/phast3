///*! @file RM_interface_F.h
//	@brief C/Fortran Documentation
//*/
#ifndef RM_INTERFACE_F_H
#define RM_INTERFACE_F_H

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RM_Abort                           FC_FUNC_ (rm_abort,                         RM_ABORT)
#define RM_CloseFiles                      FC_FUNC_ (rm_closefiles,                    RM_CLOSEFILES)  
#define RM_Concentrations2Utility          FC_FUNC_ (rm_concentrations2utility,        RM_CONCENTRATIONS2UTILITY)    
#define RM_Create                          FC_FUNC_ (rm_create,                        RM_CREATE)
#define RM_CreateMapping                   FC_FUNC_ (rm_createmapping,                 RM_CREATEMAPPING)
#define RM_DecodeError                     FC_FUNC_ (rm_decodeerror,                   RM_DECODEERROR)
#define RM_Destroy                         FC_FUNC_ (rm_destroy,                       RM_DESTROY)
#define RM_DumpModule                      FC_FUNC_ (rm_dumpmodule,                    RM_DUMPMODULE)
#define RM_ErrorMessage                    FC_FUNC_ (rm_errormessage,                  RM_ERRORMESSAGE)
#define RM_FindComponents                  FC_FUNC_ (rm_findcomponents,                RM_FINDCOMPONENTS)
#define RM_GetChemistryCellCount           FC_FUNC_ (rm_getchemistrycellcount,         RM_GETCHEMISTRYCELLCOUNT)
#define RM_GetComponent                    FC_FUNC_ (rm_getcomponent,                  RM_GETCOMPONENT)
#define RM_GetComponentCount               FC_FUNC_ (rm_getcomponentcount,             RM_GETCOMPONENTCOUNT)
#define RM_GetConcentrations               FC_FUNC_ (rm_getconcentrations,             RM_GETCONCENTRATIONS)
#define RM_GetDensity                      FC_FUNC_ (rm_getdensity,                    RM_GETDENSITY)
#define RM_GetErrorString                  FC_FUNC_ (rm_geterrorstring,                RM_GETERRORSTRING)
#define RM_GetErrorStringLength            FC_FUNC_ (rm_geterrorstringlength,          RM_GETERRORSTRINGLENGTH)
#define RM_GetFilePrefix                   FC_FUNC_ (rm_getfileprefix,                 RM_GETFILEPREFIX)
#define RM_GetGfw                          FC_FUNC_ (rm_getgfw,                        RM_GETGFW)
#define RM_GetGridCellCount                FC_FUNC_ (rm_getgridcellcount,              RM_GETGRIDCELLCOUNT)
#define RM_GetIPhreeqcId                   FC_FUNC_ (rm_getiphreeqcid,                 RM_GETIPHREEQCID)
#define RM_GetMpiMyself                    FC_FUNC_ (rm_getmpimyself,                  RM_GETMPIMYSELF)
#define RM_GetMpiTasks                     FC_FUNC_ (rm_getmpitasks,                   RM_GETMPITASKS)
#define RM_GetNthSelectedOutputUserNumber  FC_FUNC_ (rm_getnthselectedoutputusernumber, RM_GETNTHSELECTEDOUTPUTUSERNUMBER)
#define RM_GetSaturation                   FC_FUNC_ (rm_getsaturation,                 RM_GETSATURATION)
#define RM_GetSelectedOutput               FC_FUNC_ (rm_getselectedoutput,             RM_GETSELECTEDOUTPUT)
#define RM_GetSelectedOutputColumnCount    FC_FUNC_ (rm_getselectedoutputcolumncount,  RM_GETSELECTEDOUTPUTCOLUMNCOUNT)
#define RM_GetSelectedOutputCount          FC_FUNC_ (rm_getselectedoutputcount,        RM_GETSELECTEDOUTPUTCOUNT)
#define RM_GetSelectedOutputHeading        FC_FUNC_ (rm_getselectedoutputheading,      RM_GETSELECTEDOUTPUTHEADING)
#define RM_GetSelectedOutputRowCount       FC_FUNC_ (rm_getselectedoutputrowcount,     RM_GETSELECTEDOUTPUTROWCOUNT)
#define RM_GetSolutionVolume               FC_FUNC_ (rm_getsolutionvolume,             RM_GETSOLUTIONVOLUME)
#define RM_GetSpeciesConcentrations        FC_FUNC_ (rm_getspeciesconcentrations,      RM_GETSPECIESCONCENTRATIONS)
#define RM_GetSpeciesCount                 FC_FUNC_ (rm_getspeciescount,               RM_GETSPECIESCOUNT)
#define RM_GetSpeciesD25                   FC_FUNC_ (rm_getspeciesd25,                 RM_GETSPECIESD25)
#define RM_GetSpeciesName                  FC_FUNC_ (rm_getspeciesname,                RM_GETSPECIESNAME)
#define RM_GetSpeciesSaveOn                FC_FUNC_ (rm_getspeciessaveon,              RM_GETSPECIESSAVEON)
#define RM_GetSpeciesZ                     FC_FUNC_ (rm_getspeciesz,                   RM_GETSPECIESZ)
#define RM_GetThreadCount                  FC_FUNC_ (rm_getthreadcount,                RM_GETTHREADCOUNT)
#define RM_GetTime                         FC_FUNC_ (rm_gettime,                       RM_GETTIME)
#define RM_GetTimeConversion               FC_FUNC_ (rm_gettimeconversion,             RM_GETTIMECONVERSION)
#define RM_GetTimeStep                     FC_FUNC_ (rm_gettimestep,                   RM_GETTIMESTEP)
#define RM_InitialPhreeqc2Concentrations   FC_FUNC_ (rm_initialphreeqc2concentrations, RM_INITIALPHREEQC2CONCENTRATIONS)
#define RM_InitialPhreeqc2Module           FC_FUNC_ (rm_initialphreeqc2module,         RM_INITIALPHREEQC2MODULE)
#define RM_InitialPhreeqcCell2Module       FC_FUNC_ (rm_initialphreeqccell2module,     RM_INITIALPHREEQCCELL2MODULE)
#define RM_InitialPhreeqc2SpeciesConcentrations   FC_FUNC_ (rm_initialphreeqc2speciesconcentrations, RM_INITIALPHREEQC2SPECIESCONCENTRATIONS)
#define RM_LoadDatabase                    FC_FUNC_ (rm_loaddatabase,                  RM_LOADDATABASE)
#define RM_LogMessage                      FC_FUNC_ (rm_logmessage,                    RM_LOGMESSAGE)
#define RM_MpiWorker                       FC_FUNC_ (rm_mpiworker,                     RM_MPIWORKER)
#define RM_MpiWorkerBreak                  FC_FUNC_ (rm_mpiworkerbreak,                RM_MPIWORKERBREAK)
#define RM_OpenFiles                       FC_FUNC_ (rm_openfiles,                     RM_OPENFILES)
#define RM_OutputMessage                   FC_FUNC_ (rm_outputmessage,                 RM_OUTPUTMESSAGE)
#define RM_RunCells                        FC_FUNC_ (rm_runcells,                      RM_RUNCELLS)
#define RM_RunFile                         FC_FUNC_ (rm_runfile,                          RM_RUNFILE)
#define RM_RunString                       FC_FUNC_ (rm_runstring,                     RM_RUNSTRING)
#define RM_ScreenMessage                   FC_FUNC_ (rm_screenmessage,                 RM_SCREENMESSAGE)
#ifdef SKIP
#define RM_SetCellVolume				   FC_FUNC_ (rm_setcellvolume,                 RM_SETCELLVOLUME)
#endif
#define RM_SetComponentH2O				   FC_FUNC_ (rm_setcomponenth2o,               RM_SETCOMPONENTH2O)
#define RM_SetConcentrations			   FC_FUNC_ (rm_setconcentrations,             RM_SETCONCENTRATIONS)
#define RM_SetCurrentSelectedOutputUserNumber  FC_FUNC_ (rm_setcurrentselectedoutputusernumber, RM_SETCURRENTSELECTEDOUTPUTUSERNUMBER)
#define RM_SetDensity                      FC_FUNC_ (rm_setdensity,                    RM_SETDENSITY)
#define RM_SetDumpFileName                 FC_FUNC_ (rm_setdumpfilename,               RM_SETDUMPFILENAME)
#define RM_SetErrorHandlerMode             FC_FUNC_ (rm_seterrorhandlermode,           RM_SETERRORHANDLERMODE)
#define RM_SetFilePrefix                   FC_FUNC_ (rm_setfileprefix,                 RM_SETFILEPREFIX)
#define RM_SetMpiWorkerCallback            FC_FUNC_ (rm_setmpiworkercallback,          RM_SETMPIWORKERCALLBACK)
#define RM_SetPartitionUZSolids            FC_FUNC_ (rm_setpartitionuzsolids,          RM_SETPARTITIONUZSOLIDS)
#ifdef SKIP_RV
#define RM_SetPoreVolume                   FC_FUNC_ (rm_setporevolume,                 RM_SETPOREVOLUME)
#endif
#define RM_SetPorosity                     FC_FUNC_ (rm_setporosity,                   RM_SETPOROSITY)
#define RM_SetPrintChemistryMask           FC_FUNC_ (rm_setprintchemistrymask,         RM_SETPRINTCHEMISTRYMASK)
#define RM_SetPrintChemistryOn             FC_FUNC_ (rm_setprintchemistryon,           RM_SETPRINTCHEMISTRYON)
#define RM_SetPressure                     FC_FUNC_ (rm_setpressure,                   RM_SETPRESSURE)
#define RM_SetRebalanceFraction            FC_FUNC_ (rm_setrebalancefraction,          RM_SETREBALANCEFRACTION)
#define RM_SetRebalanceByCell              FC_FUNC_ (rm_setrebalancebycell,            RM_SETREBALANCEBYCELL)
#define RM_SetRepresentativeVolume		   FC_FUNC_ (rm_setrepresentativevolume,       RM_SETREPRESENTATIVEVOLUME)
#define RM_SetSaturation                   FC_FUNC_ (rm_setsaturation,                 RM_SETSATURATION)
#define RM_SetSelectedOutputOn             FC_FUNC_ (rm_setselectedoutputon,           RM_SETSELECTEDOUTPUTON)
#define RM_SetSpeciesSaveOn                FC_FUNC_ (rm_setspeciessaveon,              RM_SETSPECIESSAVEON)
#define RM_SetTemperature                  FC_FUNC_ (rm_settemperature,                RM_SETTEMPERATURE)
#define RM_SetTime                         FC_FUNC_ (rm_settime,                       RM_SETTIME)
#define RM_SetTimeConversion               FC_FUNC_ (rm_settimeconversion,             RM_SETTIMECONVERSION)
#define RM_SetTimeStep                     FC_FUNC_ (rm_settimestep,                   RM_SETTIMESTEP)
#define RM_SetUnitsExchange                FC_FUNC_ (rm_setunitsexchange,              RM_SETUNITSEXCHANGE)
#define RM_SetUnitsGasPhase                FC_FUNC_ (rm_setunitsgasphase,              RM_SETUNITSGASPHASE)
#define RM_SetUnitsKinetics                FC_FUNC_ (rm_setunitskinetics,              RM_SETUNITSKINETICS)
#define RM_SetUnitsPPassemblage            FC_FUNC_ (rm_setunitsppassemblage,          RM_SETUNITSPPASSEMBLAGE)
#define RM_SetUnitsSolution                FC_FUNC_ (rm_setunitssolution,              RM_SETUNITSSOLUTION)
#define RM_SetUnitsSSassemblage            FC_FUNC_ (rm_setunitsssassemblage,          RM_SETUNITSSSASSEMBLAGE)
#define RM_SetUnitsSSassemblage            FC_FUNC_ (rm_setunitsssassemblage,          RM_SETUNITSSSASSEMBLAGE)
#define RM_SetUnitsSurface                 FC_FUNC_ (rm_setunitssurface,               RM_SETUNITSSURFACE)
#define RM_SpeciesConcentrations2Module    FC_FUNC_ (rm_speciesconcentrations2module,  RM_SPECIESCONCENTRATIONS2MODULE)
#define RM_UseSolutionDensityVolume        FC_FUNC_ (rm_usesolutiondensityvolume,      RM_USESOLUTIONDENSITYVOLUME)
#define RM_WarningMessage                  FC_FUNC_ (rm_warningmessage,                RM_WARNINGMESSAGE)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

IRM_RESULT RM_Abort(int *id, int *result, const char * err_str, size_t l = 0);
IRM_RESULT RM_CloseFiles(int *id);
int        RM_Concentrations2Utility(int *id, double *c, int *n, double *tc, double *p_atm);
int        RM_Create(int *nxyz, int *nthreads = NULL);
IRM_RESULT RM_CreateMapping (int *id, int *grid2chem); 
IRM_RESULT RM_DecodeError (int *id, int *e); 
IRM_RESULT RM_Destroy(int *id);
IRM_RESULT RM_DumpModule(int *id, int *dump_on, int *append);
IRM_RESULT RM_ErrorMessage(int *id, const char *err_str, size_t l = 0);
int        RM_FindComponents(int *id);
int        RM_GetChemistryCellCount(int *id);
IRM_RESULT RM_GetComponent(int * id, int * num, char *chem_name, size_t l1);
int        RM_GetComponentCount(int * id);
IRM_RESULT RM_GetConcentrations(int *id, double *c);
IRM_RESULT RM_GetDensity(int *id, double *density);
IRM_RESULT RM_GetErrorString(int *id, char *prefix, size_t l);
int        RM_GetErrorStringLength(int *id);
IRM_RESULT RM_GetFilePrefix(int *id, char *prefix, size_t l);
IRM_RESULT RM_GetGfw(int *id, double * gfw);
int        RM_GetGridCellCount(int *id);
int        RM_GetIPhreeqcId(int *id, int *i);
int        RM_GetMpiMyself(int *id);
int        RM_GetMpiTasks(int *id);
int        RM_GetNthSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RM_GetSaturation(int *id, double *sat);
IRM_RESULT RM_GetSelectedOutput(int *id, double *so);
int        RM_GetSelectedOutputColumnCount(int *id);
int        RM_GetSelectedOutputCount(int *id);
IRM_RESULT RM_GetSelectedOutputHeading(int *id, int * icol, char * heading, size_t length);
int        RM_GetSelectedOutputRowCount(int *id);
IRM_RESULT RM_GetSolutionVolume(int *id, double *solution_volume);
IRM_RESULT RM_GetSpeciesConcentrations(int *id, double *species_conc);
int        RM_GetSpeciesCount(int *id);
IRM_RESULT RM_GetSpeciesD25(int *id, double *diffc);
IRM_RESULT RM_GetSpeciesName(int *id, int *i, char * name, size_t length);
int        RM_GetSpeciesSaveOn(int *id);
IRM_RESULT RM_GetSpeciesZ(int *id, double *z);
int        RM_GetThreadCount(int *id);
double     RM_GetTime(int *id);
double     RM_GetTimeConversion(int *id);
double     RM_GetTimeStep(int *id);
IRM_RESULT RM_InitialPhreeqc2Concentrations(
                int *id,
                double *c,
                int *n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction1 = NULL);
IRM_RESULT RM_InitialPhreeqc2Module(int *id,
                int *initial_conditions1,		        // 7 x nxyz end-member 1
                int *initial_conditions2 = NULL,		// 7 x nxyz end-member 2
                double *fraction1 = NULL);			    // 7 x nxyz fraction of end-member 1
IRM_RESULT RM_InitialPhreeqcCell2Module(int *id,
                int *n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int *dim_module_numbers);			    // Number of module cell numbers
IRM_RESULT RM_InitialPhreeqc2SpeciesConcentrations(
                int *id,
                double *species_c,
                int *n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction1 = NULL);
IRM_RESULT RM_LoadDatabase(int *id, const char *db_name, size_t l = 0);
IRM_RESULT RM_LogMessage(int * id, const char *str, size_t l = 0);
IRM_RESULT RM_MpiWorker(int * id);
IRM_RESULT RM_MpiWorkerBreak(int * id);
IRM_RESULT RM_OpenFiles(int * id);
IRM_RESULT RM_OutputMessage(int *id, const char * err_str, size_t l = 0);
IRM_RESULT RM_RunCells(int *id);
IRM_RESULT RM_RunFile(int *id, int * workers, int *initial_phreeqc, int *utility, const char *chem_name, size_t l = 0);
IRM_RESULT RM_RunString(int *id, int * workers, int *initial_phreeqc, int *utility, const char * input_string, size_t l = 0);
IRM_RESULT RM_ScreenMessage(int *id, const char *str, size_t l = 0);
#ifdef SKIP_RV
IRM_RESULT RM_SetCellVolume(int *id, double *t);
#endif
IRM_RESULT RM_SetComponentH2O(int *id, int *tf);
IRM_RESULT RM_SetConcentrations(int *id, double *t);
IRM_RESULT RM_SetCurrentSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RM_SetDensity(int *id, double *t);
IRM_RESULT RM_SetDumpFileName(int *id, const char *dump_name, size_t l = 0);
IRM_RESULT RM_SetErrorHandlerMode(int *id, int *mode);
IRM_RESULT RM_SetFilePrefix(int *id, const char *prefix, size_t l = 0);
IRM_RESULT RM_SetMpiWorkerCallback(int *id, int (*fcn)(int *x1));
IRM_RESULT RM_SetPartitionUZSolids(int *id, int *t);
#ifdef SKIP_RV
IRM_RESULT RM_SetPoreVolume(int *id, double *t);
#endif
IRM_RESULT RM_SetPorosity(int *id, double *t);
IRM_RESULT RM_SetPressure(int *id, double *t);
IRM_RESULT RM_SetPrintChemistryMask(int *id, int *t);
IRM_RESULT RM_SetPrintChemistryOn(int *id, int *worker, int *ip, int *utility);
IRM_RESULT RM_SetRebalanceByCell(int *id, int *method);
IRM_RESULT RM_SetRebalanceFraction(int *id, double *f);
IRM_RESULT RM_SetSaturation(int *id, double *t);
IRM_RESULT RM_SetSelectedOutputOn(int *id, int *selected_output);
IRM_RESULT RM_SetSpeciesSaveOn(int *id, int *save_on);
IRM_RESULT RM_SetTemperature(int *id, double *t);
IRM_RESULT RM_SetTime(int *id, double *t);
IRM_RESULT RM_SetTimeConversion(int *id, double *t);
IRM_RESULT RM_SetTimeStep(int *id, double *t);
IRM_RESULT RM_SetUnitsExchange(int *id, int *i);
IRM_RESULT RM_SetUnitsGasPhase(int *id, int *i);
IRM_RESULT RM_SetUnitsKinetics(int *id, int *i);
IRM_RESULT RM_SetUnitsPPassemblage(int *id, int *i);
IRM_RESULT RM_SetUnitsSolution(int *id, int *i);
IRM_RESULT RM_SetUnitsSSassemblage(int *id, int *i);
IRM_RESULT RM_SetUnitsSurface(int *id, int *i);
IRM_RESULT RM_SpeciesConcentrations2Module(int *id, double * species_conc);
IRM_RESULT RM_UseSolutionDensityVolume(int *id, int *tf);
IRM_RESULT RM_WarningMessage(int *id, const char *warn_str, size_t l = 0);
#if defined(__cplusplus)
}
#endif

#endif // RM_INTERFACE_F_H
