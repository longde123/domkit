package domkit;
import domkit.Property;

class PropertyHandler<O,P> {

	public var parser(default,null) : CssValue -> P;
	#if !macro
	public var defaultValue(default,null) : P;
	public var apply(default,null) : O -> P -> Void;
	#end

	#if macro
	public var defaultValue : haxe.macro.Expr;
	public var type : haxe.macro.Expr.ComplexType;
	public var position : haxe.macro.Expr.Position;
	public var parserExpr : haxe.macro.Expr;
	public var fieldName : String;
	#end

	public function new(parser,def,applyType) {
		this.parser = parser;
		this.defaultValue = def;
		#if macro
		this.type = applyType;
		#else
		this.apply = applyType;
		#end
	}
}

interface ComponentDecl<T> {
}

class Component<BaseT,T> {

	public var name : String;
	public var make : BaseT -> T;
	public var parent : Component<BaseT,Dynamic>;
	var propsHandler : Array<PropertyHandler<T,Dynamic>>;

	public function new(name, make, parent) {
		this.name = name;
		this.make = make;
		this.parent = parent;
		propsHandler = parent == null ? [] : cast parent.propsHandler.copy();
		COMPONENTS.set(name, this);
	}

	public inline function getHandler<P>( p : Property ) : PropertyHandler<T,P> {
		return cast propsHandler[p.id];
	}

	function addHandler<P>( p : String, parser : CssValue -> P, def : #if macro haxe.macro.Expr #else P #end, applyType : #if macro haxe.macro.Expr.ComplexType #else T -> P -> Void #end ) {
		var ph = new PropertyHandler(parser,def,applyType);
		propsHandler[Property.get(p).id] = ph;
		return ph;
	}

	public static function get( name : String ) {
		return COMPONENTS.get(name);
	}

	@:persistent static var COMPONENTS = new Map<String,Component<Dynamic,Dynamic>>();

}
