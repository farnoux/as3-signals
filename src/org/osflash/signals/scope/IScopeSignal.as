package org.osflash.signals.scope
{

	public interface IScopeSignal
	{
		/**
		 * An optional array of classes defining the types of parameters sent to listeners.
		 */
		function get valueClasses() : Array;

		/** The current number of listeners for the signal. */
		function get numListeners() : uint;


		function add( scope : Object, listener : Function, injectEvent : Boolean = false ) : void;

		function addOnce( scope : Object, listener : Function, injectEvent : Boolean = false ) : void;

		function remove( scope : Object, listener : Function ) : void;

	}
}