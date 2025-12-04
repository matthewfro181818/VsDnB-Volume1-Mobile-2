package data;

/**
 * An interface used to define the necessary functions and properties
 * for a registry entry.
 */
interface IRegistryEntry<T>
{
    /**
     * The ID of the entry.
     * Interfaces cannot define `final` vars, so we declare a read-only property.
     */
    public var id(default, null):String;

    /**
     * Retrieves the data for this entry.
     * @param id The id of the entry.
     * @return The data object for this entry.
     */
    public function fetchData(id:String):T;

    /**
     * Destroys this data object.
     */
    public function destroy():Void;

    /**
     * Returns a string representation of this entry.
     */
    public function toString():String;
}
