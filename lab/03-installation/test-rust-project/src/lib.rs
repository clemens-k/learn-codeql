// Intentionally problematic code for CodeQL to analyze

#![allow(dead_code)]

/// Unused variable example
pub fn unused_variable_example() {
    let x = 42; // Variable declared but never used
    let y = 10;
    println!("Y is: {}", y);
    // x is never used!
}

/// Unreachable code example
pub fn unreachable_code_example(condition: bool) -> i32 {
    if condition {
        return 42;
    } else {
        return 0;
    }
    
    // This code is unreachable!
    #[allow(unreachable_code)]
    {
        println!("This will never print");
        return -1;
    }
}

/// Unwrap abuse - can panic!
pub fn unwrap_abuse_example(input: Option<i32>) -> i32 {
    // PROBLEMATIC: unwrap can panic if None
    input.unwrap()
}

/// Integer overflow in debug mode
pub fn integer_overflow_example(a: i32, b: i32) -> i32 {
    // Can panic in debug mode on overflow
    a + b
}

/// Redundant clone
pub fn redundant_clone_example(x: i32) -> i32 {
    // i32 is Copy, no need to clone
    let y = x.clone();
    y
}

/// Empty loop - potential infinite loop or logic error
pub fn empty_loop_example() {
    let mut _count = 0;
    loop {
        // Empty loop body - likely a bug!
        break; // Added break to prevent actual infinite loop
    }
}

/// Result unwrap without error handling
pub fn parse_number_unsafe(s: &str) -> i32 {
    // PROBLEMATIC: parse can fail, unwrap will panic
    s.parse::<i32>().unwrap()
}

/// Double unwrap - even worse!
pub fn double_unwrap_example(opt: Option<Option<i32>>) -> i32 {
    opt.unwrap().unwrap()
}

/// Using panic directly
pub fn explicit_panic_example(condition: bool) {
    if condition {
        panic!("Something went wrong!");
    }
}

/// Index out of bounds potential
pub fn unsafe_indexing_example(vec: Vec<i32>, index: usize) -> i32 {
    // PROBLEMATIC: No bounds check, can panic
    vec[index]
}
