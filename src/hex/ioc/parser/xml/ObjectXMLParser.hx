package hex.ioc.parser.xml;

import hex.error.Exception;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.core.ContextTypeList;
import hex.ioc.error.ParsingException;
import hex.ioc.vo.ConstructorVO;
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
	
	override public function parse() : Void
	{
		var iterator = this.getXMLContext().firstElement().elements();
		while ( iterator.hasNext() )
		{
			this._parseNode( iterator.next() );
		}

		this._handleComplete();
	}
	
	function _parseNode( xml : Xml ) : Void
	{
		var applicationContext : AbstractApplicationContext = this.getApplicationContext();

		var identifier : String = XMLAttributeUtil.getID( xml );
		if ( identifier == null )
		{
			throw new ParsingException( this + " encounters parsing error with '" + xml.nodeName + "' node. You must set an id attribute." );
		}

		var type 		: String;
		var args 		: Array<Dynamic>;
		var factory 	: String;
		var singleton 	: String;
		var injectInto	: Bool;
		var mapType		: String;
		var staticRef	: String;
		var ifList		: Array<String>;
		var ifNotList	: Array<String>;

		// Build object.
		type = XMLAttributeUtil.getType( xml );

		if ( type == ContextTypeList.XML )
		{
			factory = xml.get( ContextAttributeList.PARSER_CLASS );
			args = [ new ConstructorVO( identifier, ContextTypeList.STRING, [ xml.firstElement().toString() ] ) ];
			this.getApplicationAssembler().buildObject( applicationContext, identifier, type, args, factory );
		}
		else
		{
			args 		= ( type == ContextTypeList.HASHMAP || type == ContextTypeList.SERVICE_LOCATOR ) ? XMLParserUtil.getItems( identifier, xml ) : XMLParserUtil.getArguments( identifier, xml, type );
			factory 	= XMLAttributeUtil.getFactoryMethod( xml );
			singleton 	= XMLAttributeUtil.getSingletonAccess( xml );
			injectInto	= XMLAttributeUtil.getInjectInto( xml );
			mapType 	= XMLAttributeUtil.getMapType( xml );
			staticRef 	= XMLAttributeUtil.getStaticRef( xml );
			ifList 		= XMLParserUtil.getIfList( xml );
			ifNotList 	= XMLParserUtil.getIfNotList( xml );

			if ( type == null )
			{
				type = staticRef != null ? ContextTypeList.INSTANCE : ContextTypeList.STRING;
			}

			this.getApplicationAssembler( ).buildObject( applicationContext, identifier, type, args, factory, singleton, injectInto, mapType, staticRef, ifList, ifNotList );

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
						XMLAttributeUtil.getStaticRef( property ),
						XMLParserUtil.getIfList( xml ),
						XMLParserUtil.getIfNotList( xml )
				);
			}

			// Build method call.
			var methodCallIterator = xml.elementsNamed( ContextNameList.METHOD_CALL );
			while( methodCallIterator.hasNext() )
			{
				var methodCallItem = methodCallIterator.next();
				this.getApplicationAssembler( ).buildMethodCall( applicationContext, identifier, XMLAttributeUtil.getName( methodCallItem ), XMLParserUtil.getMethodCallArguments( identifier, methodCallItem ), XMLParserUtil.getIfList( methodCallItem ), XMLParserUtil.getIfNotList( methodCallItem ) );
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
					this.getApplicationAssembler().buildDomainListener( applicationContext, identifier, channelName, listenerArgs, XMLParserUtil.getIfList( listener ), XMLParserUtil.getIfNotList( listener ) );
				}
				else
				{
					throw new Exception( this + " encounters parsing error with '" + xml.nodeName + "' node, 'ref' attribute is mandatory in a 'listen' node." );
				}
			}
		}
	}
}