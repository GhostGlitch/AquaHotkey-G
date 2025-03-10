/**
 * AquaHotkey - DLL.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Other/DLL.ahk
 * 
 * **Overview**:
 *
 * The `DLL` class provides an object-oriented interface for dynamically
 * loading and interacting with Windows DLLs in a clean and structured way.
 * It automatically resolves function addresses and binds method signatures
 * for type safety.
 *
 * **Usage**:
 *
 * To create a DLL wrapper, define a subclass and specify the target DLL
 * using the `static FilePath` property:
 *
 * ```
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 * }
 * ```
 *
 * This automatically resolves all available functions in `user32.dll` by
 * memory address when the class is initialized.
 * 
 * **Defining Function Signatures**:
 *
 * Function parameters can be defined explicitly via:
 *
 * 1. **Assigning signatures dynamically**:
 * 
 * ```
 * User32.CharUpper := ["Str", "Str"]
 * ```
 * 
 * 2. **Defining them inside the subclass**:
 * 
 * ```
 * class User32 extends DLL {
 *     static FilePath => "user32.dll"
 *     
 *     static TypeSignatures => {
 *         MessageBox: ["Ptr", "Str", "Str", "UInt", "Int"]
 *         CharUpper: "Str, Str"
 *         ; etc.
 *     }
 * }
 * ```
 * 
 * **Function Resolution Behavior**:
 *
 * - If a method is **directly defined**, it is used immediately.
 * - If a method is **not available**, the class automatically 
 *   tries **appending "A" (ANSI) or "W" (Wide)** based on system architecture:
 *   - **32-bit AutoHotkey → Uses "A" (ANSI) functions**.
 *   - **64-bit AutoHotkey → Uses "W" (Unicode) functions**.
 * - Once resolved, the function address is retroactively added as property,
 *   improving performance for repeated calls.
 *
 * **Limitations**:
 *
 * - Each subclass can only reference a single DLL.
 * - Subclasses cannot override the `FilePath` property.
 * - If a DLL does not export a function table (e.g., COM-based DLLs),
 *   function resolution will fail.
 *
 * **Error Handling**:
 *
 * - If a requested function is not found, an explicit error message
 *   is thrown.
 * - If an invalid function signature is provided, an **error is raised
 *   during assignment** basic Windows data types are supported.
 *
 * **Example Usage**:
 *
 * ```
 * class Kernel32 extends DLL {
 *     static FilePath => "kernel32.dll"
 * 
 *     static TypeSignatures => {
 *         GetTickCount: ["UInt"]
 *     }
 * }
 *
 * TickCount := Kernel32.GetTickCount()
 *
 * ; defining a function signature
 * Kernel32.Sleep := ["UInt"]
 * Kernel32.Sleep(1000) ; Sleep for 1 second
 * ```
 */
class DLL extends UninstantiableClass {
    /**
     * Class initialization. This method loads the DLL file, generating property
     * getters and methods dynamically.
     */
    static __New() {
        static LoadLibrary(DllClass) {
            if (!DllClass.HasOwnProp("FilePath")) {
                throw PropertyError("missing property: static FilePath",,
                                    String(DllClass))
            }
            FilePath := DllClass.FilePath
            hModule  := DllCall("GetModuleHandle", "Str", FilePath, "Ptr")
            if (!hModule) {
                hModule := DllCall("LoadLibrary", "Str", FilePath, "Ptr")
                OnExit((*) => DllCall("FreeLibrary", "Ptr", hModule))
            }
            if (!hModule) {
                throw TargetError("unable to load library",, FilePath)
            }
            return hModule
        }
        
        static DeleteAllProperties(DllClass) {
            static Delete(Obj, PropertyName) {
                return Object.Prototype.DeleteProp.Call(Obj, PropertyName)
            }

            if (ObjHasOwnProp(DllClass, "TypeSignatures")) {
                TypeSignatures := DllClass.TypeSignatures.AssertType(Object)
            } else {
                TypeSignatures := false
            }

            Proto         := DllClass.Prototype
            DeletionQueue := Array()

            for PropertyName in ObjOwnProps(DllClass) {
                DeletionQueue.Push(Delete.Bind(DllClass, PropertyName))
            }

            for PropertyName in ObjOwnProps(Proto) {
                DeletionQueue.Push(Delete.Bind(Proto, PropertyName))
            }

            for DeletionFunction in DeletionQueue {
                DeletionFunction()
            }

            return TypeSignatures
        }
        

        static LoadProperties(DllClass, hModule, TypeSignatures) {
            p_peHeader       := hModule + NumGet(hModule, 0x3C, "UInt")
            p_optionalHeader := p_peHeader + 0x18
            PE_format        := NumGet(p_optionalHeader, "UShort")

            switch (PE_format) {
                case 0x20B:        offset := 0x70
                case 0x10B, 0x107: offset := 0x60
                default: throw ValueError("invalid PE format",, PE_format)
            }
            
            exportTableRva := NumGet(p_optionalHeader, offset, "UInt")
            p_exportTable  := hModule + exportTableRva

            if (exportTableMagic := NumGet(p_exportTable, "UInt")) {
                exportTableMagic := Format("{:#08x}", exportTableMagic)
                throw ValueError("this DLL has no exported functions",,
                                 "unexpected value " . exportTableMagic)
            }

            cNameEntries   := NumGet(p_exportTable, 0x18, "UInt")
            p_names        := hModule + NumGet(p_ExportTable, 0x20, "UInt")

            Loop cNameEntries {
                offset := (A_Index - 1) * 4
                p_name := hModule + NumGet(p_names, offset, "UInt")
                Name   := StrGet(p_name, "CP0")
                Addr   := DllCall("GetProcAddress",
                                  "Ptr", hModule, "AStr", Name, "Ptr")

                PropDesc     := Object()
                PropDesc.Get := CreateGetter(DllClass, Name, Addr)
                PropDesc.Set := CreateSetter(DllClass, Name)
                
                DllClass.DefineProp(Name, PropDesc)

                static CreateGetter(DllClass, Name, Addr) {
                    FunctionName := DllClass.Prototype.__Class . ".Prototype."
                                  . Name . ".Get"

                    Getter.DefineProp("Name", {
                        Get: (Instance) => FunctionName
                    })
                    return Getter

                    Getter(Instance) {
                        return Addr
                    }
                }

                static CreateSetter(DllClass, Name) {
                    return Setter

                    Setter(Instance, Value) {
                        Instance.__Set(Name, [], Value)
                    }
                }
            }

            if (!TypeSignatures) {
                return
            }

            TypeSignatures.AssertType(Object)
            for PropName, TypeSignature in ObjOwnProps(TypeSignatures) {
                DllClass.__Set(PropName, [], TypeSignature)
            }
        }

        if (this == DLL) {
            return
        }

        if (ObjGetBase(this) != DLL) {
            if (ObjHasOwnProp(this, "FilePath")) {
                throw PropertyError("DLL is already defined in a base class")
            }
            if (ObjHasOwnProp(this, "TypeSignatures")) {
                TypeSignatures := this.TypeSignatures
            } else {
                TypeSignatures := false
            }
            DeleteAllProperties(this)
            if (!TypeSignatures) {
                return
            }
            for PropName, TypeSignature in ObjOwnProps(TypeSignatures) {
                this.__Set(PropName, [], TypeSignature)
            }
            return
        }
        
        hModule := LoadLibrary(this)
        TypeSignatures := DeleteAllProperties(this)
        LoadProperties(this, hModule, TypeSignatures)
    }
    
    /**
     * Sets a new type signature for a method `PropName` of this DLL class.
     * @example
     * 
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * 
     * User32.CharUpper := "Ptr, Str"
     * User32.CharUpper(StrPtr("Hello, world!")) ; "HELLO, WORLD!"
     * 
     * @param   {String}        PropName  name of the method
     * @param   {Array}         Args      zero or more arguments (ignored)
     * @param   {String/Array}  Value     array of strings or a comma delimited
     *                                    list of all parameter types
     * @return  {Func}
     */
    static __Set(PropName, Args, Value) {
        if (!HasProp(this, PropName)) {
            PropName .= ((A_PtrSize == 8) ? "W" : "A")
            if (!HasProp(this, PropName)) {
                throw PropertyError("DLL function does not exist",, PropName)
            }
        }
        BaseClass := this
        while (!ObjHasOwnProp(BaseClass, PropName)) {
            BaseClass := BaseClass.base
        }

        EntryPoint    := this.%PropName%
        DllCallback   := DllFunc(EntryPoint, Value)

        Callback(Instance, Value*) {
            return DllCallback(Value*)
        }
        FunctionName := BaseClass.Prototype.__Class . ".Prototype." . PropName
        Callback.DefineProp("Name", { Get: (Instance) => FunctionName })

        PropDesc      := BaseClass.GetOwnPropDesc(PropName)
        PropDesc.Call := Callback
        BaseClass.DefineProp(PropName, PropDesc)
        return GetMethod(this, PropName)
    }

    /**
     * This method is called whenever an undefined property is retrieved and
     * attempts to find a property with an "-A" or "-W" suffix.
     * 
     * If a property was found, it will be retroactively defined for the class
     * to avoid calling this meta-function again. An error is thrown, if the
     * property could not be found.
     * 
     * @example
     * 
     * class User32 extends DLL {
     *     static FilePath => "user32.dll"
     * }
     * ; only properties `MessageBoxA` and `MessageBoxW` exist
     * EntryPoint := User32.MessageBox 
     * 
     * @param   {String}  PropName  name of the undefined property
     * @param   {Array}   Args      zero or more arguments (ignored)
     */
    static __Get(OldPropName, Args) {
        NewPropName := OldPropName . ((A_PtrSize == 8) ? "W" : "A")
        if (HasProp(this, NewPropName)) {
            this.DefineProp(OldPropName, this.GetOwnPropDesc(NewPropName))
            return this.%NewPropName%
        }
        throw PropertyError("DLL function does not exist",, OldPropName)
    }

    /**
     * This method is called whenever an undefined method is called and attempts
     * to find a method with an "-A" or "-W" suffix.
     * 
     * If a property was found, it will be retroactively defined for the class
     * to avoid calling this meta-function again. An error is thrown, if the
     * property could not be found or if there is not yet a type signature
     * defined.
     * 
     * @param   {String}  PropName  name of the undefined method
     * @param   {Array}   Args      zero or more additional arguments
     */
    static __Call(OldPropName, Args) {
        NewPropName := OldPropName . ((A_PtrSize == 8) ? "W" : "A")
        if (HasProp(this, NewPropName)) {
            this.DefineProp(OldPropName, this.GetOwnPropDesc(NewPropName))
            return this.%NewPropName%(Args*)
        }
        throw PropertyError("DLL function does not exist",, OldPropName)
    }
}
