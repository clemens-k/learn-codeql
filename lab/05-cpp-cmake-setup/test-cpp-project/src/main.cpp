#include <iostream>
#include "vulnerable.h"

int main(int argc, char* argv[]) {
    std::cout << "=== CodeQL C++ Test Project ===" << std::endl;
    std::cout << "This program contains intentional vulnerabilities"
              << std::endl;
    std::cout << "================================" << std::endl;
    std::cout << std::endl;
    
    // Example 1: Buffer overflow
    std::cout << "1. Testing buffer overflow..." << std::endl;
    buffer_overflow_example("Short");  // Safe
    // buffer_overflow_example("This is way too long!");  // Unsafe
    
    // Example 2: Null pointer
    std::cout << "\n2. Testing null pointer..." << std::endl;
    int value = 10;
    null_pointer_example(&value);  // Safe
    // null_pointer_example(nullptr);  // Unsafe - commented for safety
    
    // Example 3: Memory leak
    std::cout << "\n3. Testing memory leak..." << std::endl;
    memory_leak_example();
    
    // Example 4: Use after free (commented out for safety)
    // std::cout << "\n4. Testing use after free..." << std::endl;
    // use_after_free_example();
    
    // Example 5: Integer overflow
    std::cout << "\n4. Testing integer overflow..." << std::endl;
    integer_overflow_example(2147483647, 1);  // Max int + 1
    
    // Example 6: Command injection (commented for safety)
    // std::cout << "\n6. Testing command injection..." << std::endl;
    // command_injection_example("/etc/hosts");
    
    std::cout << "\n=== Analysis complete ===" << std::endl;
    std::cout << "Run CodeQL analysis to find the vulnerabilities!"
              << std::endl;
    
    return 0;
}
