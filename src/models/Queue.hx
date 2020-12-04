package models;

import pony.text.tpl.TplData.TplShortTag;
import pony.text.tpl.ITplPut;
import pony.net.http.modules.mmodels.ModelPut;
import pony.db.DBV;
import pony.net.http.modules.mmodels.Model;
import pony.net.http.modules.mmodels.ModelConnect;
import pony.net.http.modules.mmodels.Field;
import pony.net.http.modules.mmodels.fields.FString;
import pony.net.http.modules.mmodels.fields.FDate;
import pony.tests.Errors;

@:enum abstract QueueFields(String) to String {

	var ID = 'id';
	var NAME = 'name';
	var REG = 'reg';
	var BEGIN = 'begin';
	var END = 'end';

}

@:enum abstract ValidateErrors(String) to String {

	var EMPTY = 'Empty';
	var SHORT = 'Is short';
	var LONG = 'Is long';

}

@:keep class Queue extends Model {

	public static var NAME_MIN: Int = 3;
	public static var NAME_MAX: Int = 60;

	private static var fields: Dynamic<Field> = {
		name: new FString(NAME_MAX),
		reg: new FDate(true),
		begin: new FDate(false),
		end: new FDate(false)
	};

}

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(':async'))
@:keep class QueueConnect extends ModelConnect {

	@:async function many(): Array<Dynamic> {
		var s: Int = @await rawWaitTime();
		var r = @await db.select(ID, NAME, REG).where((begin == null) & end == null).asc(REG).get();
		return r.map(e -> ({
			id: e.id,
			name: e.name,
			reg: e.reg + s
		}));

	}
	@:async function insert(name: String): Bool return @await db.insert([NAME => (name: DBV), REG => DBV.TIMESTAMP]);
	@:async function delete(id: Int): Bool return @await db.where(id == $id).delete();
	@action('Delete') @:async function start(id: Int): Bool return @await db.where(id == $id).update([BEGIN => DBV.TIMESTAMP]);
	@action('Delete') @:async function finish(id: Int): Bool return @await db.where(id == $id).update([END => DBV.TIMESTAMP]);
	@action('Single') @:async function current(): Dynamic return @await db.where(begin != null & end == null).asc(REG).first();
	@action('Single') @:async function next(): Dynamic return @await db.where((begin == null) & end == null).asc(REG).first();

	function validate(name: String): Errors {
		var e: Errors = new Errors();
		e.arg = NAME;
		e.test(name == '', EMPTY);
		e.test(name.length < Queue.NAME_MIN, SHORT);
		e.test(name.length > Queue.NAME_MAX, LONG);
		return e;
	}

	override public function tpl(parent: ITplPut): ITplPut {
		return new QueuePut(this, null, parent);
	}

	@:async
	public function rawWaitTime(): Int {
		var r = @await db.select(BEGIN, END).where((begin != null) & end != null).get();
		var s: Int = 0;
		for (e in r) s += Std.int(e.end) - Std.int(e.begin);
		return s;
	}

	@:async
	public function waitTime(): String {
		var s: Int = @await rawWaitTime();
		return '${Std.int(s / 60)} мин ${s % 60} сек';
	}


}

@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class QueuePut extends ModelPut {

	@:async @:puper
	override public function shortTag(name:String, arg:String, ?kid:ITplPut):String {
		if (name == 'waittime')
			return @await cast(a, QueueConnect).waitTime();
		if (parent == null)
			return '%' + name + '%';
		else
			return @await super.shortTag(name, arg, kid);
	}

}