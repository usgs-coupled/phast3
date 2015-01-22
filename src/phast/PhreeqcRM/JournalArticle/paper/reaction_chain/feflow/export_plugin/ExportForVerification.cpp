#include "stdifm.h"
#include "ExportForVerification.h"
#include <fstream>
#include <string>
#include <set>
using namespace std;


IfmModule g_pMod;  /* Global handle related to this plugin */

#pragma region IFM_Definitions
/* --- IFMREG_BEGIN --- */
/*  -- Do not edit! --  */

static IfmResult OnBeginDocument(IfmDocument);
static void OnEndDocument(IfmDocument);
static void OnActivate(IfmDocument, Widget);
static void PostSimulation(IfmDocument);

/*
 * Enter a short description between the quotation marks in the following lines:
 */
static const char szDesc[] =
"Please, insert a plug-in description here!";

#ifdef __cplusplus
extern "C"
#endif /* __cplusplus */

IfmResult RegisterModule(IfmModule pMod)
{
	if (IfmGetFeflowVersion(pMod) < IFM_REQUIRED_VERSION)
		return False;
	g_pMod = pMod;
	IfmRegisterModule(pMod, "SIMULATION", "EXPORT_SPECIES", "ExportForVerification", 0x1000);
	IfmSetDescriptionString(pMod, szDesc);
	IfmSetCopyrightPath(pMod, "ExportForVerification.txt");
	IfmSetHtmlPage(pMod, "ExportForVerification.htm");
	IfmSetPrimarySource(pMod, "ExportForVerification.cpp");
	IfmRegisterProc(pMod, "OnBeginDocument", 1, (IfmProc)OnBeginDocument);
	IfmRegisterProc(pMod, "OnEndDocument", 1, (IfmProc)OnEndDocument);
	IfmRegisterProc(pMod, "OnActivate", 1, (IfmProc)OnActivate);
	IfmRegisterProc(pMod, "PostSimulation", 1, (IfmProc)PostSimulation);
	return True;
}

static void OnActivate(IfmDocument pDoc, Widget button)
{
	CExportSpecies::FromHandle(pDoc)->OnActivate(pDoc, button);
}
static void PostSimulation(IfmDocument pDoc)
{
	CExportSpecies::FromHandle(pDoc)->PostSimulation(pDoc);
}

/* --- IFMREG_END --- */
#pragma endregion


static IfmResult OnBeginDocument(IfmDocument pDoc)
{
	if (IfmDocumentVersion(pDoc) < IFM_CURRENT_DOCUMENT_VERSION)
		return false;

	try {
		IfmDocumentSetUserData(pDoc, new CExportSpecies(pDoc));
	}
	catch (...) {
		return false;
	}

	return true;
}

static void OnEndDocument(IfmDocument pDoc)
{
	delete CExportSpecies::FromHandle(pDoc);
}

///////////////////////////////////////////////////////////////////////////
// Implementation of CExportSpecies

// Constructor
CExportSpecies::CExportSpecies(IfmDocument pDoc)
: m_pDoc(pDoc)
{
	/*
	 * TODO: Add your own code here ...
	 */
}

// Destructor
CExportSpecies::~CExportSpecies()
{
	/*
	 * TODO: Add your own code here ...
	 */
}

// Obtaining class instance from document handle
CExportSpecies* CExportSpecies::FromHandle(IfmDocument pDoc)
{
	return reinterpret_cast<CExportSpecies*>(IfmDocumentGetUserData(pDoc));
}

// Callbacks
void CExportSpecies::OnActivate(IfmDocument pDoc, Widget button)
{
	IfmInfo(pDoc, "Export started...");
	double x;
	double y;
	double z;
	const int speciesNo = IfmGetNumberOfSpecies(pDoc);
	double yExtent = IfmGetY(pDoc, 0);
	double zExtent = IfmGetZ(pDoc, 0);
	set<pair<double,double>> xyNodeCoords;
	set<double> zNodeCoords;
	ofstream xyFile(string(IfmGetFileDirectory(pDoc, IfmGetProblemPath(pDoc))) + "feflow_xy.dat");
	ofstream xzFile(string(IfmGetFileDirectory(pDoc, IfmGetProblemPath(pDoc))) + "feflow_xz.dat");

	// Get extent
	for (int i = 0; i < IfmGetNumberOfNodes(pDoc); ++i)
	{
		if (IfmGetY(pDoc, i) > yExtent)
			yExtent = IfmGetY(pDoc, i);
		if (IfmGetZ(pDoc, i) > zExtent)
			zExtent = IfmGetZ(pDoc, i);
	}

	// Check if files can be openend
	if (!xyFile.is_open() || !xzFile.is_open())
	{
		IfmWarning(pDoc, "Failed to open files for export.");
		IfmWarning(pDoc, IfmGetProblemPath(pDoc));
		return;
	}

	// Create headings
	string heading("ID\tx\ty\tz");
	for (int i = 0; i < speciesNo; ++i)
		heading += ('\t' + string(IfmGetSpeciesName(pDoc, i)));
	char buffer[1024];
	for (int i = 0; i < IfmGetNumberOfNodalRefDistr(pDoc); ++i)
	{
		IfmGetNodalRefDistrName(pDoc, i, buffer);
		heading += ('\t' + string(buffer));
	}
	xyFile << heading << endl;
	xzFile << heading << endl;

	for (int i = 0; i < IfmGetNumberOfNodes(pDoc); ++i)
	{
		x = IfmGetX(pDoc, i);
		y = IfmGetY(pDoc, i);
		z = IfmGetZ(pDoc, i);

		if (y < 0.01)
		{
			xzFile << i << '\t' << x << '\t' << y << '\t' << z;
			for (int j = 0; j < speciesNo; ++j)
			{
				IfmSetMultiSpeciesId(pDoc, j);
				xzFile << '\t' << IfmGetResultsTransportMassValue(pDoc, i);
			}
			for (int j = 0; j < IfmGetNumberOfNodalRefDistr(pDoc); ++j)
				xzFile << '\t' << IfmGetNodalRefDistrValue(pDoc, j, i);
			xzFile << endl;
		}
		if (z < 0.01)
		{
			xyFile << i << '\t' << x << '\t' << y << '\t' << z;
			for (int j = 0; j < speciesNo; ++j)
			{
				IfmSetMultiSpeciesId(pDoc, j);
				xyFile << '\t' << IfmGetResultsTransportMassValue(pDoc, i);
			}
			for (int j = 0; j < IfmGetNumberOfNodalRefDistr(pDoc); ++j)
				xyFile << '\t' << IfmGetNodalRefDistrValue(pDoc, j, i);
			xyFile << endl;
		}
	}
	
	// Close files
	xyFile.close();
	xzFile.close();
	IfmInfo(pDoc, "Export finished!");
}

void CExportSpecies::PostSimulation(IfmDocument pDoc)
{
	OnActivate(pDoc, NULL);
}

