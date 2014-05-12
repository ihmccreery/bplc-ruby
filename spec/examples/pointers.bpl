/* This outputs 23 */

void f( int *x ) {
	if (*x == 4)
		*x = 23;
	else
		*x = 55;
}

void main(void) {
	int a;
	int *b;
	b = &a;
	a = 4;
	f( b );
	write(a);
}
