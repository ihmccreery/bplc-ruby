void main(void) {
	int i;
	int a[5];
	string s[5];

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

	s[0] = "zero";
	s[1] = "one";
	s[2] = "two";
	s[3] = "three";
	s[4] = "four";

	i = 0;
	while(i < 5) {
		write(s[i]);
		i = i + 1;
	}
}
