/* A program to sort and output. */

void switch (int A[], int i, int j) {
	int temp;
	if (i != j) {
		temp = A[i];
		A[i] = A[j];
		A[j] = temp;
	}
}

void sort( int A[], int first, int last ) {
	int i;
	int j;
	int small;

	i = first;
	while (i < last-1) {
		/* gets smallest remaining value and put it at position i */
		j = i;
		small = j;
		while (j < last) {
			if (A[j] < A[small])
				small = j;
			j = j+1;
		}
		switch(A, i, small);
		i = i + 1;
	}
}

void main(void) {
	int x[10];

	int i;

	x[0] = 8;
	x[1] = 7;
	x[2] = 2;
	x[3] = 0;
	x[4] = 9;
	x[5] = 1;
	x[6] = 5;
	x[7] = 6;
	x[8] = 3;
	x[9] = 4;

	sort(x, 0, 10);

	i = 0;
	while (i < 10) {
		write(x[i]);
		i = i + 1;
	}
}
