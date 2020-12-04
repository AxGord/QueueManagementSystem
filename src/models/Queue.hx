package models;

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

	@:async function many(): Array<Dynamic> return @await db.select(ID, NAME, REG).where((begin == null) & end == null).asc(REG).get();
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

}