package hex.ioc.parser.xml;

import hex.domain.TopLevelDomain;
import hex.error.Exception;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.vo.DomainListenerVOArguments;

/**
 * ...
 * @author Francis Bourre
 */
class ObjectXMLParser extends AbstractXMLParser
{
	public function new() 
	{
		super();
	}
	
	override public function parse( ) : Void
	{
		var iterator = this.getXMLContext().firstElement().elements();
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next() );
		}

		this._handleComplete();
	}
	
	private function _parseNode( xml : Xml ) : Void
	{
		var applicationContext : ApplicationContext = this._applicationContext;

		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new Exception( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}

		this.getApplicationAssembler().registerID( applicationContext, identifier );

		var type 		: String;
		var args 		: Array<Dynamic>;
		var factory 	: String;
		var singleton 	: String;
		var mapType		: String;
		var staticRef	: String;

		// Build object.
		type = XMLAttributeUtil.getType( xml );

		if ( type == ContextTypeList.XML )
		{
			args = [];
			args.push( { ownerID:identifier, value:xml.firstElement() } );
			factory = XMLAttributeUtil.getParserClass( xml );
			this.getApplicationAssembler().buildObject( applicationContext, identifier, type, args, factory );
		}
		else
		{
			args 		= ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR ) ? XMLParserUtil.getItems( xml ) : XMLParserUtil.getArguments( xml );
			factory 	= XMLAttributeUtil.getFactoryMethod( xml );
			singleton 	= XMLAttributeUtil.getSingletonAccess( xml );
			mapType 	= XMLAttributeUtil.getMapType( xml );
			staticRef 	= XMLAttributeUtil.getStaticRef( xml );

			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.UNKNOWN : ContextTypeList.STRING;
			}

			this.getApplicationAssembler( ).buildObject( applicationContext, identifier, type, args, factory, singleton, mapType, staticRef );

			// register each object to system channel.
			this.getApplicationAssembler().buildDomainListener( applicationContext, identifier, TopLevelDomain.DOMAIN.getName().toString(), null );

			// Build property.
			var propertyIterator = xml.elementsNamed( ContextNameList.PROPERTY );
			while ( propertyIterator.hasNext() )
			{
				var property = propertyIterator.next();
				
				this.getApplicationAssembler( ).buildProperty (
						applicationContext,
						identifier,
						XMLAttributeUtil.getName( property ),
						XMLAttributeUtil.getValue( property ),
						XMLAttributeUtil.getType( property ),
						XMLAttributeUtil.getRef( property ),
						XMLAttributeUtil.getMethod( property ),
						XMLAttributeUtil.getStaticRef( property )
				);
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();
				this.getApplicationAssembler( ).buildMethodCall( applicationContext, identifier, XMLAttributeUtil.getName( methodCallItem ), XMLParserUtil.getMethodCallArguments( methodCallItem ) );
			}

			// Build channel listener.
			var listenIterator = xml.elementsNamed( ContextNameList.LISTEN );
			while( listenIterator.hasNext() )
			{
				var listener = listenIterator.next();
				var channelName : String = XMLAttributeUtil.getRef( listener );

				if ( channelName != null )
				{
					var listenerArgs : Array<DomainListenerVOArguments> = XMLParserUtil.getEventArguments( listener );
					this.getApplicationAssembler().buildDomainListener( applicationContext, identifier, channelName, listenerArgs );
				}
				else
				{
					throw new Exception( this + " encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
				}
			}
		}
	}
}