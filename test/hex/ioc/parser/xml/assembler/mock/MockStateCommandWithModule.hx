package hex.ioc.parser.xml.assembler.mock;

import hex.control.Request;
import hex.control.command.BasicCommand;
import hex.di.IInjectorContainer;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class MockStateCommandWithModule extends BasicCommand implements IInjectorContainer
{
	static public var callCount : Int = 0;
	static public var lastInjectedModule : IModule;
	
	@Inject
	public var module : IModule;
	
	public function execute( ?request : Request ) : Void 
	{
		MockStateCommandWithModule.callCount++;
		MockStateCommandWithModule.lastInjectedModule = this.module;
		//trace( Stringifier.stringify( this.module ) );
	}
}