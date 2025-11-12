use codeql_test_rust::*;

fn main() {
    println!("=== CodeQL Rust Test Project ===");
    println!("This program contains intentional code quality issues");
    println!("====================================");
    println!();
    
    // Example 1: Unused variables
    println!("1. Testing unused variables...");
    unused_variable_example();
    
    // Example 2: Unreachable code
    println!("\n2. Testing unreachable code...");
    let result = unreachable_code_example(true);
    println!("Result: {}", result);
    
    // Example 3: Unwrap (safe call)
    println!("\n3. Testing unwrap abuse...");
    let safe_value = unwrap_abuse_example(Some(42));
    println!("Unwrapped value: {}", safe_value);
    // Uncomment to see panic:
    // let _panic = unwrap_abuse_example(None);
    
    // Example 4: Integer operations
    println!("\n4. Testing integer overflow...");
    let sum = integer_overflow_example(100, 200);
    println!("Sum: {}", sum);
    // Uncomment to see overflow panic in debug:
    // let _overflow = integer_overflow_example(i32::MAX, 1);
    
    // Example 5: Redundant clone
    println!("\n5. Testing redundant clone...");
    let value = redundant_clone_example(42);
    println!("Cloned value: {}", value);
    
    // Example 6: Empty loop
    println!("\n6. Testing empty loop...");
    empty_loop_example();
    println!("Loop completed");
    
    // Example 7: Parse without error handling
    println!("\n7. Testing unsafe parsing...");
    let parsed = parse_number_unsafe("123");
    println!("Parsed: {}", parsed);
    // Uncomment to see panic:
    // let _bad_parse = parse_number_unsafe("not a number");
    
    // Example 8: Unsafe indexing
    println!("\n8. Testing unsafe indexing...");
    let vec = vec![1, 2, 3, 4, 5];
    let element = unsafe_indexing_example(vec, 2);
    println!("Element: {}", element);
    // Uncomment to see panic:
    // let _out_of_bounds = unsafe_indexing_example(vec![1,2,3], 10);
    
    println!("\n=== Analysis complete ===");
    println!("Run CodeQL analysis to find all the issues!");
}
