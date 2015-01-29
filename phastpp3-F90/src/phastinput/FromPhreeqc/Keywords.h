#ifndef _INC_KEYWORDS_H
#define _INC_KEYWORDS_H
#include <string>
#include <map>
class Keywords
{
public:
		enum KEYWORDS
	{
		KEY_NONE,
		KEY_EOF,
		KEY_END,
		KEY_TITLE,
		KEY_GRID,
		KEY_MEDIA,
		KEY_HEAD_IC,
		KEY_CHEMISTRY_IC,
		KEY_FREE_SURFACE_BC,
		KEY_SPECIFIED_HEAD_BC,
		KEY_FLUX_BC,
		KEY_LEAKY_BC,
		KEY_UNITS,
		KEY_SOLUTION_METHOD,
		KEY_TIME_CONTROL,
		KEY_PRINT_FREQUENCY,
		KEY_PRINT_INITIAL,
		KEY_RIVER,
		KEY_WELL,
		KEY_PRINT_LOCATIONS,
		KEY_STEADY_FLOW,
		KEY_SOLUTE_TRANSPORT,
		KEY_DRAIN,
		KEY_ZONE_FLOW,
		KEY_COUNT_KEYWORDS // MUST BE LAST in list
	};

	Keywords(void);
	~Keywords(void);

	static KEYWORDS Keyword_search(std::string key);
	static const std::string & Keyword_name_search(KEYWORDS key);

	static const std::map<const std::string, KEYWORDS> phast_keywords;
	static const std::map<KEYWORDS, const std::string> phast_keyword_names;
};

#endif // _INC_KEYWORDS_H