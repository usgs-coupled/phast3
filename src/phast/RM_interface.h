/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef RM_INTERFACE_H
#define RM_INTERFACE_H
#include "IPhreeqc.h"
#include "Var.h"
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define RM_calculate_well_ph               FC_FUNC_ (rm_calculate_well_ph,             RM_CALCULATE_WELL_PH)
#define RM_CloseFiles                      FC_FUNC_ (rm_closefiles,                    RM_CLOSEFILES)    
#define RM_convert_to_molal                FC_FUNC_ (rm_convert_to_molal,              RM_CONVERT_TO_MOLAL)   
#define RM_Create                          FC_FUNC_ (rm_create,                        RM_CREATE)
#define RM_CreateMapping                   FC_FUNC_ (rm_createmapping,                 RM_CREATEMAPPING)
#define RM_Destroy                         FC_FUNC_ (rm_destroy,                       RM_DESTROY)
#define RM_DumpModule                      FC_FUNC_ (rm_dumpmodule,                    RM_DUMPMODULE)
#define RM_Error                           FC_FUNC_ (rm_error,                         RM_ERROR)
#define RM_ErrorMessage                    FC_FUNC_ (rm_errormessage,                  RM_ERRORMESSAGE)
#define RM_FindComponents                  FC_FUNC_ (rm_findcomponents,                RM_FINDCOMPONENTS)
#define RM_GetChemistryCellCount           FC_FUNC_ (rm_getchemistrycellcount,         RM_GETNCHEMISTRYCELLCOUNT)
#define RM_GetComponent                    FC_FUNC_ (rm_getcomponent,                  RM_GETCOMPONENT)
#define RM_GetFilePrefix                   FC_FUNC_ (rm_getfileprefix,                 RM_GETFILEPREFIX)
#define RM_GetMpiMyself                    FC_FUNC_ (rm_getmpimyself,                  RM_GETMPIMYSELF)
#define RM_GetMpiTasks                     FC_FUNC_ (rm_getmpitasks,                   RM_GETMPITASKS)
#define RM_GetGridCellCount                FC_FUNC_ (rm_getgridcellcount,              RM_GETGRIDCELLCOUNT)
#define RM_GetNthSelectedOutputUserNumber  FC_FUNC_ (rm_getnthselectedoutputusernumber, RM_GETNTHSELECTEDOUTPUTUSERNUMBER)
#define RM_GetSelectedOutput               FC_FUNC_ (rm_getselectedoutput,             RM_GETSELECTEDOUTPUT)
#define RM_GetSelectedOutputColumnCount    FC_FUNC_ (rm_getselectedoutputcolumncount,  RM_GETSELECTEDOUTPUTCOLUMNCOUNT)
#define RM_GetSelectedOutputCount          FC_FUNC_ (rm_getselectedoutputcount,        RM_GETSELECTEDOUTPUTCOUNT)
#define RM_GetSelectedOutputHeading        FC_FUNC_ (rm_getselectedoutputheading,      RM_GETSELECTEDOUTPUTHEADING)
#define RM_GetSelectedOutputRowCount       FC_FUNC_ (rm_getselectedoutputrowcount,     RM_GETSELECTEDOUTPUTROWCOUNT)
#define RM_GetTime                         FC_FUNC_ (rm_gettime,                       RM_GETTIME)
#define RM_GetTimeConversion               FC_FUNC_ (rm_gettimeconversion,             RM_GETTIMECONVERSION)
#define RM_GetTimeStep                     FC_FUNC_ (rm_gettimestep,                   RM_GETTIMESTEP)
#define RM_InitialPhreeqc2Concentrations   FC_FUNC_ (rm_initialphreeqc2concentrations, RM_INITIALPHREEQC2CONCENTRATIONS)
#define RM_InitialPhreeqc2Module           FC_FUNC_ (rm_initialphreeqc2module,         RM_INITIALPHREEQC2MODULE)
#define RM_InitialPhreeqcRunFile           FC_FUNC_ (rm_initialphreeqcrunfile,         RM_INITIALPHREEQCRUNFILE)
#define RM_LoadDatabase                    FC_FUNC_ (rm_loaddatabase,                  RM_LOADDATABASE)
#define RM_LogMessage                      FC_FUNC_ (rm_logmessage,                    RM_LOGMESSAGE)
#define RM_LogScreenMessage                FC_FUNC_ (rm_logscreenmessage,              RM_LOGSCREENMESSAGE)
#define RM_OpenFiles                       FC_FUNC_ (rm_openfiles,                     RM_OPENFILES)
#define RM_RunCells                        FC_FUNC_ (rm_runcells,                      RM_RUNCELLS)
#define RM_ScreenMessage                   FC_FUNC_ (rm_screenmessage,                 RM_SCREENMESSAGE)
#define RM_SetCurrentSelectedOutputUserNumber  FC_FUNC_ (rm_setcurrentselectedoutputusernumber, RM_SETCURRENTSELECTEDOUTPUTUSERNUMBER)
#define RM_SetDensity                      FC_FUNC_ (rm_setdensity,                    RM_SETDENSITY)
#define RM_SetFilePrefix                   FC_FUNC_ (rm_setfileprefix,                 RM_SETFILEPREFIX)
#define RM_SetInputUnits                   FC_FUNC_ (rm_setinputunits,                 RM_SETINPUTUNITS)
#define RM_SetPartitionUZSolids            FC_FUNC_ (rm_setpartitionuzsolids,          RM_SETPARTITIONUZSOLIDS)
#define RM_SetPrintChemistryOn             FC_FUNC_ (rm_setprintchemistryon,           RM_SETPRINTCHEMISTRYON)
#define RM_SetPrintChemistryMask           FC_FUNC_ (rm_setprintchemistrymask,         RM_SETPRINTCHEMISTRYMASK)
#define RM_SetPressure                     FC_FUNC_ (rm_setpressure,                   RM_SETPRESSURE)
#define RM_SetPoreVolume                   FC_FUNC_ (rm_setporevolume,                 RM_SETPOREVOLUME)
#define RM_SetPoreVolumeZero               FC_FUNC_ (rm_setporevolumezero,             RM_SETPOREVOLUMEZERO)
#define RM_SetRebalance                    FC_FUNC_ (rm_setrebalance,                  RM_SETREBALANCE)
#define RM_SetSaturation                   FC_FUNC_ (rm_setsaturation,                 RM_SETSATURATION)
#define RM_SetSelectedOutputOn             FC_FUNC_ (rm_setselectedoutputon,           RM_SETSELECTEDOUTPUTON)
#define RM_SetTemperature                  FC_FUNC_ (rm_settemperature,                RM_SETTEMPERATURE)
#define RM_SetTimeConversion               FC_FUNC_ (rm_settimeconversion,             RM_SETTIMECONVERSION)
#define RM_SetCellVolume				   FC_FUNC_ (rm_setcellvolume,                 RM_SETCELLVOLUME)
#define RM_Module2Concentrations           FC_FUNC_ (rm_module2concentrations,         RM_MODULE2CONCENTRATIONS)
#define RM_write_bc_raw                    FC_FUNC_ (rm_write_bc_raw,                  RM_WRITE_BC_RAW)
#define RM_write_output                    FC_FUNC_ (rm_write_output,                  RM_WRITE_OUTPUT)
#define RM_WarningMessage                  FC_FUNC_ (rm_warningmessage,                RM_WARNINGMESSAGE)
#endif

class RM_interface
{
public:
	static int CreateReactionModule(int *nxyz, int *nthreads);
	static IRM_RESULT DestroyReactionModule(int *n);
	static Reaction_module* GetInstance(int *n);
	static void CleanupReactionModuleInstances(void);
	static PHRQ_io phast_io;

private:
	friend class Reaction_module;
	static std::map<size_t, Reaction_module*> Instances;
	static size_t InstancesIndex;
};

#if defined(__cplusplus)
extern "C" {
#endif
void       RM_calculate_well_ph(int *id, double *c, double * ph, double * alkalinity);
void       RM_CloseFiles(void);
void       RM_convert_to_molal(int *id, double *c, int *n, int *dim);
int        RM_Create(int *nxyz, int *nthreads = NULL);
IRM_RESULT RM_CreateMapping (int *id, int *grid2chem = NULL); 
IRM_RESULT RM_Destroy(int *id);
IRM_RESULT RM_DumpModule(int *id, int *dump_on = NULL, int *use_gz = NULL);
void       RM_Error(int *id);
void       RM_ErrorMessage(const char *err_str, long l = -1);
int        RM_FindComponents(int *id);
int        RM_GetChemistryCellCount(int *id);
IRM_RESULT RM_GetComponent(int * id, int * num, char *chem_name, int l1 = -1);
IRM_RESULT RM_GetFilePrefix(int *id, char *prefix, long l = -1);
int        RM_GetGridCellCount(int *id);
int        RM_GetMpiMyself(int *id);
int        RM_GetMpiTasks(int *id);
int        RM_GetNthSelectedOutputUserNumber(int *id, int *i);
IRM_RESULT RM_GetSelectedOutput(int *id, double *so = NULL);
int        RM_GetSelectedOutputColumnCount(int *id);
int        RM_GetSelectedOutputCount(int *id);
IRM_RESULT RM_GetSelectedOutputHeading(int *id, int * icol, char * heading, int length);
int        RM_GetSelectedOutputRowCount(int *id);
double     RM_GetTime(int *id);
double     RM_GetTimeConversion(int *id);
double     RM_GetTimeStep(int *id);
IRM_RESULT RM_InitialPhreeqc2Concentrations(
                int *id,
                double *c,
                int *n_boundary,
                int *dim, 
                int *boundary_solution1,  
                int *boundary_solution2 = NULL, 
                double *fraction = NULL);
IRM_RESULT RM_InitialPhreeqc2Module(int *id,
                int *initial_conditions1 = NULL,		// 7 x nxyz end-member 1
                int *initial_conditions2 = NULL,		// 7 x nxyz end-member 2
                double *fraction1 = NULL);			    // 7 x nxyz fraction of end-member 1
int        RM_InitialPhreeqcRunFile(int *id, const char *chem_name = NULL, long l = -1);
int        RM_LoadDatabase(int *id, const char *db_name = NULL, long l = -1);
void       RM_LogMessage(const char *err_str, long l = -1);
void       RM_LogScreenMessage(const char *err_str, long l = -1);
void       RM_Module2Concentrations(int *id, double *c = NULL);
IRM_RESULT RM_OpenFiles(int * solute, const char * prefix = NULL, int l_prefix = -1);
void       RM_RunCells(int *id,
                double *time,					        // time from transport 
                double *time_step,				        // time step from transport
                double *concentration,					// mass fractions nxyz:components
                int * stop_msg);
void       RM_ScreenMessage(const char *err_str, long l = -1);
void       RM_SetCellVolume(int *id, double *t);
int        RM_SetCurrentSelectedOutputUserNumber(int *id, int *i);
void       RM_SetDensity(int *id, double *t);
void       RM_SetDumpModuleOn(int *id, int *dump_on = NULL);
IRM_RESULT RM_SetFilePrefix(int *id, const char *prefix = NULL, long l = -1);
void       RM_SetInputUnits (int *id, int *sol=NULL, int *pp=NULL, int *ex=NULL, 
                int *surf=NULL, int *gas=NULL, int *ss=NULL, int *kin=NULL);
void       RM_SetPartitionUZSolids(int *id, int *t);
void       RM_SetPoreVolume(int *id, double *t);
void       RM_SetPoreVolumeZero(int *id, double *t);
int        RM_SetPrintChemistryOn(int *id, int *print_chem);
void       RM_SetPrintChemistryMask(int *id, int *t);
void       RM_SetPressure(int *id, double *t);
void       RM_SetRebalance(int *id, int *method, double *f);
void       RM_SetSaturation(int *id, double *t);
IRM_RESULT RM_SetSelectedOutputOn(int *id, int *selected_output = NULL);
void       RM_SetTemperature(int *id, double *t);
void       RM_SetTimeConversion(int *id, double *t);
void       RM_WarningMessage(const char *err_str, long l = -1);
void       RM_write_bc_raw(int *id, 
                int *solution_list, 
                int * bc_solution_count, 
                int * solution_number, 
                char *prefix, 
                int prefix_l);
void RM_write_output(int *id);

#if defined(__cplusplus)
}
#endif

// Global functions
//inline std::string trim_right(const std::string &source , const std::string& t = " \t")
//{
//	std::string str = source;
//	return str.erase( str.find_last_not_of(t) + 1);
//}
//
//inline std::string trim_left( const std::string& source, const std::string& t = " \t")
//{
//	std::string str = source;
//	return str.erase(0 , source.find_first_not_of(t) );
//}
//
//inline std::string trim(const std::string& source, const std::string& t = " \t")
//{
//	std::string str = source;
//	return trim_left( trim_right( str , t) , t );
//} 
#endif // RM_INTERFACE_H
