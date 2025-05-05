/**
 * AquaHotkey - AquaHotkey_Backup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_Backup.ahk
 * 
 * The `AquaHotkey_Backup` class creates a snapshot of all properties and
 * methods contained in one or more classes, allowing them to be safely
 * overridden or extended later.
 * 
 * To use it, create a subclass of `AquaHotkey_Backup` and call
 * `super.__New()` within its static constructor, passing the class or classes
 * to copy from.
 * 
 * 
 * 
 * This class extends `AquaHotkey_Ignore`, which means that it is skipped by
 * `AquaHotkey`'s automatic class prototyping mechanism.
 * 
 * If you want your subclass to *actively apply* the collected methods to
 * multiple unrelated classes, use `AquaHotkey_MultiApply` instead.
 * 
 * @example
 * 
 * class Gui_Backup extends AquaHotkey_Backup {
 *     static __New() {
 *         super.__New(Gui)
 *     }
 * }
 * 
 * class LotsOfStuff extends AquaHotkey_Backup {
 *     static __New() {
 *         super.__New(MyClass, MyOtherClass, String, Array, Buffer)
 *     }
 * }
 */
class AquaHotkey_Backup extends AquaHotkey_Ignore {
    /**
     * Static class initializer that copies properties and methods from one or
     * more sources. An error is thrown if a subclass calls this method without
     * passing any parameters.
     * 
     * @param   {Object*}  Suppliers  where to copy properties and methods from
     */
    static __New(Suppliers*) {
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
        if (this == AquaHotkey_Backup) {
            return
        }

        ; If a subclass calls this method, the parameter count must not be zero.
        if (!Suppliers.Length) {
            throw ValueError("No source classes provided")
        }

        ; Start copying properties and methods from all specified targets.
        Receiver := this
        for Supplier in Suppliers {
            Transfer(Supplier, Receiver)
        }

        /**
         * Copies over all static and instance properties from
         * Supplier to Receiver.
         */
        static Transfer(Supplier, Receiver) {
            ReceiverName := Receiver.Prototype.__Class
            switch {
                case (Supplier is Class):
                    SupplierName := Supplier.Prototype.__Class
                case (Supplier is Func):
                    SupplierName := Supplier.Name
                default:
                    SupplierName := Type(Supplier)
            }
            FormatString := "`n[Aqua] ######## Backup: {1} -> {2} ########`n"
            OutputDebug(Format(FormatString, SupplierName, ReceiverName))

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
                Define(NestedReceiver, "Prototype", {
                    Value: NestedReceiverProto
                })
                
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
