int fact(int n) {
	if(n == 0) {
		return 1;
	} else {
		return n * fact(n-1);
	}
}

void main(void) {
	int i;
	i = 0;

	while(i <= 5) {
		write(fact(i));
		i = i + 1;
	}	
}
