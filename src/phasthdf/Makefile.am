if BUILD_PHASTHDF

bin_SCRIPTS = phasthdf
CLEANFILES = $(bin_SCRIPTS)

do_subst = sed -e 's,[@]pkglibdir[@],$(pkglibdir),g'

phasthdf: $(srcdir)/phasthdf.in Makefile
	$(do_subst) < $(srcdir)/phasthdf.in > phasthdf
	chmod +x phasthdf

pkglib_DATA = \
	dist/jhdf5.jar \
	dist/jhdf5obj.jar \
	dist/jhdf.jar \
	dist/jhdfobj.jar \
	dist/Linux/libjh5srb.so \
	dist/Linux/libjhdf5.so \
	dist/Linux/libjhdf.so \
	dist/phast.jar

$(pkglib_DATA):
	$(ANT) -Dsrcdir=@srcdir@ dist-Linux

clean-local:
	$(ANT) -Dsrcdir=@srcdir@ clean

endif

EXTRA_DIST = \
	hdf-java/linux/hdf-java-2.3.jar \
	hdf-java/solaris/hdf-java-2.3.jar \
	hdf-java/win/hdf-java-2.3.jar \
	src/corejava/Format.java \
	src/gov/usgs/phast/JCheckList.java \
	src/gov/usgs/phast/JMalformedHDFException.java \
	src/gov/usgs/phast/IProgressMonitor.java \
	src/gov/usgs/phast/JPage2Tab.form \
	src/gov/usgs/phast/JPage1.form \
	src/gov/usgs/phast/JPage1.java \
	src/gov/usgs/phast/JPage2.form \
	src/gov/usgs/phast/JPage2.java \
	src/gov/usgs/phast/JWizardFrame.java \
	src/gov/usgs/phast/JPage2Tab.java \
	src/gov/usgs/phast/JPage3.form \
	src/gov/usgs/phast/JPage3.java \
	src/gov/usgs/phast/ModalProgressMonitor.java \
	src/gov/usgs/phast/JWizardPanel.form \
	src/gov/usgs/phast/JWizardPanel.java \
	src/gov/usgs/phast/PhastH5File.java \
	src/gov/usgs/Splash.java \
	src/images/splash.jpeg \
	src/sample/SwingWorker.java \
	test/corejava/FormatTest.java \
	test/corejava/CorejavaSuite.java \
	test/gov/usgs/phast/JPage1Test.java \
	test/gov/usgs/phast/JWizardFrameTest.java \
	test/gov/usgs/phast/JCheckListTest.java \
	test/gov/usgs/phast/JPage2TabTest.java \
	test/gov/usgs/phast/JPage2Test.java \
	test/gov/usgs/phast/JPage3Test.java \
	test/gov/usgs/phast/JPhastHDFTest.java \
	test/gov/usgs/phast/ModalProgressMonitorTest.java \
	test/gov/usgs/phast/JWizardPanelTest.java \
	test/gov/usgs/phast/PhastH5FileTest.java \
	test/gov/usgs/phast/PhastSuite.java \
	test/gov/usgs/UsgsSuite.java \
	test/gov/GovSuite.java
