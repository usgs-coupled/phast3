#if !defined(DOMAIN_H_INCLUDED)
#define DOMAIN_H_INCLUDED
#include "Cube.h"

class Domain : public Cube
{
public:
	// constructors
	Domain(void);
	Domain(const struct zone *zone_ptr);

	// destructor
	virtual ~Domain(void);

	virtual Domain *clone() const;
	virtual Domain *create() const;

	bool operator==(const Domain &other) const;
	bool operator!=(const Domain &other) const;

	void SetZone(const struct zone *zone_ptr);

protected:
	virtual void printOn(std::ostream & os) const;
};
#endif // !defined(DOMAIN_H_INCLUDED)

