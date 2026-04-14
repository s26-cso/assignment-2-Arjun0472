#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

int main(void) {
	char op_name[6];
	int x, y;

	// Process operations until EOF
	while (1) {
		char lib_path[16];
		void *lib;
		int (*do_op)(int, int);

		// Read operation name and two operands
		if (scanf("%5s %d %d", op_name, &x, &y) != 3) {
			break;
		}

		// Build the library filename like ./libadd.so or ./libmul.so
		snprintf(lib_path, sizeof(lib_path), "./lib%s.so", op_name);

		// Load the library at runtime using dlopen
		lib = dlopen(lib_path, RTLD_NOW);
		if (lib == NULL) {
			// If the library doesn't exist, skip and wait for the next input
			continue;
		}

		// Find the function in the library that matches the operation name
		do_op = (int (*)(int, int))dlsym(lib, op_name);
		if (do_op == NULL) {
			// If symbol not found, close library and skip
			dlclose(lib);
			continue;
		}

		// Call the operation and print the result
		printf("%d\n", do_op(x, y));
		
		// Clean up: unload the library
		dlclose(lib);
	}

	return 0;
}
