#include <stdio.h>

int X;

int Y[10];

/* this is a comment */
int main(int argc, char *argv[])
{
	X = 100;
	Y[0] = 200;
	printf("%d %d\n", Y[0], X);
	return 0;
}
