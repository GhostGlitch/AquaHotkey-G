/**
 * AquaHotkey - PropertyBackup.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Init/PropertyBackup.ahk
 * 
 * This class creates a snapshot of all properties and methods of a target
 * class before any modifications are applied. This allows for restoring or
 * referencing the original functionality when extending or modifying
 * built-in classes.
 * 
 * To use it, extend `PropertyBackup` and set `static Class` to the target
 * class whose properties should be preserved.
 * 
 * @example
 * 
 * class OriginalGui extends PropertyBackup {
 *     static Class => Gui
 * }
 * ; Now OriginalGui stores all original properties/methods of Gui
 * ; before modifications.
 */
class PropertyBackup {
    static __New() {
        static Define(Obj, PropertyName, PropertyDesc) {
            (Object.Prototype.DefineProp)(Obj, PropertyName, PropertyDesc)
        }

        if (this.base == Object) {
            return
        }
        ClsName := this.Prototype.__Class
        if (!ObjHasOwnProp(this, "Class")) {
            throw UnsetError('expected a "static Class" property',, ClsName)
        }
        Transfer(this.Class, this)

        static Transfer(Supplier, Receiver) {
            ReceiverProto := Receiver.Prototype
            switch {
                case (Supplier is Class): SupplierProto := Supplier.Prototype
                case (Supplier is Func):  SupplierProto := Supplier
                default:                  throw TypeError("unexpected type")
            }

            for PropertyName in ObjOwnProps(Supplier) {
                ; DO NOT REMOVE THIS
                if (PropertyName = "Prototype") {
                    continue
                }

                try {
                    DoRecursion := (Supplier.%PropertyName% is Class)
                } catch {
                    DoRecursion := false
                } 

                if (DoRecursion) {
                    NewClass := Class()
                    NewProto := Object()
                    Define(NewClass, "Prototype", CreateGetter(NewProto))
                    Define(Receiver, PropertyName, CreateGetter(NewClass))
                    Transfer(Supplier.%PropertyName%, NewClass)
                } else {
                    PropDesc := Supplier.GetOwnPropDesc(PropertyName)
                    Define(Receiver, PropertyName, PropDesc)
                }
            }

            for PropertyName in ObjOwnProps(SupplierProto) {
                PropDesc := SupplierProto.GetOwnPropDesc(PropertyName)
                Define(ReceiverProto, PropertyName, PropDesc)
            }
        }

        static CreateGetter(Value) => { Get: (Instance) => Value }
    }
}
