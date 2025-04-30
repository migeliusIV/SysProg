 #include <iostream.h>
 #include <iomanip.h>

 const double koef = 2.54;

 extern "C" {
	void calculate() {
		double a = 0;
		double res = 0;
		cin >> a;
		res = a / koef;
		cout << setprecision(2) << res << endl;
	}
 }

 int main(){
	calculate();
	return 0;
 }