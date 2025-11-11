#include <cstring>
#include <cstdlib>
#include <iostream>

// Example file demonstrating CodeQL suppression comments

// ============================================================================
// Example 1: Suppressing unbounded write in legacy code
// ============================================================================

void legacy_string_copy(const char* source) {
    char buffer[64];
    
    // codeql [cpp/unbounded-write] - Legacy function, refactor planned Q1 2026 (TICKET-123)
    strcpy(buffer, source);
    
    std::cout << buffer << std::endl;
}

// ============================================================================
// Example 2: Suppressing dangerous function with justification
// ============================================================================

void execute_command(const char* cmd) {
    // Input validation performed by caller validate_command()
    // codeql [cpp/potentially-dangerous-function] - Command from whitelist only
    system(cmd);
}

// ============================================================================
// Example 3: Multiple suppressions on same line
// ============================================================================

void unsafe_buffer_operation() {
    char src[100] = "source data";
    char dst[50];
    
    // lgtm [cpp/unbounded-write, cpp/no-space-for-terminator] - Buffer sizes controlled by protocol
    strcpy(dst, src);
}

// ============================================================================
// Example 4: Inline suppression
// ============================================================================

char* get_static_buffer() {
    static char global_buffer[1024];
    // This looks like returning stack memory, but it's actually static
    return global_buffer;  // lgtm [cpp/return-stack-allocated-memory]
}

// ============================================================================
// Example 5: Temporary suppression with TODO
// ============================================================================

void process_user_input(char* input) {
    char buffer[256];
    
    // codeql [cpp/unbounded-write] TODO(security): Add bounds checking by 2025-12-31
    strcpy(buffer, input);
}

// ============================================================================
// Example 6: False positive suppression
// ============================================================================

int* get_heap_memory() {
    int* ptr = new int[10];
    
    // codeql [cpp/memory-leak] - Caller is responsible for cleanup (documented in API)
    return ptr;
}

// ============================================================================
// Example 7: Suppression for third-party code compatibility
// ============================================================================

void legacy_api_wrapper(const char* data) {
    // Required for compatibility with ThirdPartyLib v2.x API
    // codeql [cpp/unbounded-write] - ThirdPartyLib requires null-terminated strings
    char compat_buffer[1024];
    strcpy(compat_buffer, data);
    // third_party_function(compat_buffer);
}

// ============================================================================
// Example 8: Security-reviewed suppression
// ============================================================================

void crypto_operation(unsigned char* key, size_t key_len) {
    // Reviewed by security team 2025-11-01, approved for production
    // codeql [cpp/weak-cryptographic-algorithm] - MD5 required by RFC-compliant protocol
    // md5_hash(key, key_len);
}

// ============================================================================
// Example 9: BAD - Suppression without justification (should be flagged in audit)
// ============================================================================

void bad_suppression_example() {
    char buffer[64];
    char* input = getenv("USER_INPUT");
    
    // lgtm [cpp/unbounded-write]
    strcpy(buffer, input);  // ⚠️ No justification - will be flagged in audit
}

// ============================================================================
// Example 10: GOOD - Well-documented suppression
// ============================================================================

void good_suppression_example() {
    char buffer[64];
    
    // Suppression justified with:
    // - Ticket reference: SEC-456
    // - Reason: Performance-critical path, bounds checked by hardware constraint
    // - Reviewed: Security team, 2025-11-11
    // - Expiry: Review by 2026-Q2
    // codeql [cpp/unbounded-write]
    strcpy(buffer, get_validated_input());
}

int main() {
    std::cout << "This file demonstrates CodeQL suppression comments" << std::endl;
    std::cout << "Use: grep -n 'codeql\\|lgtm' suppression-examples.cpp" << std::endl;
    return 0;
}
