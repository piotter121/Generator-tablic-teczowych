#ifndef _REDUCTION_FUNCTION_H
#define _REDUCTION_FUNCTION_H

#include "table_row.h"

__global__ void reduction(char **, char **);

void reduct_rows(char **, char **, int);

#endif
