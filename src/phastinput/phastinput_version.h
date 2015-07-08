#define PHAST_VER_MAJOR      2
#define PHAST_VER_MINOR      2
#define PHAST_VER_PATCH      1  
#define PHAST_VER_REVISION   6485

#define RELEASE_DATE           "April 17, 2012"

#define APR_STRINGIFY(n) APR_STRINGIFY_HELPER(n)
#define APR_STRINGIFY_HELPER(n) #n

/** Version number */
#define PHAST_VER_NUM        APR_STRINGIFY(PHAST_VER_MAJOR) \
                           "." APR_STRINGIFY(PHAST_VER_MINOR) \
                           "." APR_STRINGIFY(PHAST_VER_PATCH) \
                           "." APR_STRINGIFY(PHAST_VER_REVISION)



#define PRODUCT_NAME       "PHAST" \
                       "-" APR_STRINGIFY(PHAST_VER_MAJOR) \
                       "." APR_STRINGIFY(PHAST_VER_MINOR)
