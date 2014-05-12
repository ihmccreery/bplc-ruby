/* prints "hello 55 " */

int X;
string Y;

void set_x(int x) {
	X = x;
}

void set_y(string y) {
	Y = y;
}

void main(void) {
	set_x(55);
	set_y("hello");
	write(Y);
	write(X);
}
