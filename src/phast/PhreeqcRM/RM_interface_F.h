///*! @file RM_interface_F.h
//	@brief C/Fortran Documentation
//*/
#ifndef RMF_INTERFACE_F_H
#define RMF_INTERFACE_F_H

#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RMF_Abort                           FC_FUNC_ (RMF_abort,                         RMF_ABORT)
#define RMF_CloseFiles                      FC_FUNC_ (RMF_closefiles,                    RMF_CLOSEFILES)  
#define RMF_Concentrations2Utility          FC_FUNC_ (RMF_concentrations2utility,        RMF_CONCENTRATIONS2UTILITY)    
#define RMF_Create                          FC_FUNC_ (RMF_create,                        RMF_CREATE)
#define RMF_CreateMapping                   FC_FUNC_ (RMF_createmapping,                 RMF_CREATEMAPPING)
#define RMF_DecodeError                     FC_FUNC_ (RMF_decodeerror,                   RMF_DECODEERROR)
#define RMF_Destroy                         FC_FUNC_ (RMF_destroy,                       RMF_DESTROY)
#define RMF_DumpModule                      FC_FUNC_ (RMF_dumpmodule,                    RMF_DUMPMODULE)
#define RMF_ErrorMessage                    FC_FUNC_ (RMF_errormessage,                  RMF_ERRORMESSAGE)
#define RMF_FindComponents                  FC_FUNC_ (RMF_findcomponents,                RMF_FINDCOMPONENTS)
#define RMF_GetChemistryCellCount           FC_FUNC_ (RMF_getchemistrycellcount,         RMF_GETCHEMISTRYCELLCOUNT)
#define RMF_GetComponent                    FC_FUNC_ (RMF_getcomponent,                  RMF_GETCOMPONENT)
#define RMF_GetComponentCount               FC_FUNC_ (rmf_getcomponentcount,             RMF_GETCOMPONENTCOUNT)
#define RMF_GetConcentrations               FC_FUNC_ (RMF_getconcentrations,             RMF_GETCONCENTRATIONS)
#define RMF_GetDensity                      FC_FUNC_ (RMF_getdensity,                    RMF_GETDENSITY)
#define RMF_GetErrorString                  FC_FUNC_ (RMF_geterrorstring,                RMF_GETERRORSTRING)
#define RMF_GetErrorStringLength            FC_FUNC_ (RMF_geterrorstringlength,          RMF_GETERRORSTRINGLENGTH)
#define RMF_GetFilePrefix                   FC_FUNC_ (RMF_getfileprefix,                 RMF_GETFILEPREFIX)
#define RMF_GetGfw                          FC_FUNC_ (RMF_getgfw,                        RMF_GETGFW)
#define RMF_GetGridCellCount                FC_FUNC_ (RMF_getgridcellcount,              RMF_GETGRIDCELLCOUNT)
#define RMF_GetIPhreeqcId                   FC_FUNC_ (RMF_getiphreeqcid,                 RMF_GETIPHREEQCID)
#define RMF_GetMpiMyself                    FC_FUNC_ (RMF_getmpimyself,                  RMF_GETMPIMYSELF)
#define RMF_GetMpiTasks                     FC_FUNC_ (RMF_getmpitasks,                   RMF_GETMPITASKS)
#define RMF_GetNthSelectedOutputUserNumber  FC_FUNC_ (RMF_getnthselectedoutputusernumber, RMF_GETNTHSELECTEDOUTPUTUSERNUMBER)
#define RMF_GetSaturation                   FC_FUNC_ (RMF_getsaturation,                 RMF_GETSATURATION)
#define RMF_GetSelectedOutput               FC_FUNC_ (RMF_getselectedoutput,             RMF_GETSELECTEDOUTPUT)
#define RMF_GetSelectedOutputColumnCount    FC_FUNC_ (RMF_getselectedoutputcolumncount,  RMF_GETSELECTEDOUTPUTCOLUMNCOUNT)
#define RMF_GetSelectedOutputCount          FC_FUNC_ (RMF_getselectedoutputcount,        RMF_GETSELECTEDOUTPUTCOUNT)
#define RMF_GetSelectedOutputHeading        FC_FUNC_ (RMF_getselectedoutputheading,      RMF_GETSELECTEDOUTPUTHEADING)
#define RMF_GetSelectedOutputRowCount       FC_FUNC_ (RMF_getselectedoutputrowcount,     RMF_GETSELECTEDOUTPUTROWCOUNT)
#define RMF_GetSolutionVolume               FC_FUNC_ (RMF_getsolutionvolume,             RMF_GETSOLUTIONVOLUME)
#define RMF_GetSpeciesConcentrations        FC_FUNC_ (RMF_getspeciesconcentrations,      RMF_GETSPECIESCONCENTRATIONS)
#define RMF_GetSpeciesCount                 FC_FUNC_ (RMF_getspeciescount,               RMF_GETSPECIESCOUNT)
#define RMF_GetSpeciesD25                   FC_FUNC_ (RMF_getspeciesd25,                 RMF_GETSPECIESD25)
#define RMF_GetSpeciesName                  FC_FUNC_ (RMF_getspeciesname,                RMF_GETSPECIESNAME)
#define RMF_GetSpeciesSaveOn                FC_FUNC_ (RMF_getspeciessaveon,              RMF_GETSPECIESSAVEON)
#define RMF_GetSpeciesZ                     FC_FUNC_ (RMF_getspeciesz,                   RMF_GETSPECIESZ)
#define RMF_GetThreadCount                  FC_FUNC_ (RMF_getthreadcount,                RMF_GETTHREADCOUNT)
#define RMF_GetTime                         FC_FUNC_ (RMF_gettime,                       RMF_GETTIME)
#define RMF_GetTimeConversion               FC_FUNC_ (RMF_gettimeconversion,             RMF_GETTIMECONVERSION)
#define RMF_GetTimeStep                     FC_FUNC_ (RMF_gettimestep,                   RMF_GETTIMESTEP)
#define RMF_InitialPhreeqc2Concentrations   FC_FUNC_ (RMF_initialphreeqc2concentrations, RMF_INITIALPHREEQC2CONCENTRATIONS)
#define RMF_InitialPhreeqc2Module           FC_FUNC_ (RMF_initialphreeqc2module,         RMF_INITIALPHREEQC2MODULE)
#define RMF_InitialPhreeqcCell2Module       FC_FUNC_ (RMF_initialphreeqccell2module,     RMF_INITIALPHREEQCCELL2MODULE)
#define RMF_InitialPhreeqc2SpeciesConcentrations   FC_FUNC_ (RMF_initialphreeqc2speciesconcentrations, RMF_INITIALPHREEQC2SPECIESCONCENTRATIONS)
#define RMF_LoadDatabase                    FC_FUNC_ (RMF_loaddatabase,                  RMF_LOADDATABASE)
#define RMF_LogMessage                      FC_FUNC_ (RMF_logmessage,                    RMF_LOGMESSAGE)
#define RMF_MpiWorker                       FC_FUNC_ (RMF_mpiworker,                     RMF_MPIWORKER)
#define RMF_MpiWorkerBreak                  FC_FUNC_ (RMF_mpiworkerbreak,                RMF_MPIWORKERBREAK)
#define RMF_OpenFiles                       FC_FUNC_ (RMF_openfiles,                     RMF_OPENFILES)
#define RMF_OutputMessage                   FC_FUNC_ (RMF_outputmessage,                 RMF_OUTPUTMESSAGE)
#define RMF_RunCells                        FC_FUNC_ (RMF_runcells,                      RMF_RUNCELLS)
#define RMF_RunFile                         FC_FUNC_ (RMF_runfile,                          RMF_RUNFILE)
#define RMF_RunString                       FC_FUNC_ (RMF_runstring,                     RMF_RUNSTRING)
#define RMF_ScreenMessage                   FC_FUNC_ (RMF_screenmessage,                 RMF_SCREENMESSAGE)
#ifdef SKIP_RV
#define RMF_SetCellVolume				   FC_FUNC_ (RMF_setcellvolume,                 RMF_SETCELLVOLUME)
#endif
#define RMF_SetComponentH2O				   FC_FUNC_ (RMF_setcomponenth2o,               RMF_SETCOMPONENTH2O)
#define RMF_SetConcentrations			   FC_FUNC_ (RMF_setconcentrations,             RMF_SETCONCENTRATIONS)
#define RMF_SetCurrentSelectedOutputUserNumber  FC_FUNC_ (RMF_setcurrentselectedoutputusernumber, RMF_SETCURRENTSELECTEDOUTPUTUSERNUMBER)
#define RMF_SetDensity                      FC_FUNC_ (RMF_setdensity,                    RMF_SETDENSITY)
#define RMF_SetDumpFileName                 FC_FUNC_ (RMF_setdumpfilename,               RMF_SETDUMPFILENAME)
#define RMF_SetErrorHandlerMode             FC_FUNC_ (RMF_seterrorhandlermode,           RMF_SETERRORHANDLERMODE)
#define RMF_SetFilePrefix                   FC_FUNC_ (RMF_setfileprefix,                 RMF_SETFILEPREFIX)
#define RMF_SetMpiWorkerCallback            FC_FUNC_ (RMF_setmpiworkercallback,          RMF_SETMPIWORKERCALLBACK)
#define RMF_SetPartitionUZSolids            FC_FUNC_ (RMF_setpartitionuzsolids,          RMF_SETPARTITIONUZSOLIDS)
#ifdef SKIP_RV
#define RMF_SetPoreVolume                   FC_FUNC_ (RMF_setporevolume,                 RMF_SETPOREVOLUME)
#endif
#define RMF_SetPorosity                     FC_FUNC_ (RMF_setporosity,                   RMF_SETPOROSITY)
#define RMF_SetPrintChemistryMask           FC_FUNC_ (RMF_setprintchemistrymask,         RMF_SETPRINTCHEMISTRYMASK)
#define RMF_SetPrintChemistryOn             FC_FUNC_ (RMF_setprintchemistryon,           RMF_SETPRINTCHEMISTRYON)
#define RMF_SetPressure                     FC_FUNC_ (RMF_setpressure,                   RMF_SETPRESSURE)
#define RMF_SetRebalanceFraction            FC_FUNC_ (RMF_setrebalancefraction,          RMF_SETREBALANCEFRACTION)
#define RMF_SetRebalanceByCell              FC_FUNC_ (RMF_setrebalancebycell,            RMF_SETREBALANCEBYCELL)
#define RMF_SetRepresentativeVolume		   FC_FUNC_ (RMF_setrepresentativevolume,       RMF_SETREPRESENTATIVEVOLUME)
#define RMF_SetSaturation                   FC_FUNC_ (RMF_setsaturation,                 RMF_SETSATURATION)
#define RMF_SetSelectedOutputOn             FC_FUNC_ (RMF_setselectedoutputon,           RMF_SETSELECTEDOUTPUTON)
#define RMF_SetSpeciesSaveOn                FC_FUNC_ (RMF_setspeciessaveon,              RMF_SETSPECIESSAVEON)
#define RMF_SetTemperature                  FC_FUNC_ (RMF_settemperature,                RMF_SETTEMPERATURE)
#define RMF_SetTime                         FC_FUNC_ (RMF_settime,                       RMF_SETTIME)
#define RMF_SetTimeConversion               FC_FUNC_ (RMF_settimeconversion,             RMF_SETTIMECONVERSION)
#define RMF_SetTimeStep                     FC_FUNC_ (RMF_settimestep,                   RMF_SETTIMESTEP)
#define RMF_SetUnitsExchange                FC_FUNC_ (RMF_setunitsexchange,              RMF_SETUNITSEXCHANGE)
#define RMF_SetUnitsGasPhase                FC_FUNC_ (RMF_setunitsgasphase,              RMF_SETUNITSGASPHASE)
#define RMF_SetUnitsKinetics                FC_FUNC_ (RMF_setunitskinetics,              RMF_SETUNITSKINETICS)
#define RMF_SetUnitsPPassemblage            FC_FUNC_ (RMF_setunitsppassemblage,          RMF_SETUNITSPPASSEMBLAGE)
#define RMF_SetUnitsSolution                FC_FUNC_ (RMF_setunitssolution,              RMF_SETUNITSSOLUTION)
#define RMF_SetUnitsSSassemblage            FC_FUNC_ (RMF_setunitsssassemblage,          RMF_SETUNITSSSASSEMBLAGE)
#define RMF_SetUnitsSSassemblage            FC_FUNC_ (RMF_setunitsssassemblage,          RMF_SETUNITSSSASSEMBLAGE)
#define RMF_SetUnitsSurface                 FC_FUNC_ (RMF_setunitssurface,               RMF_SETUNITSSURFACE)
#define RMF_SpeciesConcentrations2Module    FC_FUNC_ (RMF_speciesconcentrations2module,  RMF_SPECIESCONCENTRATIONS2MODULE)
#define RMF_UseSolutionDensityVolume        FC_FUNC_ (RMF_usesolutiondensityvolume,      RMF_USESOLUTIONDENSITYVOLUME)
#define RMF_WarningMessage                  FC_FUNC_ (RMF_warningmessage,                RMF_WARNINGMESSAGE)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

IRM_RESULT RMF_Abort(int *id, int *result, const char * err_str);
IRM_RESULT RMF_CloseFiles(int *id);
int        RMF_Concentrations2Utility(int *id, double *c, int *n, double *tc, double *p_atm);
int        RMF_Create(int *nxyz, int *nthreads = NULL);
IRM_RESULT RMF_CreateMapping (int *id, int *grid2chem); 
IRM_RESULT RMF_DecodeError (int *id, int *e); 
IRM_RESULT RMF_Destroy(int *id);
IRM_RESULT RMF_DumpModule(int *id, int *dump_on, int *append);
IRM_RESULT RMF_ErrorMessage(int *id, const char *err_str);
int        RMF_FindComponents(int *id);
int        RMF_GetChemistryCellCount(int *id);
IRM_RESULT RMF_GetComponent(int * id, int * num, char *chem_name, int *l1);
int        RMF_GetComponentCount(int * id);
IRM_RESULT RMF_GetConcentrations(int *id, double *c);
IRM_RESULT RMF_GetDensity(int *id, double *density);
IRM_RESULT RMF_GetErrorString(int *id, char *prefix, int *l);
int        RMF_GetErrorStringLength(int *id);
IRM_RESULT RMF_GetFilePrefix(int *id, char *prefix, int *l);
IRM_RESULT RMF_GetGfw(int *id, double * gfw);
int        RMF_GetGridCellCount(int *id);
int        RMF_GetIPhreeqcId(int *id, int *i);
int        RMF_GetMpiMyself(int *id);
int        RMF_GetMpiTasks(int *id);
int        RMF_GetNthSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RMF_GetSaturation(int *id, double *sat);
IRM_RESULT RMF_GetSelectedOutput(int *id, double *so);
int        RMF_GetSelectedOutputColumnCount(int *id);
int        RMF_GetSelectedOutputCount(int *id);
IRM_RESULT RMF_GetSelectedOutputHeading(int *id, int * icol, char * heading, int *length);
int        RMF_GetSelectedOutputRowCount(int *id);
IRM_RESULT RMF_GetSolutionVolume(int *id, double *solution_volume);
IRM_RESULT RMF_GetSpeciesConcentrations(int *id, double *species_conc);
int        RMF_GetSpeciesCount(int *id);
IRM_RESULT RMF_GetSpeciesD25(int *id, double *diffc);
IRM_RESULT RMF_GetSpeciesName(int *id, int *i, char * name, int *length);
int        RMF_GetSpeciesSaveOn(int *id);
IRM_RESULT RMF_GetSpeciesZ(int *id, double *z);
int        RMF_GetThreadCount(int *id);
double     RMF_GetTime(int *id);
double     RMF_GetTimeConversion(int *id);
double     RMF_GetTimeStep(int *id);
IRM_RESULT RMF_InitialPhreeqc2Concentrations(
                int *id,
                double *c,
                int *n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction1 = NULL);
IRM_RESULT RMF_InitialPhreeqc2Module(int *id,
                int *initial_conditions1,		        // 7 x nxyz end-member 1
                int *initial_conditions2 = NULL,		// 7 x nxyz end-member 2
                double *fraction1 = NULL);			    // 7 x nxyz fraction of end-member 1
IRM_RESULT RMF_InitialPhreeqcCell2Module(int *id,
                int *n,		                            // InitialPhreeqc cell number
                int *module_numbers,		            // Module cell numbers
                int *dim_module_numbers);			    // Number of module cell numbers
IRM_RESULT RMF_InitialPhreeqc2SpeciesConcentrations(
                int *id,
                double *species_c,
                int *n_boundary,
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction1 = NULL);
IRM_RESULT RMF_LoadDatabase(int *id, const char *db_name);
IRM_RESULT RMF_LogMessage(int * id, const char *str);
IRM_RESULT RMF_MpiWorker(int * id);
IRM_RESULT RMF_MpiWorkerBreak(int * id);
IRM_RESULT RMF_OpenFiles(int * id);
IRM_RESULT RMF_OutputMessage(int *id, const char * err_str);
IRM_RESULT RMF_RunCells(int *id);
IRM_RESULT RMF_RunFile(int *id, int * workers, int *initial_phreeqc, int *utility, const char *chem_name);
IRM_RESULT RMF_RunString(int *id, int * workers, int *initial_phreeqc, int *utility, const char * input_string);
IRM_RESULT RMF_ScreenMessage(int *id, const char *str, size_t l = 0);
#ifdef SKIP_RV
IRM_RESULT RMF_SetCellVolume(int *id, double *t);
#endif
IRM_RESULT RMF_SetComponentH2O(int *id, int *tf);
IRM_RESULT RMF_SetConcentrations(int *id, double *t);
IRM_RESULT RMF_SetCurrentSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RMF_SetDensity(int *id, double *t);
IRM_RESULT RMF_SetDumpFileName(int *id, const char *dump_name);
IRM_RESULT RMF_SetErrorHandlerMode(int *id, int *mode);
IRM_RESULT RMF_SetFilePrefix(int *id, const char *prefix);
IRM_RESULT RMF_SetMpiWorkerCallback(int *id, int (*fcn)(int *x1));
IRM_RESULT RMF_SetPartitionUZSolids(int *id, int *t);
#ifdef SKIP_RV
IRM_RESULT RMF_SetPoreVolume(int *id, double *t);
#endif
IRM_RESULT RMF_SetPorosity(int *id, double *t);
IRM_RESULT RMF_SetPressure(int *id, double *t);
IRM_RESULT RMF_SetPrintChemistryMask(int *id, int *t);
IRM_RESULT RMF_SetPrintChemistryOn(int *id, int *worker, int *ip, int *utility);
IRM_RESULT RMF_SetRebalanceByCell(int *id, int *method);
IRM_RESULT RMF_SetRebalanceFraction(int *id, double *f);
IRM_RESULT RMF_SetRepresentativeVolume(int *id, double *t);
IRM_RESULT RMF_SetSaturation(int *id, double *t);
IRM_RESULT RMF_SetSelectedOutputOn(int *id, int *selected_output);
IRM_RESULT RMF_SetSpeciesSaveOn(int *id, int *save_on);
IRM_RESULT RMF_SetTemperature(int *id, double *t);
IRM_RESULT RMF_SetTime(int *id, double *t);
IRM_RESULT RMF_SetTimeConversion(int *id, double *t);
IRM_RESULT RMF_SetTimeStep(int *id, double *t);
IRM_RESULT RMF_SetUnitsExchange(int *id, int *i);
IRM_RESULT RMF_SetUnitsGasPhase(int *id, int *i);
IRM_RESULT RMF_SetUnitsKinetics(int *id, int *i);
IRM_RESULT RMF_SetUnitsPPassemblage(int *id, int *i);
IRM_RESULT RMF_SetUnitsSolution(int *id, int *i);
IRM_RESULT RMF_SetUnitsSSassemblage(int *id, int *i);
IRM_RESULT RMF_SetUnitsSurface(int *id, int *i);
IRM_RESULT RMF_SpeciesConcentrations2Module(int *id, double * species_conc);
IRM_RESULT RMF_UseSolutionDensityVolume(int *id, int *tf);
IRM_RESULT RMF_WarningMessage(int *id, const char *warn_str);
#if defined(__cplusplus)
}
#endif

#endif // RMF_INTERFACE_F_H
