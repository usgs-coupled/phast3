/*! @file IPhreeqc.h
	@brief C/Fortran Documentation
*/
#ifndef TM_INTERFACE_H
#define TM_INTERFACE_H
#if defined(_MSC_VER)
#define FC_FUNC_(name,NAME) NAME
#endif

#if defined(FC_FUNC_)
// Called from Fortran or C++
#define TM_transport                       FC_FUNC_ (tm_transport,                     TM_TRANSPORT)
#define TM_zone_flow_write_chem            FC_FUNC_ (tm_zone_flow_write_chem,          TM_ZONE_FLOW_WRITE_CHEM)
// Calls to Fortran
#define transport_component                FC_FUNC_ (transport_component,              TRANSPORT_COMPONENT)
#define transport_component_thread         FC_FUNC_ (transport_component_thread,       TRANSPORT_COMPONENT_THREAD)
#define zone_flow_write_chem               FC_FUNC_ (zone_flow_write_chem,             ZONE_FLOW_WRITE_CHEM)
#endif
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
