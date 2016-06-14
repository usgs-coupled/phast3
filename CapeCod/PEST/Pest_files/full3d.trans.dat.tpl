# <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
# <WPhast>
#   <!--Exported from C:\CapeCod\Phast3\2002Model\full3d.p4w-->
#   <!--Exported to   C:\CapeCod\Phast3\2002Model\full3d.trans.dat-->
# </WPhast>
# 
TITLE
.       3D model of sewage plume from sewage beds to Ashumet Pond
.       $Revision: 1.8 $ $Date: 2001/12/10 15:40:04 $
SOLUTE_TRANSPORT true
	-diffusivity  1e-009
STEADY_FLOW false
FREE_SURFACE_BC true
SOLUTION_METHOD
	-iterative_solver   true
	-tolerance          1e-016
	-save_directions    30
	-maximum_iterations 500
	-space_differencing 0
	-time_differencing  1
	-cross_dispersion   false
	-rebalance_fraction 0.5
	-rebalance_by_cell  true
UNITS
	-time                             years
	-horizontal_grid                  m
	-vertical_grid                    m
	-map_horizontal                   m
	-map_vertical                     m
	-head                             m
	-hydraulic_conductivity           m/s
	-specific_storage                 1/m
	-dispersivity                     m
	-flux                             meters/day
	-leaky_hydraulic_conductivity     m/s
	-leaky_thickness                  m
	-well_diameter                    m
	-well_flow_rate                   gallon/second
	-well_depth                       m
	-river_bed_hydraulic_conductivity m/s
	-river_bed_thickness              m
	-river_width                      m
	-river_depth                      m
	-drain_hydraulic_conductivity     m/s
	-drain_thickness                  m
	-drain_width                      m
	-equilibrium_phases               WATER
	-exchange                         WATER
	-surface                          WATER
	-solid_solutions                  WATER
	-kinetics                         WATER
	-gas_phase                        WATER
GRID
	-uniform X -600 1000 33
	-uniform Y -1200 400 33
	-uniform Z -30 15 19
	-snap X 0.001
	-snap Y 0.001
	-snap Z 0.001
	-chemistry_dimensions XYZ
	-print_orientation XZ
	-grid_origin   0  0  0
	-grid_angle    0
MEDIA
	-domain
		-active                   1
		-Kx                       0.00106
		-Ky                       0.00106
		-Kz                       0.0003
		-porosity                 0.39
		-specific_storage         0
		-long_dispersivity        0.0001
		-horizontal_dispersivity  0.0001
		-vertical_dispersivity    0.0001
		-tortuosity               1
	-box -600 -1200 -50 1200 800 20 GRID
		-active                   0
		-Kx                       0.00106
		-Ky                       0.00106
		-Kz                       0.0003
		-porosity                 0.39
		-specific_storage         0
		-long_dispersivity        0.0001
		-horizontal_dispersivity  0.0001
		-vertical_dispersivity    0.0001
	-box -600 -400 -50 -400 400 20 GRID
		-active                   1
	-box -400 -600 -50 0 400 20 GRID
		-active                   1
	-box 0 -800 -50 400 400 20 GRID
		-active                   1
	-box 400 -1000 -50 600 400 20 GRID
		-active                   1
	-box 600 -1200 -50 1000 400 20 GRID
		-active                   1
	-box 625 25 7.5 1000 400 20 GRID
		-active                   0
FLUX_BC
	-box -600 -1200 15 1200 800 15 GRID
		-face Z
		-associated_solution
			0 years	3
		-flux
			0 years	-0.0018
FLUX_BC
	-box -25 75 15 75 175 15 GRID
		-face Z
		-associated_solution
			0 years	3
			1936 years	2
			1984 years	3
		-flux
			0 years	-0.0018
			1936 years	-0.037
			1941 years	-0.114
			1946 years	-0.023
			1956 years	-0.126
			1971 years	-0.05
			1978 years	-0.114
			1984 years	-0.0018
FLUX_BC
	-box 25 -25 15 125 75 15 GRID
		-face Z
		-associated_solution
			0 years	3
			1936 years	3
			1941 years	2
			1978 years	3
			1984 years	4
			1996 years	3
		-flux
			0 years	-0.0018
			1941 years	-0.114
			1946 years	-0.023
			1956 years	-0.126
			1971 years	-0.05
			1978 years	-0.0018
			1984 years	-0.038
			1996 years	-0.0018
FLUX_BC
	-box -75 -125 15 25 -25 15 GRID
		-face Z
		-associated_solution
			0 years	3
			1936 years	3
			1941 years	2
			1978 years	3
			1984 years	4
			1996 years	3
		-flux
			0 years	-0.0018
			1941 years	-0.114
			1946 years	-0.023
			1956 years	-0.126
			1971 years	-0.05
			1978 years	-0.0018
			1984 years	-0.038
			1996 years	-0.0018
FLUX_BC
	-box -175 -175 15 -75 -75 15 GRID
		-face Z
		-associated_solution
			0 years	3
			1936 years	3
			1941 years	2
			1956 years	3
		-flux
			0 years	-0.0018
			1941 years	-0.114
			1946 years	-0.023
			1956 years	-0.0018
FLUX_BC
	-box -325 -25 15 -225 75 15 GRID
		-face Z
		-associated_solution
			0 years	3
			1936 years	3
			1941 years	2
			1956 years	3
		-flux
			0 years	-0.0018
			1941 years	-0.114
			1946 years	-0.023
			1956 years	-0.0018
LEAKY_BC
	-box -600 -400 -50 -600 400 20 GRID
		-face X
		-thickness               1700
		-hydraulic_conductivity  0.00106
		-head
			0 years	18.3
		-associated_solution
			0 years	1
LEAKY_BC
	-box 1000 -1200 -50 1000 0 20 GRID
		-face X
		-thickness               Y 800 -1200 1300 0
		-hydraulic_conductivity  0.00106
		-head
			0 years	10.19
		-associated_solution
			0	1
LEAKY_BC
	-box 1000 0 -50 1000 400 20 GRID
		-face X
		-thickness               1300
		-hydraulic_conductivity  0.00106
		-head
			0 years	10.19
		-associated_solution
			0 years	1
SPECIFIED_HEAD_BC
	-box 600 0 7.5 1200 400 15 GRID
		-head
			0 years	13.42
		-associated_solution
			0 years	1
HEAD_IC
	-domain
		-head                     16.0419565217391
HEAD_IC
	-box -600 -1200 -50 1200 400 20 GRID
		-head                     X 18.3 -2300 12.19 2300
CHEMISTRY_IC
	-domain
		-solution            1
		-equilibrium_phases  1
		-surface             1
		-kinetics            1
CHEMISTRY_IC
	-box -300 -150 -10 600 150 15 GRID
		-kinetics            2
PRINT_INITIAL
	-boundary_conditions        true
	-components                 false
	-conductances               false
	-echo_input                 true
	-fluid_properties           true
	-force_chemistry_print      false
	-HDF_chemistry              true
	-HDF_heads                  true
	-HDF_media                  true
	-HDF_steady_flow_velocities false
	-heads                      true
	-media_properties           true
	-solution_method            true
	-steady_flow_velocities     false
	-wells                      true
	-xyz_chemistry              false
	-xyz_components             false
	-xyz_heads                  false
	-xyz_steady_flow_velocities false
	-xyz_wells                  false
PRINT_FREQUENCY
	-save_final_heads true
	0
		-bc_flow_rates          0
		-boundary_conditions    false 
		-components             0
		-conductances           0
		-end_of_period_default  true 
		-flow_balance           1    years
		-force_chemistry_print  0
		-HDF_chemistry          0.5    years
		-HDF_heads              end 
		-HDF_velocities         0
		-heads                  end 
		-progress_statistics    end 
		-restart_file           0
		-velocities             0
		-wells                  end 
		-xyz_chemistry          0
		-xyz_components         0
		-xyz_heads              500    years
		-xyz_velocities         0
		-xyz_wells              0
		-zone_flow              end 
		-zone_flow_xyzt         end 
		-zone_flow_tsv          end 
		-hdf_intermediate       end 
TIME_CONTROL
	-time_step
		0 0.25
		1941 0.25
		1946 0.25
		1956 0.25
		1957 0.25
		1971 0.25
	-time_change
		2055
	-start_time 1936
