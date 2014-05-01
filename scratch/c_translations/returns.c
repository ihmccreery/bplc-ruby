#include <stdio.h>

int f(int n) {
	if(n == 0)
		return 1;
	else
		return n * f(n-1);
}

int main(int argc, char *argv[])
{
	printf("%d\n", f(5));
	return 0;
}
