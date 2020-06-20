This target contains inconsistent behaviour between `CombineX` and Apple's `Combine`, including:

### SuspiciousBehaviour

The behaviour of `Combine` is suspicious or inconsistent with documentation. `CombineX` will not attempt to match these behaviour. 

All suspicious tests will ultimately 

1. Move to Versioning tests if Apple's `Combine` fix it. Or,
2. Move to FailingTests if Apple change its documentation, or it proves to be our fault.

### Versioning

The behaviour of `Combine` changed over time. `CombineX` follows the latest behaviour.

### FailingTests

The behaviour of `CombineX` is wrong and needs to be fixed.

### Fixed

Was failing, now fixed and consistent with `Combine`.
