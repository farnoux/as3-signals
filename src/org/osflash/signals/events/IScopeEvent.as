package org.osflash.signals.events
{
	import org.osflash.signals.scope.IScopeSignal;

	public interface IScopeEvent
	{

		function get signal() : IScopeSignal;

		function get scope() : Object;

	}
}