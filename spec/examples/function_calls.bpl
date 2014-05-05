int f(int x) {
	write(x);
	write("times two");
	return 2*x;
}

int g(int x, int y) {
	write(x);
	write("times");
	write(y);
	return x*y;
}

void main(void) {
	int x;
	write(f(5));
	x = g(3, 4) * 2;
	write("times two again");
	write(x);
}
