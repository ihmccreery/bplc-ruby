int square(int x) {
	return x * x;
}

int mod_eight_if_mod_ten(int x) {
	int z;
	if (x % 10 == 0) {
		int y;
		y = 8;
		z = x % 8;
	} else {
		int w;
		w = x;
		z = w;
	}
	return z;
}

int times_two(int x) {
	int y;
	int z;
	y = 2;
	z = x * y;
	return z;
}

void main(void) {
	int a;
	int b;
	string hello;

	a = 5;
	b = 10;

	write(square(a));
	write(mod_eight_if_mod_ten(a));
	write(times_two(a));

	write(square(b));
	write(mod_eight_if_mod_ten(b));
	write(times_two(b));

	hello = "hello!";

	write(hello);
}

/* ... */
