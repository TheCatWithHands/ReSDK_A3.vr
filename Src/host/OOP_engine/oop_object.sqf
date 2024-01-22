// ======================================================
// Copyright (c) 2017-2023 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include "..\oop.hpp"
#include "..\engine.hpp"

#define basic() _mother = TYPE_SUPER_BASE;

//basic object for all oop system
editor_attribute("HiddenClass")
class(object) basic()
	"
		name:Объект
		desc:Базовый объект, от которого унаследованы абсолютно все другие объекты. Является корневым типом в объектной системе.
		path:Объекты.Библиотека
	"
	node_class

	"
		name:Получить имя
		namelib:Получить имя объекта
		desc:Получает имя объекта. Данное имя эквивалентно имени класса.
		type:method
		lockoverride:1
		color:PureFunction
		return:classname:Имя класса
	" node_met
	func(getClassName)
	{
		objParams();
		this getVariable PROTOTYPE_VAR_NAME getVariable "classname"
	};

	"
		name:Получить класс
		namelib:Получить класс объекта
		desc:Получает класс объекта.
		type:method
		lockoverride:1
		color:PureFunction
		return:class:Объект типа (класс)
	" node_met
	getter_func(getType,typeGetFromObject(this));

	"
		name:Конструктор
		namelib:Конструктор объекта
		desc:Конструктор объекта. Вызывается при создании объекта.
		type:event
	" node_met
	func(constructor)
	{
		INC(oop_cao);
		INC(oop_cco);
	};

	"
		name:Деструктор
		namelib:Деструктор объекта
		desc:Деструктор объекта. Вызывается при удалении объекта.
		type:event
	" node_met
	func(destructor)
	{
		DEC(oop_cao);
	};

endclass

class(Type) extends(object)
	"
		name:Класс
		desc:Предоставляет интерфейс для работы с типами объектов.
		path:Объекты.Библиотека
	"
	node_class

	var(_srcType,nullPtr); //TODO auto alloc type objects

	func(getMember)
	{
		objParams_1(_name);
		typeGetVar(getSelf(_srcType),_name);
	};

	func(setMember)
	{
		objParams_2(_name,val);
		typeSetVar(getSelf(_srcType),_name,_val)
	};

	func(hasMember)
	{
		objParams_1(_name);
		typeHasVar(getSelf(_srcType),_name);
	};

	func(getVarDefaultValue)
	{
		params ['this',"_name",["_serialized",true]];
		private _srcObj = getSelf(_srcType);
		ifcheck(_serialized,typeGetDefaultFieldValueSerialized(_srcObj,_name),typeGetDefaultFieldValue(_srcObj,_name))
	};

endclass

class(ManagedObject) extends(object)
	"
		name:Управляемый объект
		desc:Управляемый системой объект, поддерживающий логику обновления (симуляции)
		path:Объекты.Библиотека
	"
	node_class
	var(handleUpdate,-1);
	
	// Указывает может ли быть использована функция обновления
	getterconst_func(hasUpdate,false);
	// Указывает есть ли какие-нибудь действия в методе обновления
	var_bool(haveUpdateActions);
	getter_func(doUpdateAction,setSelf(haveUpdateActions,true));
	getter_func(resetUpdateAction,setSelf(haveUpdateActions,false));

	func(constructor)
	{
		if (callSelf(hasUpdate)) then {
			setSelf(handleUpdate,startUpdateParams(getSelfFunc(onUpdate),1,[this]));
			INC(oop_upd);
		};
	};

	getter_func(enableAutoRefGC,true);

	func(destructor)
	{
		
		private _hnd = getSelf(handleUpdate);
		if (_hnd > -1) then {
			stopUpdate(_hnd);
			DEC(oop_upd);
		};
		
		if (!callSelf(enableAutoRefGC)) exitWith {};

		//implementation for GC half-referenced objects
		private _refList = getSelfFunc(__autoref_list);

		if (!isNullVar(_refList)) then {
			private _ptr = nullPtr;
			private _Tarray = [];
			{
				_ptr = getSelfReflect(_x); //may be object reference or array

				call {
					if equalTypes(_ptr,_Tarray) exitWith { //cleanup array
						{
							if (!isNullObject(_x)) then {
								delete(_x);
							}
						} foreach _ptr;

						_ptr resize 1;
						_ptr set [0,"<AUTOREF_NAN>"];
					};
					if equalTypes(_ptr,nullPtr) exitWith { //cleanup object links
						if (!isNullObject(_ptr)) then {
							delete(_ptr);
						}
					};
					if equalTypes(_ptr,0) exitWith { //stop threads threads
						if (_ptr > -1) then {
							stopUpdate(_ptr);
						}
					};
				}

			} foreach _refList;
		};
	};

endclass

//Объект с системой подсчёта ссылок созданных экземпляров
//TODO refactoing with type object
editor_attribute("HiddenClass")
class(RefCounterObject)

	func(getRefList)
	{
		objParams();
		private _t = typeGetFromObject(this);
		if !typeHasVar(_t,__references) then {
			typeSetVar(_t,__references,[]);
		};
		typeGetVar(_t,__references)
	};
	
	//Внешнее получение по типу
	func(getRefListFromType)
	{
		objParams_1(_typeObj);
		
		if !typeHasVar(_typeObj,__references) then {
			typeSetVar(_typeObj,__references,[]);
		};
		typeGetVar(_typeObj,__references)
	};

	func(constructor)
	{
		objParams();
		callSelf(getRefList) pushBack this;
	};
	
	func(destructor)
	{
		objParams();
		private _refs = callSelf(getRefList);
		_refs deleteAt (_refs find this);
	};

endclass

class(NetObject) basic()

	func(getClassName)
	{
		objParams();
		this getVariable PROTOTYPE_VAR_NAME getVariable "classname"
	};

endclass
