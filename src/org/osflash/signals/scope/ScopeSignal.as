package org.osflash.signals.scope
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	import org.osflash.signals.events.IScopeEvent;
	import org.osflash.signals.events.ScopeEvent;


	public class ScopeSignal implements IScopeSignal, IScopeDispatcher
	{

		protected var _valueClasses : Array; // of Class
		protected var listeners : Dictionary; // of Scope of Array of Function
		protected var onceListeners : Dictionary; // of Function
		protected var injectEventListeners : Dictionary;
		protected var listenersNeedCloning : Boolean = false;



		public function ScopeSignal( ... valueClasses )
		{
			listeners = new Dictionary();
			onceListeners = new Dictionary();
			injectEventListeners = new Dictionary();
			// Cannot use super.apply(null, valueClasses), so allow the subclass to call super(valueClasses).
			if( valueClasses.length == 1 && valueClasses[ 0 ] is Array )
				valueClasses = valueClasses[ 0 ];
			setValueClasses( valueClasses );
		}


		public function get valueClasses() : Array
		{
			return _valueClasses;
		}

		public function get numListeners() : uint
		{
			return listeners.length;
		}


		public function add( scope : Object, listener : Function, injectEvent : Boolean = false ) : void
		{
			registerListener( scope, listener, false, injectEvent );
		}

		public function addOnce( scope : Object, listener : Function, injectEvent : Boolean = false ) : void
		{
			registerListener( scope, listener, true, injectEvent );
		}



		public function dispatch( scope : Object, ... valueObjects ) : void
		{
			// If there's no arguments it's ok
			if( valueObjects.length )
			{
				// Validate value objects against pre-defined value classes.
				var valueObject : Object;
				var valueClass : Class;
				var len : int = _valueClasses.length;
				for( var i : int = 0; i < len; i++ )
				{
					// null is allowed to pass through.
					if(( valueObject = valueObjects[ i ]) === null || valueObject is ( valueClass = _valueClasses[ i ]))
						continue;

					throw new ArgumentError( 'Value object <' + valueObject + '> is not an instance of <' + valueClass + '>.' );
				}
			}

			//// Call listeners.
			var scopeListeners : Array;

			if( scope !== null )
				scopeListeners = listeners[ scope ];

			if( scopeListeners == null )
				scopeListeners = [];

			// We add the global listeners (which scope == null)
			var globalListeners : Array = listeners[ null ];

			if( globalListeners == null )
				globalListeners = [];


			var callListener : Function;
			switch( valueObjects.length )
			{
				case 0:
					callListener = function( event : IScopeEvent = null ) : void
				{
					if( event != null )
						listener( event );
					else
						listener();
				};
					break;
				case 1:
					callListener = function( event : IScopeEvent = null ) : void
				{
					if( event != null )
						listener.apply( null, [ event ].concat( valueObjects ));
					else
						listener( valueObjects[ 0 ]);
				};
				default:
					callListener = function( event : IScopeEvent = null ) : void
				{
					if( event != null )
						listener.apply( null, [ event ].concat( valueObjects ));
					else
						listener.apply( null, valueObjects );
				};
			}


			// During a dispatch, add() and remove() should clone listeners array instead of modifying it.
			listenersNeedCloning = true;
			var listener : Function;

			for each( listener in scopeListeners.concat( globalListeners ))
			{
				var event : IScopeEvent = null;
				if( injectEventListeners[ listener ])
					event = createEvent( scope );

				if( onceListeners[ listener ])
					remove( scope, listener );

				callListener( event );
			}

			listenersNeedCloning = false;
		}


		protected function callListeners() : void
		{

		}

		protected function createEvent( scope : Object ) : IScopeEvent
		{
			return new ScopeEvent( this, scope );
		}


		public function remove( scope : Object, listener : Function ) : void
		{
			var scopeListeners : Array = listeners[ scope ];
			if( !scopeListeners )
				return;

			var index : int = scopeListeners.indexOf( listener );
			if( index == -1 )
				return;
			if( listenersNeedCloning )
			{
				listeners[ scope ] = scopeListeners = scopeListeners.slice();
				listenersNeedCloning = false;
			}
			scopeListeners.splice( index, 1 );
			delete onceListeners[ listener ];
			delete injectEventListeners[ listener ];
		}



		public function removeAll( scope : Object ) : void
		{
			var scopeListeners : Array = listeners[ scope ];
			if( !scopeListeners )
				return;

			// Looping backwards is more efficient when removing array items.
			for( var i : uint = scopeListeners.length; i--;  )
			{
				var listener : Function = scopeListeners[ i ] as Function;
				var index : int = scopeListeners.indexOf( listener );
				if( index == -1 )
					return;
				if( listenersNeedCloning )
				{
					listeners[ scope ] = scopeListeners = scopeListeners.slice();
					listenersNeedCloning = false;
				}
				scopeListeners.splice( index, 1 );
				delete onceListeners[ listener ];
				delete injectEventListeners[ listener ];
			}
		}



		protected function setValueClasses( valueClasses : Array ) : void
		{
			_valueClasses = valueClasses || [];

			for( var i : int = _valueClasses.length; i--;  )
			{
				if( !( _valueClasses[ i ] is Class ))
				{
					throw new ArgumentError( 'Invalid valueClasses argument: item at index ' + i + ' should be a Class but was:<' + _valueClasses[ i ] + '>.' );
				}
			}
		}

		protected function registerListener( scope : Object, listener : Function, once : Boolean = false, injectEvent : Boolean = false ) : void
		{
			// function.length is the number of arguments.
			if( listener.length < _valueClasses.length )
			{
				var argumentString : String = ( listener.length == 1 ) ? 'argument' : 'arguments';
				throw new ArgumentError( 'Listener has ' + listener.length + ' ' + argumentString + ' but it needs at least ' + _valueClasses.length + ' to match the given value classes.' );
			}

			var scopeListeners : Array = listeners[ scope ];
			if( !scopeListeners )
				listeners[ scope ] = scopeListeners = [];

			// If there are no previous listeners, add the first one as quickly as possible.
			if( !scopeListeners.length )
			{
				scopeListeners[ 0 ] = listener;
				if( once )
					onceListeners[ listener ] = true;
				if( injectEvent )
					injectEventListeners[ listener ] = true;
				return;
			}

			if( scopeListeners.indexOf( listener ) >= 0 )
			{
				// If the listener was previously added, definitely don't add it again.
				// But throw an exception in some cases, as the error messages explain.
				if( onceListeners[ listener ] && !once )
				{
					throw new IllegalOperationError( 'You cannot addOnce() then add() the same listener without removing the relationship first.' );
				}
				else if( !onceListeners[ listener ] && once )
				{
					throw new IllegalOperationError( 'You cannot add() then addOnce() the same listener without removing the relationship first.' );
				}
				// Listener was already added, so do nothing.
				return;
			}

			if( listenersNeedCloning )
			{
				listeners[ scope ] = scopeListeners = scopeListeners.slice();
				listenersNeedCloning = false;
			}

			// Faster than push().
			scopeListeners[ scopeListeners.length ] = listener;
			if( once )
				onceListeners[ listener ] = true;
			if( injectEvent )
				injectEventListeners[ listener ] = true;
		}

	}
}