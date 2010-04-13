package org.osflash.signals.events
{
	import org.osflash.signals.scope.IScopeSignal;

	public class ScopeEvent implements IScopeEvent
	{

		protected var _signal : IScopeSignal;
		protected var _scope : Object;


		public function ScopeEvent( signal : IScopeSignal, scope : Object )
		{
			_signal = signal;
			_scope = scope;
		}


		public function get signal() : IScopeSignal
		{
			return _signal;
		}

		public function get scope() : Object
		{
			return _scope;
		}
	}
}