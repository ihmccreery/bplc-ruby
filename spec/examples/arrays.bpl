void main(void) {
	int i;
	int a[5];

	i = 0;
	while(i < 5) {
		a[i] = i;
		i = i + 1;
	}	

	i = 0;
	while(i < 5) {
		write(a[i]);
		i = i + 1;
	}
}
