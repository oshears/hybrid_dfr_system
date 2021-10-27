#include <stdio.h>
#include <stdlib.h>
#include <cmath>

#include "dfr.h"

//mackey glass function
float mackey_glass(float x){

    // float C = 1.33;
    // float b = 0.4;
    // return (C * x) / (1 + b * x);

    float C = 2;
    float b = 2.1;
    float p = 10;

    float a = 0.8;
    float c = 0.2;

    return (C * x) / (a + c * pow(b * x, p) );

}