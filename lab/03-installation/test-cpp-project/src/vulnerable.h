#ifndef VULNERABLE_H
#define VULNERABLE_H

#include <string>

// Vulnerable function declarations
void buffer_overflow_example(const char* input);
void null_pointer_example(int* ptr);
void memory_leak_example();
void use_after_free_example();
void integer_overflow_example(int a, int b);
void command_injection_example(const std::string& filename);

#endif // VULNERABLE_H
