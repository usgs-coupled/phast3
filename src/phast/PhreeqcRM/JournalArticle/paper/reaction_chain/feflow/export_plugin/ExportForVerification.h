#pragma once

// Plugin implementation class
class CExportSpecies
{
public:
	CExportSpecies(IfmDocument pDoc);
	~CExportSpecies();
	static CExportSpecies* FromHandle(IfmDocument pDoc);

#pragma region IFM_Definitions
	// Implementation
public:
	void OnActivate (IfmDocument pDoc, Widget wParent);
	void PostSimulation(IfmDocument);
#pragma endregion

private:
	IfmDocument m_pDoc;
};
