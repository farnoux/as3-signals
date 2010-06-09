package org.osflash.signals.net
{
	import flight.net.IResponse;

	import org.osflash.signals.IDispatcher;
	import org.osflash.signals.scope.IScopeDispatcher;
	import org.osflash.signals.scope.IScopeSignal;


	public interface IResponseSignal extends IScopeSignal
	{

		function hasResponse() : Boolean;

		function getResponse() : IResponse;


		//--------------------------------------------------------------------------
		//  associate an IResponse object to the signal
		//--------------------------------------------------------------------------

		function addResponse( response : IResponse ) : IResponseSignal;


		//--------------------------------------------------------------------------
		//  shortcuts to the IResponse interface
		//--------------------------------------------------------------------------

		function addResult( handler : Function, ... resultParams ) : IResponseSignal;

		function bindResult( target : Object, targetPath : Object ) : IResponseSignal;

		function addFault( handler : Function, ... faultParams ) : IResponseSignal;

	}

}