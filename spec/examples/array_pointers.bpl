/* This outputs 0 100 */

void g( int *x ) {
	if (*x != 0)
		*x = 100;
}

void f( int a[] ) {
	g( &a[0] );
	g( &a[1] );
}

void main(void) {
	int a[2];

	a[0] = 0;
	a[1] = 1;

	f( a );

	write(a[0]);
	write(a[1]);
}
