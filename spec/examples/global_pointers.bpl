int *X;
string *S;

void set_x(int *x) {
	X = x;
}

void set_s(string *s) {
	S = s;
}

void main(void) {
	int x;
	string s;

	set_x(&x);
	set_s(&s);

	x = 1;
	s = "hello";

	write(*X);
	write(*S);

	x = 2;
	s = "goodbye";

	write(*X);
	write(*S);
}
