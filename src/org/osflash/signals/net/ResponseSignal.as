package org.osflash.signals.net
{
	import flight.net.IResponse;
	import flight.net.Response;

	import org.osflash.signals.scope.ScopeSignal;

	public class ResponseSignal extends ScopeSignal implements IResponseSignal
	{
		//--------------------------------------------------------------------------
		//  RESPONSE CLASS - the class implementing IResponse that is lazily created
		//--------------------------------------------------------------------------
		public static var RESPONSE_CLASS : Class = Response;


		public function ResponseSignal( ... valueClasses )
		{
			super( valueClasses );
		}



		//--------------------------------------------------------------------------
		//  response - the IResponse property
		//--------------------------------------------------------------------------

		protected var _response : IResponse;

		public function get response() : IResponse
		{
			if( !_response )
				_response = new RESPONSE_CLASS() as IResponse;

			return _response;
		}

		public function set response( value : IResponse ) : void
		{
			if( _response == value )
				return;

			_response = value;
		}



		//--------------------------------------------------------------------------
		//  Implemented methods from IResponseSignal
		//--------------------------------------------------------------------------

		public function hasResponse() : Boolean
		{
			return _response != null;
		}

		public function getResponse() : IResponse
		{
			return _response;
		}


		public function addResponse( response : IResponse ) : IResponseSignal
		{
			this.response = response;
			return this;
		}


		public function addResult( handler : Function, ... resultParams ) : IResponseSignal
		{
			response.addResultHandler( handler, resultParams );
			return this;
		}

		public function bindResult( target : Object, targetPath : Object ) : IResponseSignal
		{
			response.bindResult( target, targetPath );
			return this;
		}

		public function addFault( handler : Function, ... faultParams ) : IResponseSignal
		{
			response.addFaultHandler( handler, faultParams );
			return this;
		}


	}
}