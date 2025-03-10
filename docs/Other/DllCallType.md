# DllCallType

## Method Summary

| Method Name                                           | Return Type | Description                                                              |
| ----------------------------------------------------- | ----------- | ------------------------------------------------------------------------ |
| [`static Exists(Str)`](#Exists)                       | `Boolean`   | Returns `true`, if `Str` is a valid `DllCall()` type                     |
| [`static FromWindowsType(WinType)`](#FromWindowsType) | `String`    | Returns an appropriate `DllCall()` type for the given Windows data type. |

---

## Method Details

<a id="Exists"></a>

### `static Exists(Str: String) => Boolean`

**Description**:

Returns `true`, if `Str` is a valid `DllCall()` type.

**Example**:

```ahk
DllCallType.Exists("UInt*") ; true
```

**Parameters**:

| Parameter Name | Type     | Description                            |
| -------------- | -------- | -------------------------------------- |
| `Str`          | `String` | Any string to be used as type argument |

**Return Value**:

- **Type**: `Boolean`

---

<a id="FromWindowsType"></a>

### `static FromWindowsType(WinType: String) => String`

**Description**:

Returns an appropriate `DllCall()` type for the given Windows data type.

**Example**:

```ahk
DllCallType.FromWindowsType("DWORD") ; "UInt"
```

**Parameters**:

| Parameter Name | Type     | Description       |
| -------------- | -------- | ----------------- |
| `WinType`      | `String` | Windows data type |

**Return Value**:

- **Type**: `String`
