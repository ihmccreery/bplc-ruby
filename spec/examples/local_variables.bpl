int f(int x) {
	int y;
	write(x);
	write("times two");
	return 2*x;
}

int g(int x, int y) {
	int z;
	int w;
	write(x);
	write("times");
	write(y);
	return x*y;
}

void main(void) {
	write(f(5));
	write(g(3, 4));
}
