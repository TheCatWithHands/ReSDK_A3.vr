// ======================================================
// Copyright (c) 2017-2023 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include <..\GameMode.h>

editor_attribute("CodeOnyGamemode")
class(@GAMEMODE_NAME@) extends(GMBase) //GMBase - базовый режим, от которого унаследованы все возможные режимы.
	
    // -----------------------------------------------------------------//
    // ------------------ Базовые настройки режима ---------------------//
    // -----------------------------------------------------------------//

    // Текстовые данные режима @GAMEMODE_NAME@
	var(name,"Имя режима");
	var(desc,"Описание");
	var(descExtended,"Описание в конце игры.");

	// Длительность игры в режиме @GAMEMODE_NAME@.
	var(duration,t_atMin(30)); // 30 минут
    
    // Имя карты, которая будет создана в режиме @GAMEMODE_NAME@
	getterconst_func(getMapName,"Template");

    // ------- Настройки для случайности режима -------
    // Настройки случайности используются, когда администратор не установил режим и он выбирается автоматически
    // в зависимости от количества игроков и настроек, указанных ниже.

	//Вероятность режима при случайном выборе
	getterconst_func(getProbability,100);
	//минимальное и максимальное колчиество людей для случайного выбора режима
	getterconst_func(getReqPlayersMin,1);
	getterconst_func(getReqPlayersMax,5);


    // ------- Настройки для лобби -------

	// Путь до композиции, проигрываемой в лобби (в формате .ogg)
	getterconst_func(getLobbySoundName,"lobby\First_Steps.ogg");
	// Путь до изображения заднего фона в лобби (в формате .paa)
	getterconst_func(getLobbyBackground,PATH_PICTURE("lobby\lobby.paa"));

	// Список ролей (имён классов) для режима @GAMEMODE_NAME@, доступных до старта раунда.
	func(getLobbyRoles)
	{
		[
			// Введите тут строковые имена классов ролей через запятую
            /*
                Пример:
                    "@GAMEMODE_NAME@_BasicRole1",
                    "@GAMEMODE_NAME@_BasicRole2",
                    "@GAMEMODE_NAME@_BasicRole3"
            */
		]
	};

	// Список ролей (имён классов), доступных после начала раунда.
	// Сюда так же добавляются роли из getLobbyRoles, у которых 
	// установлен canVisibleAfterStart в значение true
	func(getLateRoles)
	{
		[
			// Введите тут строковые имена классов ролей через запятую
		]
	};

    // ---- Доп. настройки для @GAMEMODE_NAME@ ----
    getterconst_func(isVotable,true); // Можно ли проголосовать за режим с включенной системой голосования

    // Включает систему аспектов раунда. Пример аспекта: "все двери на станции украли"
    var(canAddAspect,true);

    // Можно ли запускать события "Влияния Реликты"
    getterconst_func(canPlayEvents,true);
    //Минимальное и максимальное время между запусками "Влияния Реликты"
    getter_func(getMinPlayEventTime,t_atMin(30));
	getter_func(getMaxPlayEventTime,t_atMin(50));


	// -----------------------------------------------------------------//
    // ------------------------ События режима -------------------------//
    // -----------------------------------------------------------------//

	// Условие старта раунда.
	// Если код возвращает true то раунд будет запущен
	func(conditionToStart)
	{
		objParams();
        /*
            Как правило здесь описываются условия типа: 
                если на "@GAMEMODE_NAME@_BasicRole1" встало 2 игрока и на "@GAMEMODE_NAME@_BasicRole2" встал 1 игрок,
                то раунд можно запускать.
                В лююбых других случаях раунд не стартуер.
            
            Для получения количества игроков, вставших на роли используйте функцию getCandidatesCount

            callSelfParams(getCandidatesCount,"@GAMEMODE_NAME@_BasicRole1") >= 2 
            && callSelfParams(getCandidatesCount,"@GAMEMODE_NAME@_BasicRole2") >= 1
            
        */
		false
	};

	// Возвращает строку причины невозможности запуска режима
	func(onFailReasonToStart)
	{
		objParams();
        // Как правило здесь используются проверки из conditionToStart() 
        // для точного определения причины невозможности старта раунда
		"Не установлено свойство onFailReasonToStart() для режима @GAMEMODE_NAME@"
	};

	//                          !работает только на сервере!
	// Из этого массива выбирается одно случайное сообщение и показывается при первом пробуждении персонажа
	// Установите getterconst_func(getUnsleepGameInfo,null); если вам не нужен показ этих сообщений
	func(getUnsleepGameInfo)
	{
		objParams();
		null
	};
    // Сколько сообщений будет показано из getUnsleepGameInfo
    getter_func(getUnsleepMessagesCount,1);

	// Вызывается когда режим @GAMEMODE_NAME@ выбран (до старта раунда с загруженной картой)
	func(preSetup)
	{
		objParams();

	};

	// Вызывается после начала раунда когда все клиенты зашли в игру
	func(postSetup)
	{
		objParams();

	};

	// Проверка режима. Выполняется каждую секунду
	// Возвращаемое значение должно быть числом
	// Любое число, не равное 0 означает конец режима
	func(checkFinish)
	{
		objParams();

		// Обработка конца режима по времени
		if (gm_roundDuration >= getSelf(duration)) exitWith {1};
		
		// Добавьте тут пользовательскую логику конца режима.

        
		0
	};
	
	func(getResultTextOnFinish)
	{
		objParams();

		if (getSelf(finishResult) == 1) exitWith {
			"Время режима закончилось."
		};
		
		
		"Неизвестная причина."
	};
	
	// Событие при завершении раунда в режиме @GAMEMODE_NAME@
	func(onFinish)
	{
		objParams();
		
		// Вызываем базовый метод onFinish,
		// определенный в GMBase.
		// Нужен для вывода собщения конца раунда и текста, определенного в getResultTextOnFinish
		super(); 
	};





    // -----------------------------------------------------------------//
    // -------------------- Работа с антагонистами ---------------------//
    // -----------------------------------------------------------------//
    
    /*
        Разница между скрытми и полными антагонистами довольно проста:
        - Полные антагонисты - это игроки, которые заходили за одну роль, но при входе в игру получат совершенно другую роль,
        присущую полному антагонисту. (Прим.: Грязноямск. Человек заходит за барника но появляется как Истязатель.)
        - Скрытые антагонисты - это игроки, которые получают особую цель, находясь на своей роли, за которую они заходили.
    */


    // Минимальное количество полных и скрытых антагонистов для нормальной игры
	getterconst_func(getMinFullAntags,1);
	getterconst_func(getMinHiddenAntags,1);

    // Срабатывает при старте раунда и возвращает строковое имя класса полного антагониста.
    /*
        Функция вызывается для каждого из игроков, зашедших в раунд.
        Переменная _index для первого игрока принимает значение 1, для второго 2 и т.д.

        Если функция возвращает пустую строку - игрок не получает полного антагониста.
        В ином случае его роль при входе в игру заменяется на имя класса, вычисленное логикой функции.

        Внутри этой функции доступны 2 специальных переменных:
            _countInGame - количество игроков, зашедших в раунд
            _countProbFullAntags - сколько людей зашедших в раунд выбрали в лобби "Полных антагонистов"
    */
    func(getAntagRoleFull)
	{
		objParams_2(_client,_index);
        /*
            Параметры:
                _client - объект клиента
                _index - порядковый номер проверяемого игрока
        */
        /*
            Самый банальный расчет:
            Если _index <= 2, то роль игрока заменяется на "@GAMEMODE_NAME@_RoleSuperAntag"
            или роль не заменится (вернет пустую строку)
            
            (_index <= 2) - означает, что в игре может быть до двух антагонистов
            
            if (_index <= 2) then {
                "@GAMEMODE_NAME@_RoleSuperAntag"
            } else {
                ""
            };
        */
        // Определите тут пользовательский алгоритм распределения полных антагов,
        // если они могут быть в режиме @GAMEMODE_NAME@
		""
	};

    // Обработчик скрытых антагонистов
    /*
        Функция вызывается для каждого из игроков, зашедших в раунд.
        Переменная _index для первого игрока принимает значение 1, для второго 2 и т.д.

         Внутри этой функции доступны 2 специальных переменных:
            _countInGame - количество игроков, зашедших в раунд
            _countProbHiddenAntags - сколько людей зашедших в раунд выбрали в лобби "Скрытых антагонистов"
    */
    func(handleAntagRoleHidden)
	{
		objParams_3(_client,_mob,_index);
        /*
            Параметры:
                _client - объект клиента
                _mob - игровой персонаж
                _index - порядковый номер проверяемого игрока
        */
	};

endclass