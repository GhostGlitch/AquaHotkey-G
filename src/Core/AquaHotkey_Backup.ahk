/**
 * AquaHotkey - AquaHotkey_Backup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Init/AquaHotkey_Backup.ahk
 * 
 * This class creates a snapshot of all properties and methods of a target
 * class before any modifications are applied. This allows for restoring or
 * referencing the original functionality when extending or modifying
 * built-in classes.
 * 
 * To use it, extend `AquaHotkey_Backup` and set `static Class` to the target
 * class whose properties should be preserved.
 * 
 * @example
 * 
 * class OriginalGui extends AquaHotkey_Backup {
 *     static Class => Gui
 * }
 * ; Now OriginalGui stores all original properties/methods of Gui
 * ; before modifications.
 */
class AquaHotkey_Backup {
    /** Static initializer. */
    static __New() {
        /**
         * `Object`'s implementation of `.DefineProp()`.
         * 
         * @param   {Object}  Obj           the target object
         * @param   {String}  PropertyName  name of new property
         * @param   {Object}  PropertyDesc  property descriptor
         */
        static Define(Obj, PropertyName, PropertyDesc) {
            (Object.Prototype.DefineProp)(Obj, PropertyName, PropertyDesc)
        }

        /**
         * `Object`'s implementation of `.GetPropDesc()`.
         * 
         * @param   {Object}  Obj           the target object
         * @param   {String}  PropertyName  name of existing property
         * @return  {Object}
         */
        static GetPropDesc(Obj, PropertyName) {
            return (Object.Prototype.GetOwnPropDesc)(Obj, PropertyName)
        }

        /**
         * Returns a getter property that already returns `Value`.
         * 
         * @param   {Any}  Value  the value to return
         * @return  {Object}
         */
        static CreateGetter(Value) => { Get: (Instance) => Value }
        
        /**
         * Creates a property descriptor for a nested class.
         * 
         * @param   {Class}  Cls  the target nested class
         * @return  {Object}
         */
        static CreateNestedClassProp(Cls) {
            return {
                Get: (Instance) => Cls,
                Call: Constructor
            }

            Constructor(Instance, Args*) {
                ; If the class has its own `Call()`, use it.
                if (ObjHasOwnProp(Cls, "Call")) {
                    if (Cls.GetOwnPropDesc("Call").Call != Object.Call) {
                        return Cls(Args*)
                    }
                }
                ; Otherwise, simulate "normal" object construction.
                Obj := Object()
                ObjSetBase(Obj, Cls.Prototype)
                Obj.__New(Args*)
                return Obj
            }
        }

        ; If this is `AquaHotkey_Backup` and no derived type, do nothing.
        if (this.base == Object) {
            return
        }

        ; Here we prepare for copying: 
        ; "Receiver" is the class that *receives* the properties.
        ; "Supplier" is the class that *supplies* the properties.
        Receiver     := this
        ReceiverName := Receiver.Prototype.__Class
        if (!ObjHasOwnProp(this, "Class")) {
            throw UnsetError('expected "static Class" property',, ReceiverName)
        }
        Supplier     := this.Class
        SupplierName := Supplier.Prototype.__Class
        FormatString := "`n[Aqua] ######## Backup: {1} -> {2} ########`n"

        OutputDebug(Format(FormatString, SupplierName, ReceiverName))
        Transfer(this.Class, this)

        /**
         * Copies over all static and instance properties from
         * Supplier to Receiver.
         */
        static Transfer(Supplier, Receiver) {
            ReceiverProto := Receiver.Prototype

            ; generate debug output
            ReceiverName  := ReceiverProto.__Class
            switch {
                case (Supplier is Class):
                    SupplierProto := Supplier.Prototype
                    SupplierName  := SupplierProto.__Class
                case (Supplier is Func):
                    SupplierProto := Supplier
                    SupplierName  := Supplier.Name
                default:
                    throw TypeError("unexpected type")
            }
            FormatString := "[Aqua] {1:-40} -> {2}"
            OutputDebug(Format(FormatString, SupplierName, ReceiverName))

            ; Copy all static properties
            for PropertyName in ObjOwnProps(Supplier) {
                ; Very important - SKIP PROTOTYPE!
                if (PropertyName = "Prototype") {
                    continue
                }

                ; Check if this property is a nested class.
                try {
                    DoRecursion := (Supplier.%PropertyName% is Class)
                } catch {
                    DoRecursion := false
                }
                
                ; If it's a normal property, just copy and move on.
                if (!DoRecursion) {
                    PropDesc := GetPropDesc(Supplier, PropertyName)
                    Define(Receiver, PropertyName, PropDesc)
                    continue
                }

                ; Otherwise, we will have to recurse. 
                NestedSupplier := Supplier.%PropertyName%
                NestedSupplierName := NestedSupplier.Prototype.__Class
                
                ; If the nested class already exists in the receiver, use it.
                if (ObjHasOwnProp(Receiver, PropertyName)
                            && Receiver.%PropertyName% is Class) {
                    NestedReceiver := Receiver.%PropertyName%
                    Transfer(NestedSupplier, NestedReceiver)
                    continue
                }
                
                ; Otherwise, we will have to generate one out of thin air.
                NestedReceiver := Class()
                NestedReceiverProto := Object()
                Define(NestedReceiver, "Prototype", { Value: NestedReceiverProto })
                
                ; Define an appropriate `__Class`
                if (Index := InStr(NestedSupplierName, ".")) {
                    NestedSupplierName := SubStr(NestedSupplierName, Index + 1)
                }
                NestedReceiverName := ReceiverName . "." . NestedSupplierName
                Define(NestedReceiver, "__Class",
                       CreateGetter(NestedReceiverName))
                
                ; Hook up new nested class to receiver
                Define(Receiver, PropertyName,
                       CreateNestedClassProp(NestedReceiver))
                
                ; Keep going recursively into the new classes
                Transfer(NestedSupplier, NestedReceiver)
            }

            ; Copy all non-static properties
            for PropertyName in ObjOwnProps(SupplierProto) {
                PropDesc := GetPropDesc(SupplierProto, PropertyName)
                Define(ReceiverProto, PropertyName, PropDesc)
            }
        }
    }
}
