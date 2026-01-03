#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "ABI.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	assert(alternate_sum_4_using_c(8, 2, 5, 1) == 10);

	assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 10);
	assert(alternate_sum_8(8, 2, 5, 1, 7, 3, 6, 4) == 16);
	
	double result = 0.0;
	
	product_9_f(&result, 2, 1.5f,   // x1=2, f1=1.5
                3, 2.0f,   // x2=3, f2=2.0
                1, 1.0f,   // x3=1, f3=1.0
                1, 1.0f,   // x4=1, f4=1.0
                1, 1.0f,   // x5=1, f5=1.0
                1, 1.0f,   // x6=1, f6=1.0
                1, 1.0f,   // x7=1, f7=1.0
                1, 1.0f,   // x8=1, f8=1.0
                1, 1.0f);  // x9=1, f9=1.0
	assert(result == 18.000000);
	return 0;
}
