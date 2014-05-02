void main(void) {
	int x; /* offset: -8 */
	int y; /* offset: -16 */
	int z; /* offset: -24 */

	x = 5;
	y = 7;
	z = x + y;

	write(x);
	write(y);
	write(z);
	writeln();
}
