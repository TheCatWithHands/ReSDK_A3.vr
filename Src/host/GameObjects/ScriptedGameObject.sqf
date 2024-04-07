// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include "..\engine.hpp"
#include "..\oop.hpp"


class(ScriptedGameObject) extends(object)
	"
		name:Скрипт игрового объекта
		desc:Базовый скрипт игрового объекта для реализации пользовательской логики.
		path:Игровые объекты.Скриптовые
	" node_class

	"
		name:Название скрипта
		desc:Внутреннее название скрипта для игрового объекта.
		prop:all
		classprop:1
		return:string:Название скрипта
		defval:Скрипт игрового объекта
	" node_var
	var(name,"Скрипт игрового объекта");

	"
		name:Владелец скрипта
		desc:Игровой объект, к которому привязан скрипт.
		prop:get
		return:IDestructible^:Игровой объект.
	" node_var
	var(src,nullPtr);

	"
		name:Ограничения типов
		desc:Какие типы игровых объектов могут владеть этим скриптом. "+
		"При указании класса для ограничения используется наследование. Например, указав класс Item все типы, унаследованные от него (например, свеча) могут так же использовать этот скрипт.
		type:const
		classprop:1
		return:array[classname]:Список ролей, доступных в режиме.
		defval:[""IDestructible""]
		restr:IDestructible
	" node_met
	getter_func(getRestrictions,["IDestructible"]);

	// ------------------------------ common setup -------------------------------
	//auto add script to all objects - когда создается первый объект такого скрипта он апллаится ко всем объектам указанного типа
	"
		name:Применить ко всем объектам
		desc:Создает экземпляры скрипта для всех игровых объектов, являющихся типами (или их наследниками), указанных в ограничениях типов. Применение происходит когда хотя бы один игровой объект получил созданный скрипт, либо скрипт указан в объектах карты.
		type:const
		classprop:1
		return:bool:Автоприменение скрипта
		defval:false
	" node_met
	getterconst_func(addScriptToAllObjects,false);

	// ------------------------------------------- logic -------------------------------------------

	func(assignScript)
	{
		objParams_1(_src);

		assert_str(!isNullVar(_src),"Internal param error; Script source is null");
		assert_str(!isNullReference(_src),"Source object is null reference");
		assert_str(isTypeOf(_src,IDestructible),"Script must be assigned to IDestructible instance");
		assert_str(!isTypeOf(_src,BasicMob),"Script cannot be assigned to mob or entity");

		assert_str(isNullReference(getVar(_src,__script)),"Script already assigned to object " + str _src);

		if isNullReference(_src) exitWith {};
		if !isTypeOf(_src,IDestructible) exitWith {};
		if isTypeOf(_src,BasicMob) exitWith {};
		private _canUse = false;
		private _restrList = callSelf(getRestrictions);
		{
			if isTypeStringOf(_src,_x) exitWith {
				_canUse = true;
			};
		} foreach _restrList;

		if (!_canUse) exitWith {
			setLastError("Script " + callSelf(getClassName) + " cannot be assigned to game object " + callFunc(_src,getClassName));
		};
		

		setVar(_src,__script,this);
		setSelf(src,_src);

		callSelfParams(onScriptAssigned,_src);
	};

	"
		name:Скрипт присвоен
		desc:Выполняется когда скрипт присваивается игровому объекту.
		type:event
		out:IDestructible^:Объект:Игровой объект, к которому привязан скрипт.
	" node_met
	func(onScriptAssigned)
	{
		objParams_1(_obj);
	};

	//Действия персонажа к объекту
region(Main action)
	"
		name:При основном действии
		namelib:При основном действии
		desc:Срабатывает при исполнении персонажем основного действия с объектом (при нажатии кнопки ""Е""). "+
		"Основное действие выполняется, если персонаж может его выполнить. "+
		"Для этого он должен быть в сознании и у него должна быть рука, которой производится действие.
		type:event
		out:BasicMob:Персонаж:Тот, кто выполняет действие по отношению к объекту.
	" node_met
	func(_onMainActionWrapper)
	{
		objParams_1(_usr);
		callSelfParams(callBaseMainAction,_usr);
	};

	func(onMainAction)
	{
		objParams_1(_usr);
		callSelfParams(_onMainActionWrapper,_usr);
	};
	
	"
		name:Основное действие
		desc:Базовая логика основного действия, определенная в игровом объекте.
		type:method
		lockoverride:1
	" node_met
	func(callBaseMainAction)
	{
		params ['this'];
		assert_str(!isNullVar(_usr),"Internal error on call base main action - user not defined");
		callFuncParams(getSelf(src),onMainAction,_usr);
	};

	"
		name:Текст основного действия
		desc:Название основного действия, выводимого в окне при нажатии ""ПКМ"" по объекту.
		prop:all
		classprop:1
		return:string:Текст основного действия
		defval:Основное действие
	" node_var
	var(mainActionName,"Основное действие");

	"
		name:Получить текст основного действия
		desc:Данный узел предоставляет возможность гибкой настройки отображаемого названия основного действия при нажатии ""ПКМ"". Например, с помощью этого узла можно выводить ""Включить лампочку"" или ""Выключить лампочку"" в зависимости от состояния игрового объекта, на который назначен скрипт (в этом примере таким объектом является лампочка). "+
		"По умолчанию возвращает значение свойства ""Текст основного действия"".
		type:event
		out:BasicMob:Персонаж:Тот, кто запрашивает текст основного действия.
		return:string:Текст основного действия
	" node_met
	func(_getMainActionNameWrapper)
	{
		objParams_1(_usr);
		getSelf(mainActionName)
	};

	func(getMainActionName)
	{
		objParams_1(_usr);
		callSelfParams(_getMainActionNameWrapper,_usr);
	};

	"
		name:Текст основного действия объекта
		desc:Возвращает текстовое название основного действия, предоставляемое логикой игрового объекта и выводимого в окне при нажатии ""ПКМ"" по объекту.
		type:method
		lockoverride:1
		return:string:Текст основного действия игрового объекта
	" node_met
	func(callBaseGetMainActionName)
	{
		objParams();
		private _r = callFunc(getSelf(src),getMainActionName);
		if isNullVar(_r) then {_r = ""};
		if not_equalTypes(_r,"") then {_r = ""};
		_r
	};
region(Extra action)
	"
		name:При особом действии
		namelib:При особом действии
		desc:Срабатывает при исполнении персонажем особого действия с объектом (при нажатии кнопки ""F"" с включенным спец.действием).
		type:event
		out:BasicMob:Персонаж:Тот, кто выполняет действие по отношению к объекту.
		out:enum.SpecialActionType:Тип действия:Тип специального действия
	" node_met
	func(_onExtraActionWrapper)
	{
		objParams_2(_usr,_act);
		callSelfParams(callBaseExtraAction,_usr arg _act);
	};

	func(onExtraAction)
	{
		objParams_2(_usr,_act);
		if isNullVar(_act) then {
			_act = getVar(_usr,specialAction);
		};
		callSelfParams(_onExtraActionWrapper,_usr arg _act);
	};

	"
		name:Особое действие
		desc:Базовая логика особого действия, определенная в игровом объекте.
		type:method
		lockoverride:1
	" node_met
	func(callBaseExtraAction)
	{
		params ['this'];
		assert_str(!isNullVar(_usr),"Internal error on call base extra action - user not defined");
		callFuncParams(_usr,extraAction,getSelf(src));
	};

region(Common interactions)

	// --------------- generic interactions -----------------------

region(InteractWith)
	"
		name:При взаимодействии предметом
		desc:Срабатывает при взаимодействии персонажа с объектом при помощью другого предмета. 
		type:event
		out:Item:Предмет:Предмет, используемый для взаимодействия с владельцем этого скрипта.
		out:BasicMob:Персонаж:Персонаж, выполняющий взаимодействие.
		out:bool:Боевой режим:Возвращает истину, если взаимодействие произведено в боевом режиме.
		out:bool:В инвентаре:Возвращает истину, если взаимодействие применено к объекту, находящемуся в инвентаре.
	" node_met
	func(_onInteractWithWrapper)
	{
		objParams_4(_with,_usr,_combat,_inventory);
		callSelf(callBaseInteractWith);
	};

	func(onInteractWith)
	{
		objParams_4(_with,_usr,_combat,_inventory);
		callSelfParams(_onInteractWithWrapper,_with arg _usr arg _combat arg _inventory);
	};

	"
		name:Взаимодействие предметом
		desc:Основная логика взаимодействия с объектом с помощью предмета.
		type:method
		lockoverride:1
	" node_met
	func(callBaseInteractWith)
	{
		params ['this'];
		callSelf(callBaseClickTarget);
	};

region(redirected interact)
	//Этот раздел предназначен для вызова действий на объекте (работает по аналогии с interactTo)

	func(_interactToWrapper)
	{
		//TODO implement
	};

region(OnClick)
	"
		name:При нажатии
		desc:Срабатывает при взаимодействии персонажа по объекту пустой рукой (при нажатии ""ЛКМ"").
		type:event
		out:BasicMob:Персонаж:Персонаж, выполняющий нажатие.
		out:bool:Боевой режим:Возвращает истину, если нажатие произведено в боевом режиме.
		out:bool:В инвентаре:Возвращает истину, если нажатие произведено по предмету в инвентаре.
	" node_met
	func(_onClickWrapper)
	{
		objParams_3(_usr,_isCombatAction,_isInventoryAction);
		callSelf(callBaseOnClick);
	};

	func(onClick)
	{
		objParams_3(_usr,_isInventoryAction,_isCombatAction);
		callSelfParams(_onClickWrapper,_usr arg _isCombatAction arg _isInventoryAction );
	};

	"
		name:Нажатие
		desc:Основная логика нажатия на объект.
		type:method
		lockoverride:1
	" node_met
	func(callBaseOnClick)
	{
		params ['this'];
		callSelf(callBaseClickTarget);
	};

region(ItemClick)
	"
		name:При нажатии в активной руке
		desc:Срабатывает при нажатии персонажем по предмету в инвентаре, находящемуся в активной руке.
		type:event
		out:Item:Предмет:Предмет, которым выполняется нажатие.
		out:BasicMob:Персонаж:Персонаж, выполняющий нажатие.
		out:bool:Боевой режим:Возвращает истину, если нажатие произведено в боевом режиме.
	" node_met
	func(_onItemSelfClickWrapper)
	{
		objParams_2(_usr,_combat);
		callSelfParams(callBaseItemSelfClick,_with arg _usr);
	};

	func(onItemSelfClick)
	{
		objParams_2(_usr,_combat);
		callSelfParams(_onItemSelfClickWrapper,_usr arg _combat);
	};

	"
		name:Нажатие в активной руке
		desc:Основная логика нажатия по предмету в активной руке.
		type:method
		lockoverride:1
	" node_met
	func(callBaseItemSelfClick)
	{
		params ['this'];
		callSelf(callBaseClickTarget);
	};

	func(callBaseClickTarget)
	{
		objParams();
		assert_str(!isNullVar(_usr),"Internal error - user reference not defined");
		assert_str(!isNullReference(_usr),"Internal error - user reference null");
		assert_str(!isNullVar(_targ),"Internal error - target reference not defined");

		callFuncParams(_usr,clickTarget,_targ);
	};

endclass