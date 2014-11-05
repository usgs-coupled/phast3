///*! @file RM_interface_F.h
//	@brief C/Fortran Documentation
//*/
#ifndef RMF_INTERFACE_F_H
#define RMF_INTERFACE_F_H

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
