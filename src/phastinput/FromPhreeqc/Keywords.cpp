#include "Keywords.h"


Keywords::Keywords(void)
{
}


Keywords::~Keywords(void)
{
}

Keywords::KEYWORDS Keywords::Keyword_search(std::string key)
{
	std::map<const std::string, Keywords::KEYWORDS>::const_iterator it;
	it = phast_keywords.find(key);
	if (it != Keywords::phast_keywords.end())
	{
		return it->second;
	}
	return Keywords::KEY_NONE;
}

const std::string & Keywords::Keyword_name_search(Keywords::KEYWORDS key)
{
	std::map<Keywords::KEYWORDS, const std::string>::const_iterator it;
	it = phast_keyword_names.find(key);
	if (it != Keywords::phast_keyword_names.end())
	{
		return it->second;
	}
	it = phast_keyword_names.find(KEY_NONE);
	return it->second;
}

const std::map<const std::string, Keywords::KEYWORDS>::value_type temp_keywords[] = {
std::map<const std::string, Keywords::KEYWORDS>::value_type("eof",							Keywords::KEY_END),
std::map<const std::string, Keywords::KEYWORDS>::value_type("end", 							Keywords::KEY_END),
std::map<const std::string, Keywords::KEYWORDS>::value_type("title", 			            Keywords::KEY_TITLE),
std::map<const std::string, Keywords::KEYWORDS>::value_type("comment", 		                Keywords::KEY_TITLE),
std::map<const std::string, Keywords::KEYWORDS>::value_type("grid", 					    Keywords::KEY_GRID),
std::map<const std::string, Keywords::KEYWORDS>::value_type("media", 						Keywords::KEY_MEDIA),
std::map<const std::string, Keywords::KEYWORDS>::value_type("head_ic", 					    Keywords::KEY_HEAD_IC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("chemistry_ic", 				Keywords::KEY_CHEMISTRY_IC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("free_surface_bc", 				Keywords::KEY_FREE_SURFACE_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("specified_value_bc", 			Keywords::KEY_SPECIFIED_HEAD_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("specified_bc", 				Keywords::KEY_SPECIFIED_HEAD_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("flux_bc", 						Keywords::KEY_FLUX_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("leaky_bc", 					Keywords::KEY_LEAKY_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("units", 						Keywords::KEY_UNITS),
std::map<const std::string, Keywords::KEYWORDS>::value_type("solution_method", 				Keywords::KEY_SOLUTION_METHOD),
std::map<const std::string, Keywords::KEYWORDS>::value_type("time_control", 				Keywords::KEY_TIME_CONTROL),
std::map<const std::string, Keywords::KEYWORDS>::value_type("print_frequency", 				Keywords::KEY_PRINT_FREQUENCY),
std::map<const std::string, Keywords::KEYWORDS>::value_type("print_input", 					Keywords::KEY_PRINT_INITIAL),
std::map<const std::string, Keywords::KEYWORDS>::value_type("free_surface", 				Keywords::KEY_FREE_SURFACE_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("rivers", 						Keywords::KEY_RIVER),
std::map<const std::string, Keywords::KEYWORDS>::value_type("river", 						Keywords::KEY_RIVER),
std::map<const std::string, Keywords::KEYWORDS>::value_type("wells", 						Keywords::KEY_WELL),
std::map<const std::string, Keywords::KEYWORDS>::value_type("well", 						Keywords::KEY_WELL),
std::map<const std::string, Keywords::KEYWORDS>::value_type("print_locations", 				Keywords::KEY_PRINT_LOCATIONS),
std::map<const std::string, Keywords::KEYWORDS>::value_type("print_location", 				Keywords::KEY_PRINT_LOCATIONS),
std::map<const std::string, Keywords::KEYWORDS>::value_type("steady_flow", 					Keywords::KEY_STEADY_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("steady_state_flow", 			Keywords::KEY_STEADY_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("print_initial", 				Keywords::KEY_PRINT_INITIAL),
std::map<const std::string, Keywords::KEYWORDS>::value_type("solute_transport", 			Keywords::KEY_SOLUTE_TRANSPORT),
std::map<const std::string, Keywords::KEYWORDS>::value_type("specified_head_bc", 			Keywords::KEY_SPECIFIED_HEAD_BC),
std::map<const std::string, Keywords::KEYWORDS>::value_type("drain", 						Keywords::KEY_DRAIN),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_budget", 					Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flow_rate", 				Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flow_rates", 				Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flowrate", 				Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flowrates", 				Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flow", 					Keywords::KEY_ZONE_FLOW),
std::map<const std::string, Keywords::KEYWORDS>::value_type("zone_flows", 					Keywords::KEY_ZONE_FLOW)
};
const std::map<const std::string, Keywords::KEYWORDS> Keywords::phast_keywords(temp_keywords, temp_keywords + sizeof temp_keywords / sizeof temp_keywords[0]);

const std::map<Keywords::KEYWORDS, std::string>::value_type temp_keyword_names[] = {
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_NONE,							"UNKNOWN"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_END,							"END"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_TITLE,						"TITLE"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_GRID,							"GRID"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_MEDIA,						"MEDIA"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_HEAD_IC,						"HEAD_IC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_CHEMISTRY_IC,					"CHEMISTRY_IC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_FREE_SURFACE_BC,				"FREE_SURFACE_BC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_SPECIFIED_HEAD_BC,			"SPECIFIED_HEAD_BC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_FLUX_BC,						"FLUX_BC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_LEAKY_BC,						"LEAKY_BC"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_UNITS,						"UNITS"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_SOLUTION_METHOD,				"SOLUTION_METHOD"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_TIME_CONTROL,					"TIME_CONTROL"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_PRINT_FREQUENCY,				"PRINT_FREQUENCY"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_PRINT_INITIAL,				"PRINT_INITIAL"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_RIVER,						"RIVER"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_WELL,							"WELL"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_PRINT_LOCATIONS,				"PRINT_LOCATIONS"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_STEADY_FLOW,					"STEADY_FLOW"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_SOLUTE_TRANSPORT,				"SOLUTE_TRANSPORT"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_DRAIN,						"DRAIN"),
std::map<Keywords::KEYWORDS, const std::string>::value_type(Keywords::KEY_ZONE_FLOW,					"ZONE_FLOW")	
};
const std::map<Keywords::KEYWORDS, const std::string> Keywords::phast_keyword_names(temp_keyword_names, temp_keyword_names + sizeof temp_keyword_names / sizeof temp_keyword_names[0]);
