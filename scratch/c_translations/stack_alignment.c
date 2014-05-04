#include <stdio.h>

int f(int n) {
	return n * n;
}

int main(int argc, char *argv[])
{
	int x;
	x = (f(2) + f(3)) * f(4);
	printf("%d\n", x);
	return 0;
}
