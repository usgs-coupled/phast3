#ifndef _INC_GENERIC_H
#define _INC_GENERIC_H


int output_open(const int type, const char *file_name);
int output_fflush(const int type);
void output_rewind(const int type);
int output_close(const int type);


#endif /* _INC_GENERIC_H */
