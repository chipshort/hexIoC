package hex.ioc.parser.xml;

import hex.ioc.core.ContextAttributeList;
import hex.ioc.core.ContextNameList;
import hex.ioc.vo.DomainListenerVOArguments;

/**
 * ...
 * @author Francis Bourre
 */
class XMLParserUtil
{

	private function new() 
	{
		
	}
	
	public static function getArguments( xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );

		if ( iterator.hasNext() )
		{
			while ( iterator.hasNext() )
			{
				var item = iterator.next();

				var argItem : Dynamic					= {};
				argItem.staticRef 						= item.get( ContextAttributeList.STATIC_REF );
				argItem.ref 							= item.get( ContextAttributeList.REF );
				argItem.type 							= item.get( ContextAttributeList.TYPE );
				argItem.value 							= item.get( ContextAttributeList.VALUE );
				args.push( argItem );
			}
		}
		else
		{
			var value : String = XMLAttributeUtil.getValue( xml );
			if ( value != null ) 
			{
				args.push( { type:xml.get( ContextAttributeList.TYPE ), value:xml.get( ContextAttributeList.VALUE ) } );
			}
		}

		return args;
	}

	public static function getMethodCallArguments( xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNameList.ARGUMENT );
		
		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			
			var argItem : Dynamic					= {};
			argItem.id 								= item.get( ContextAttributeList.ID );
			argItem.staticRef 						= item.get( ContextAttributeList.STATIC_REF );
			argItem.ref 							= item.get( ContextAttributeList.REF );
			argItem.type 							= item.get( ContextAttributeList.TYPE );
			argItem.value 							= item.get( ContextAttributeList.VALUE );
			args.push( argItem );
		}

		return args;
	}

	public static function getEventArguments( xml : Xml ) : Array<DomainListenerVOArguments>
	{
		var args : Array<DomainListenerVOArguments> = [];
		var iterator = xml.elementsNamed( ContextNameList.EVENT );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();
			
			var domainListenerVOArguments : DomainListenerVOArguments 	= new DomainListenerVOArguments();
			domainListenerVOArguments.name 								= item.get( ContextAttributeList.NAME );
			domainListenerVOArguments.staticRef 						= item.get( ContextAttributeList.STATIC_REF );
			domainListenerVOArguments.method 							= item.get( ContextAttributeList.METHOD );
			domainListenerVOArguments.strategy 							= item.get( ContextAttributeList.STRATEGY );
			domainListenerVOArguments.injectedInModule 					= item.get( ContextAttributeList.INJECTED_IN_MODULE ) == "true";
			args.push( domainListenerVOArguments );
		}

		return args;
	}

	public static function getItems( xml : Xml ) : Array<Dynamic>
	{
		var args : Array<Dynamic> = [];
		var iterator = xml.elementsNamed( ContextNameList.ITEM );

		while ( iterator.hasNext() )
		{
			var item = iterator.next();

			var keyList 	= item.elementsNamed( ContextNameList.KEY );
			var valueList 	= item.elementsNamed( ContextNameList.VALUE );
			
			if ( keyList.hasNext() )
			{
				args.push( { 	mapName:XMLAttributeUtil.getMapName( item ), 
								key:XMLParserUtil._getAttributes( keyList.next() ), 
								value:XMLParserUtil._getAttributes( valueList.next() ) } 
							);
			}
		}

		return args;
	}

	private static function _getAttributes( xml : Xml ) : Dynamic
	{
		var obj : Dynamic = {};
		var iterator = xml.attributes();
		
		while ( iterator.hasNext() )
		{
			var attribute = iterator.next();
			Reflect.setField( obj, attribute, xml.get( attribute ) );
		}

		return obj;
	}
}