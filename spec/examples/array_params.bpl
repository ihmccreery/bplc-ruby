void write_and_add_ints(int a[], int size) {
	int i;

	i = 0;
	while(i < size) {
		write(a[i]);
		a[i] = a[i] + 5;
		i = i + 1;
	}
}

void write_and_modify_strings(string s[], int size) {
	int i;

	i = 0;
	while(i < size) {
		write(s[i]);
		s[i] = "hello";
		i = i + 1;
	}
}

void main(void) {
	int i;
	int a[5];
	string s[5];

	i = 0;
	while(i < 5) {
		a[i] = i;
		i = i + 1;
	}

	write_and_add_ints(a, 5);

	s[0] = "zero";
	s[1] = "one";
	s[2] = "two";
	s[3] = "three";
	s[4] = "four";

	write_and_modify_strings(s, 5);

	i = 0;
	while(i < 5) {
		write(a[i]);
		write(s[i]);
		i = i + 1;
	}
}
