/* writes "0 3 5 hello maybe goodbye " */
int X[5];
string S[5];

int SIZE;

void set_x_three_to_three(void) {
	X[3] = 3;
}

void set_s_three_to_maybe(void) {
	S[3] = "maybe";
}

void set_to_five(int *x) {
	*x = 5;
}

void set_to_goodbye(string *s) {
	*s = "goodbye";
}

void main(void) {
	int i;

	SIZE = 5;

	i = 0;
	while(i < SIZE) {
		X[i] = 0;
		S[i] = "hello";
		i = i + 1;
	}

	set_x_three_to_three();
	set_s_three_to_maybe();
	set_to_five(&X[4]);
	set_to_goodbye(&S[4]);

	write(X[2]);
	write(X[3]);
	write(X[4]);
	write(S[2]);
	write(S[3]);
	write(S[4]);
}
