/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef TM_INTERFACE_H
#define TM_INTERFACE_H

#if defined(__cplusplus)
extern "C" {
#endif
void TM_transport(int *id, int *ncomps, int *nthreads);
void TM_zone_flow_write_chem(int *);

extern void transport_component(int *i);
extern void transport_component_thread(int *i);
extern void zone_flow_write_chem(void);

#if defined(__cplusplus)
}
#endif

#endif // TM_INTERFACE_H
