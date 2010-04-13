package org.osflash.signals.scope
{

	public interface IScopeDispatcher
	{
		function dispatch( scope : Object, ... valueObjects ) : void;
	}
}