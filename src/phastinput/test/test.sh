#!/bin/sh

# uncomment the following line to display commands
# set -x

echo Testing no args
../phastinput 2> /dev/null
if [ $? ]; then
    echo PASSED
else
    echo FAILED expected !0 got $? 
fi

echo Testing all args given
cp ../../examples/ex4/ex4.trans.dat .
cp ../../examples/ex4/ex4.chem.dat .
cp ../../examples/ex4/phast.dat .
../phastinput ex4 phast.dat 2> /dev/null
if [ $? -ne 0 ]; then
    echo FAILED
else
    echo PASSED
fi

echo Testing missing trans.dat file
../phastinput missing phast.dat 2> /dev/null
if [ $? -eq 0 ]; then
    echo FAILED
else
    echo PASSED
fi

echo Testing missing chem.dat file
rm -f ex4.chem.dat
../phastinput ex4 phast.dat 2> /dev/null
if [ $? -eq 0 ]; then
    echo FAILED
else
    echo PASSED
fi

echo Testing missing phast.dat file
cp ../../examples/ex4/ex4.trans.dat .
cp ../../examples/ex4/ex4.chem.dat .
rm -f phast.dat
../phastinput ex4 phast.dat 2> /dev/null
if [ $? -eq 0 ]; then
    echo FAILED
else
    echo PASSED
fi

echo Testing missing phast.dat file 2
cp ../../examples/ex4/ex4.trans.dat .
cp ../../examples/ex4/ex4.chem.dat .
rm -f phast.dat
../phastinput ex4 2> /dev/null
if [ $? -eq 0 ]; then
    echo FAILED
else
    echo PASSED
fi

##echo "Testing FLOW_ONLY true (no chem.dat or phast.dat)"
echo "Testing SOLUTE_TRANSPORT false (no chem.dat or phast.dat)"
cp ../../examples/well/well.trans.dat .
rm -f phast.dat well.chem.dat
../phastinput well 2> /dev/null
if [ $? -ne 0 ]; then
    echo FAILED
else
    echo PASSED
fi

##echo "Testing FLOW_ONLY false (chem.dat req'd)"
echo "Testing SOLUTE_TRANSPORT true (chem.dat req'd)"
grep -v SOLUTE_TRANSPORT ../../examples/well/well.trans.dat > well.trans.dat
rm -f phast.dat well.chem.dat
../phastinput well 2> /dev/null
if [ $? -eq 0 ]; then
    echo FAILED
else
    echo PASSED
fi

# clean up
rm -f *.log *.phastinput.echo *.phastinput.error *.trans.dat *.chem.dat Phast.tmp
