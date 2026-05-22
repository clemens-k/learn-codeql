#include "vulnerable.h"
#include <cstring>
#include <cstdlib>
#include <iostream>

/* testing the fingerprinting :-D */

// CWE-120: Buffer overflow vulnerability
void buffer_overflow_example(const char* input) {
    char buffer[10];
    // VULNERABLE: No bounds checking!
    strcpy(buffer, input);
    std::cout << "Buffer contains: " << buffer << std::endl;
}

// CWE-476: NULL pointer dereference
void null_pointer_example(int* ptr) {
    // VULNERABLE: No null check!
    *ptr = 42;
    std::cout << "Value set to: " << *ptr << std::endl;
}

// CWE-401: Memory leak
void memory_leak_example() {
    int* data = new int[100];
    // VULNERABLE: Memory allocated but never freed!
    data[0] = 123;
    std::cout << "First element: " << data[0] << std::endl;
    // Missing: delete[] data;
}

// CWE-416: Use after free
void use_after_free_example() {
    int* ptr = new int(42);
    delete ptr;
    // VULNERABLE: Using freed memory!
    std::cout << "Freed value: " << *ptr << std::endl;
}

// CWE-190: Integer overflow
void integer_overflow_example(int a, int b) {
    // VULNERABLE: No overflow check!
    int result = a + b;
    std::cout << "Result: " << result << std::endl;
}

// CWE-78: OS Command Injection
void command_injection_example(const std::string& filename) {
    // VULNERABLE: User input directly in system call!
    std::string command = "cat " + filename;
    system(command.c_str());
}
