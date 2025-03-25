# AI Assistant Instructions for this project

## Understanding Crystal Macros

### Fundamental Concepts

1. **Macros Generate Code**: Crystal macros are code that writes code. They are evaluated at compile time, not runtime.

2. **Two-Phase Evaluation**: When reading macro code, you must mentally separate:
   - The macro code itself (which runs at compile time)
   - The resulting Crystal code that will be generated (which runs at runtime)

3. **Context Matters**: Macros often look strange until you consider the final generated code they produce for each specific type or context.

### Reading Macro Code

1. **Split Conditionals Pattern**: 
   - Macro conditionals (`{% if %}`) may open in one place and close much later in the code
   - This creates conditional wrappers around shared code sections
   - Example:
     ```crystal
     {% if condition %}
       # Start of conditional runtime code
       if some_runtime_condition
     {% end %}
     
     # Shared code that appears in all cases
     
     {% if condition %}
       end  # End of the runtime conditional
     {% end %}
     ```

2. **Macro Syntax vs Runtime Syntax**:
   - `{% ... %}` denotes macro code (compile-time)
   - Regular code without these delimiters is template code that will be output
   - Variables like `{{variable}}` are compile-time variables inserted into the output

3. **Macro Iteration**:
   - `{% for x in collection %}` generates repeated code for each item
   - Each iteration can produce custom code based on the properties of the current item

### IO::Serializable Implementation Patterns

1. **Properties Collection**:
   - Gather metadata about instance variables in a properties hash
   - Use this to generate specialized serialization code for each property

2. **Type-Based Dispatching**:
   - Use conditionals to generate different code paths based on property types
   - Handle nilable types with special conditional wrappers

3. **Method Detection**:
   - `has_method?("method_name")` checks if a type has a method at compile time
   - Different from `responds_to?(:method)` which is a runtime check

## Common Pitfalls to Avoid

1. **Treating Macro Code as Runtime Code**:
   - Don't analyze macro code as if it runs at runtime
   - Always consider what code it will generate

2. **Missing Split Conditionals**:
   - Always trace macro conditionals to their completion
   - Remember that `{% if %}` blocks may wrap around large sections of code

3. **Forgetting Context**:
   - Macro code executes in the context of the type including the module
   - Type information and instance variables depend on this context

## Project-Specific Conventions

1. **Serialization Pattern**:
   - Properties are collected with metadata (type, nilability, etc.)
   - Nilable properties write a flag indicating nil status
   - Type-specific serialization methods are used based on property type

2. **Deserialization Pattern**:
   - Similar property collection approach as serialization
   - Nilable properties read a flag and conditionally deserialize
   - Type-specific deserialization methods match the serialization methods

Remember to always analyze macro code by mentally expanding it to see the final generated code for each specific type or context.

## Closing remarks

After you have read these instructions, you will only reply with a confirmation that you have read and understand your new instructions.
