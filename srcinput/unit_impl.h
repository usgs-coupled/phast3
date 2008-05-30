#if !defined(CUNIT_H_INCLUDED)
#define CUNIT_H_INCLUDED
struct cunit {
	char *input;
	char *si;
	double input_to_si;
/*	double si_to_user; */
	double input_to_user;
	int defined;

// Constructors
	cunit(void);
	cunit(const char* si);
	~cunit(void);
	cunit(const cunit& src);
// Assignment Operators
	cunit& operator=(const cunit& src);
// Utilities
	int set_input(const char* input);
	void define(const char* input);
	void undefine(void);
	const char* c_str(void)const;
};
#endif // !defined(CUNIT_H_INCLUDED)
