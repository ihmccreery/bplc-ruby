// this should print 0, not 5.

#include <stdio.h>

int *X;

void f(void)
{
	int x;
	x = 0;
	x = x + x;
}

void set_X(void)
{
	int x;
	x = 5;
	X = &x;
}

int main(int argc, char *argv[])
{
	set_X();
	f();
	printf("%d\n", *X);
}
