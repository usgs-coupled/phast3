# examples directory
#
set(EXAMPLES_DIR examples)

# decay
#
set(example_decaydir ${EXAMPLES_DIR}/decay)

set(decay
decay/decay.chem.dat
decay/decay.trans.dat
decay/phast.dat
)

install(FILES ${decay} DESTINATION ${example_decaydir})


# diffusion1d
#
set(example_diffusion1ddir ${EXAMPLES_DIR}/diffusion1d)

set(diffusion1d
diffusion1d/diffusion1d.chem.dat
diffusion1d/diffusion1d.head.dat
diffusion1d/diffusion1d.trans.dat
diffusion1d/phast.dat
)

install(FILES ${diffusion1d} DESTINATION ${example_diffusion1ddir})


# diffusion2d
#
set(example_diffusion2ddir ${EXAMPLES_DIR}/diffusion2d)

set(diffusion2d
diffusion2d/diffusion2d.chem.dat
diffusion2d/diffusion2d.head.dat
diffusion2d/diffusion2d.trans.dat
diffusion2d/phast.dat
)

install(FILES ${decay} DESTINATION ${example_decaydir})


# disp2d
#
set(example_disp2ddir ${EXAMPLES_DIR}/disp2d)

set(disp2d
disp2d/disp2d.chem.dat
disp2d/disp2d.trans.dat
disp2d/phast.dat
)

install(FILES ${disp2d} DESTINATION ${example_disp2ddir})


# ex1
#
set(example_ex1dir ${EXAMPLES_DIR}/ex1)

set(ex1
ex1/ex1.chem.dat
ex1/ex1.trans.dat
ex1/phast.dat
)

install(FILES ${ex1} DESTINATION ${example_ex1dir})


# ex2
#
set(example_ex2dir ${EXAMPLES_DIR}/ex2)

set(ex2
ex2/ex2.chem.dat
ex2/ex2.trans.dat
ex2/phast.dat
)

install(FILES ${ex2} DESTINATION ${example_ex2dir})


# ex3
#
set(example_ex3dir ${EXAMPLES_DIR}/ex3)

set(ex3
ex3/ex3.chem.dat
ex3/ex3.trans.dat
ex3/phast.dat
)

install(FILES ${ex3} DESTINATION ${example_ex3dir})


# ex4
#
set(example_ex4dir ${EXAMPLES_DIR}/ex4)

set(ex4
ex4/ex4.chem.dat
ex4/ex4.restart.gz
ex4/ex4.trans.dat
ex4/phast.dat
)

install(FILES ${ex4} DESTINATION ${example_ex4dir})


# ex4_ddl
#
set(example_ex4_ddldir ${EXAMPLES_DIR}/ex4_ddl)

set(ex4_ddl
ex4_ddl/ex4_ddl.chem.dat
ex4_ddl/ex4_ddl.trans.dat
ex4_ddl/phast.dat
)

install(FILES ${ex4_ddl} DESTINATION ${example_ex4_ddldir})


# ex4_noedl
#
set(example_ex4_noedldir ${EXAMPLES_DIR}/ex4_noedl)

set(ex4_noedl
ex4_noedl/ex4_noedl.chem.dat
ex4_noedl/ex4_noedl.trans.dat
ex4_noedl/phast.dat
)

install(FILES ${ex4_noedl} DESTINATION ${example_ex4_noedldir})


# ex4_start_time
#
set(example_ex4_start_timedir ${EXAMPLES_DIR}/ex4_start_time)

set(ex4_start_time
ex4_start_time/ex4_start_time.chem.dat
ex4_start_time/ex4_start_time.trans.dat
ex4_start_time/phast.dat
)

install(FILES ${ex4_start_time} DESTINATION ${example_ex4_start_timedir})


# ex4_transient
#
set(example_ex4_transientdir ${EXAMPLES_DIR}/ex4_transient)

set(ex4_transient
ex4_transient/ex4.head.dat
ex4_transient/ex4_transient.chem.dat
ex4_transient/ex4_transient.trans.dat
ex4_transient/initial.head.dat
ex4_transient/phast.dat
)

install(FILES ${ex4_transient} DESTINATION ${example_ex4_transientdir})


# ex4restart
#
set(example_ex4restartdir ${EXAMPLES_DIR}/ex4restart)

set(ex4restart
ex4restart/ex4.head.dat
ex4restart/ex4.restart.gz
ex4restart/ex4restart.chem.dat
ex4restart/ex4restart.trans.dat
ex4restart/phast.dat
)

install(FILES ${ex4restart} DESTINATION ${example_ex4restartdir})


# ex5
#
set(example_ex5dir            ${EXAMPLES_DIR}/ex5)
set(example_ex5_ArcDatadir    ${EXAMPLES_DIR}/ex5/ArcData)
set(example_ex5_Parametersdir ${EXAMPLES_DIR}/ex5/Parameters)

set(ex5
ex5/ex5.head.200.dat
ex5/ex5.trans.dat
)

install(FILES ${ex5} DESTINATION ${example_ex5dir})

set(ArcData
ex5/ArcData/Ashumet.dbf
ex5/ArcData/Ashumet.shp
ex5/ArcData/Ashumet.shx
ex5/ArcData/AshumetBath.dbf
ex5/ArcData/AshumetBath.shp
ex5/ArcData/AshumetBath.shx
ex5/ArcData/bedrock.txt
ex5/ArcData/Coona.dbf
ex5/ArcData/Coona.shp
ex5/ArcData/Coona.shx
ex5/ArcData/CoonaBath.dbf
ex5/ArcData/CoonaBath.shp
ex5/ArcData/CoonaBath.shx
ex5/ArcData/ModelExtent.dbf
ex5/ArcData/ModelExtent.shp
ex5/ArcData/ModelExtent.shx
ex5/ArcData/OffShore.dbf
ex5/ArcData/OffShore.shp
ex5/ArcData/OffShore.shx
ex5/ArcData/OnShore.dbf
ex5/ArcData/OnShore.shp
ex5/ArcData/OnShore.shx
ex5/ArcData/SimpleBath.dbf
ex5/ArcData/SimpleBath.shp
ex5/ArcData/SimpleBath.shx
ex5/ArcData/SimplePonds.dbf
ex5/ArcData/SimplePonds.shp
ex5/ArcData/SimplePonds.shx
)

install(FILES ${ArcData} DESTINATION ${example_ex5_ArcDatadir})

set(Parameters
ex5/Parameters/kh_meters
ex5/Parameters/kz_meters
)

install(FILES ${Parameters} DESTINATION ${example_ex5_Parametersdir})


# ex6
#
set(example_ex6dir ${EXAMPLES_DIR}/ex6)

set(ex6
ex6/ex6.chem.dat
ex6/ex6.trans.dat
ex6/phast.dat
)

install(FILES ${ex6} DESTINATION ${example_ex6dir})


# kindred4.4
#
set(example_kindred4.4dir ${EXAMPLES_DIR}/kindred4.4)

set(kindred4.4
kindred4.4/kindred4.4.chem.dat
kindred4.4/kindred4.4.trans.dat
kindred4.4/phast.dat
)

install(FILES ${kindred4.4} DESTINATION ${example_kindred4.4dir})


# leaky
#
set(example_leakydir ${EXAMPLES_DIR}/leaky)

set(leaky
leaky/leaky.trans.dat
)

install(FILES ${leaky} DESTINATION ${example_leakydir})


# leakysurface
#
set(example_leakysurfacedir ${EXAMPLES_DIR}/leakysurface)

set(leakysurface
leakysurface/leakysurface.trans.dat
)

install(FILES ${leakysurface} DESTINATION ${example_leakysurfacedir})


# leakyx
#
set(example_leakyxdir ${EXAMPLES_DIR}/leakyx)

set(leakyx
leakyx/leakyx.trans.dat
leakyz/leakyz.trans.dat
)

install(FILES ${leakyx} DESTINATION ${example_leakyxdir})


# linear_bc
#
set(example_linear_bcdir ${EXAMPLES_DIR}/linear_bc)

set(linear_bc
linear_bc/linear_bc.chem.dat
linear_bc/linear_bc.trans.dat
linear_bc/phast.dat
)

install(FILES ${linear_bc} DESTINATION ${example_linear_bcdir})


# linear_ic
#
set(example_linear_icdir ${EXAMPLES_DIR}/linear_ic)

set(linear_ic
linear_ic/linear_ic.chem.dat
linear_ic/linear_ic.trans.dat
linear_ic/phast.dat
)

install(FILES ${linear_ic} DESTINATION ${example_linear_icdir})


# mass_balance
#
set(example_mass_balancedir ${EXAMPLES_DIR}/mass_balance)

set(mass_balance
mass_balance/mass_balance.chem.dat
mass_balance/mass_balance.trans.dat
mass_balance/phast.dat
)

install(FILES ${mass_balance} DESTINATION ${example_mass_balancedir})


# notch
#
set(example_notchdir ${EXAMPLES_DIR}/notch)

set(notch
notch/notch.trans.dat
)

install(FILES ${notch} DESTINATION ${example_notchdir})


# phrqex11
#
set(example_phrqex11dir ${EXAMPLES_DIR}/phrqex11)

set(phrqex11
phrqex11/phast.dat
phrqex11/phrqex11.chem.dat
phrqex11/phrqex11.trans.dat
)

install(FILES ${phrqex11} DESTINATION ${example_phrqex11dir})


# property
#
set(example_propertydir ${EXAMPLES_DIR}/property)

set(property
property/phast.dat
property/property.chem.dat
property/property.mix
property/property.mix.xyzt
property/property.solns
property/property.trans.dat
property/property.xyzt
)

install(FILES ${property} DESTINATION ${example_propertydir})


# radial
#
set(example_radialdir ${EXAMPLES_DIR}/radial)

set(radial
radial/phast.dat
radial/radial.chem.dat
radial/radial.head.dat
radial/radial.trans.dat
)

install(FILES ${radial} DESTINATION ${example_radialdir})


# river
#
set(example_riverdir ${EXAMPLES_DIR}/river)

set(river
river/river.trans.dat
)

install(FILES ${river} DESTINATION ${example_riverdir})


# shell
#
set(example_shelldir ${EXAMPLES_DIR}/shell)

set(shell
shell/phast.dat
shell/shell.chem.dat
shell/shell.trans.dat
)

install(FILES ${shell} DESTINATION ${example_shelldir})


# simple
#
set(example_simpledir ${EXAMPLES_DIR}/simple)

set(simple
simple/phast.dat
simple/simple.chem.dat
simple/simple.trans.dat
)

install(FILES ${simple} DESTINATION ${example_simpledir})


# unconf
#
set(example_unconfdir ${EXAMPLES_DIR}/unconf)

set(unconf
unconf/unconf.trans.dat
)

install(FILES ${unconf} DESTINATION ${example_unconfdir})


# well
#
set(example_welldir ${EXAMPLES_DIR}/well)

set(well
well/phast.dat
well/well.trans.dat
)

install(FILES ${well} DESTINATION ${example_welldir})


# zf
#
set(example_zfdir ${EXAMPLES_DIR}/zf)

set(zf
zf/phast.dat
zf/zf.chem.dat
zf/zf.subgrid.heads
zf/zf.trans.dat
)

install(FILES ${zf} DESTINATION ${example_zfdir})
