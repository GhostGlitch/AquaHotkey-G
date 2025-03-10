# DllFunc

## Method Summary

| Method Name                             | Return Type | Description                                                                |
| --------------------------------------- | ----------- | -------------------------------------------------------------------------- |
| [`static Call(Function, Types)`](#Call) | `BoundFunc` | Constructs a `DllCall` function which is bound to the given type signature |

## Method Details

<a id="Call"></a>

### `static Call(Function: String/Integer, Types: String/Array) => BoundFunc`

**Description**:

Constructs a `DllCall()` function which is bound the the given type signature `Types`, an array or a comma-delimited list of types.

**Example**:

```ahk
CharUpper := DllFunc("CharUpper", "Str", "Str")
CharUpper("Hello, world!") ; "HELLO, WORLD!"
```

**Parameters**:

| Parameter Name | Type             | Description                               |
| -------------- | ---------------- | ----------------------------------------- |
| `Function`     | `Integer/String` | Name or address of DLL function           |
| `Types`        | `String/Array`   | An array or comma-delimited list of types |

**Return Value**:

- **Type**: `BoundFunc`
