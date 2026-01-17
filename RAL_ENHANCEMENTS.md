# RAL Infrastructure Enhancements - Interview Ready

## What We Added

### 1. Register Coverage
- Added functional coverage to track register field values
- Coverage bins: zeros, ones, low range, high range
- Automatically samples on read/write operations

### 2. Enhanced Test
- Multiple test patterns: DEADBEEF, all zeros, all ones, A5A5A5A5
- Better UVM messaging with verbosity control
- Coverage enabled in build phase

### 3. Advanced Sequence
- Back-to-back writes (stress testing)
- Read-modify-write patterns
- Walking 1s pattern (bit-level verification)

## Files Modified
- tb/ral/apb_reg_block.sv - Added coverage to register class
- tb/uvm/reg_smoke_test.sv - Added more test patterns and coverage enable
- tb/uvm/reg_advanced_seq.sv - NEW: Advanced testing patterns

## Interview Talking Points

### Coverage
I implemented functional coverage on register fields to track which value ranges were exercised during testing.

### Test Patterns
I used multiple test patterns including walking 1s to verify individual bit functionality and catch stuck-at faults.

### UVM Best Practices
I used proper UVM reporting macros with verbosity levels instead of dollar display for controllable debug output.

## Running Tests
make test
