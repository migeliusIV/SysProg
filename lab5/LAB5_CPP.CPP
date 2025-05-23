#include <stdio.h>
// #include <iostream.h>

//const double koef = 2.54;
void calculate() {
   double a = double(10.2);
   double koef = 2.54;
   scanf("%lf", &a);

   double res = double(10.2);
   res = a / koef;
   printf("%lf\n", res);
   // cout << "12345";
   // printf("12345\n");
   return;
}

extern"C" int main() {
    calculate();
    return 0;
}