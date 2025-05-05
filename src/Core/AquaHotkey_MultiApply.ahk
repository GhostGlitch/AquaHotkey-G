/**
 * AquaHotkey - AquaHotkey_MultiApply.ahk
 * 
 * Author: 0w0Demonic
 * 
 * https://www.github.com/0w0Demonic/AquaHotkey
 * - src/Core/AquaHotkey_MultiApply.ahk
 * 
 * `AquaHotkey_MultiApply` allow you to collect properties and methods from
 * one or more sources and actively apply them to your target class.
 * 
 * This is especially useful when multiple unrelated classes (like `Gui.Button`
 * and `Gui.CheckBox`) should share a common set of methods or properties
 * defined only once in the script.
 * 
 * To use this class, create a subclass of `AquaHotkey_MultiApply` and call
 * `super.__New()` within the static constructor, passing the class(es)
 * you want to copy from.
 * 
 * `AquaHotkey_MultiApply` is functionally identical to `AquaHotkey_Backup`,
 * except that it *is not* ignored by `AquaHotkey`'s class system.
 * If you want your subclass to be skipped during prototyping, use
 * `AquaHotkey_Backup` instead.
 * 
 * @example
 * 
 * class Tanuki extends AquaHotkey {
 *     class Gui {
 *         class Button extends AquaHotkey_MultiApply {
 *             static __New() => super.__New(Tanuki.Gui.ButtonControlsCommon)
 *             
 *             ButtonProp() => MsgBox("I'm a Button!")
 *         }
 * 
 *         class ButtonControlsCommon extends AquaHotkey_Ignore {
 *             CommonProp() => MsgBox("I'm a CheckBox or a Button!")
 *         }
 * 
 *         class CheckBox extends AquaHotkey_MultiApply {
 *             static __New() => super.__New(Tanuki.Gui.ButtonControlsCommon)
 * 
 *             CheckBoxProp() => MsgBox("I'm a CheckBox!")
 *         }
 *     }
 * }
 */
class AquaHotkey_MultiApply {
    /**
     * Static class initializer that copies properties and methods from one or
     * more sources. An error is thrown if a subclass calls this method without
     * passing any parameters.
     * 
     * @example
     * 
     * ; class Tanuki extends AquaHotkey {
     * ; class Gui {
     * 
     * class Button extends AquaHotkey_MultiApply {
     *     static __New() {
     *         ; specify one or more sources to copy from
     *         super.__New(Tanuki.Gui.ButtonControlsCommon)
     *     }
     * }
     * class ButtonControlsCommon extends AquaHotkey_Ignore { ... }
     * 
     * ; }
     * ; }
     * 
     * @param   {Object*}  Suppliers  where to copy properties and methods from
     */
    static __New(Suppliers*) {
        if (this == AquaHotkey_MultiApply) {
            return
        }

        ; Use the same method as `AquaHotkey_Backup` - The only difference
        ; being that this class does not extend `AquaHotkey_Ignore` and is
        ; not ignored.
        (AquaHotkey_Backup.__New)(this, Suppliers*)
    }
}