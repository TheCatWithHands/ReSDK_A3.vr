// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include <..\..\host\oop.hpp>
#include <..\..\host\engine.hpp>
#include <..\ClientRpc\clientRpc.hpp>
#include <..\..\host\NOEngine\NOEngine.hpp>
#include <..\ClientData\ClientData.hpp>
#include <LightEngine.h>
#include <LightEngine.hpp>

//decl
#include "ScriptedEffects.sqf"
//cfgs
#include "ScriptedEffectConfigs.sqf"
//prepare cfgs
call le_se_doSorting;

#include "LightConfigs.sqf"
#include "FireLightConfigs.sqf"
#include "ShotableConfigs.sqf"
#include "VisualStatesConfigs.sqf"

// #include "LightEngine_mainThread.sqf"

#include "LightRender.sqf"

// Нужно выяснить какое существо самое лучшее в плане атачинга при первом создании
le_simulated = clientMob;//"B_Soldier_F" createVehicleLocal [0,0,0];

//le_handler_mainThread = -1;
//le_handler_rendering = -1;
//le_glsData = objNull;
//le_localGlsData = nullPtr;

le_allChunkTypes = [CHUNK_TYPE_ITEM,CHUNK_TYPE_STRUCTURE,CHUNK_TYPE_DECOR];

le_allLights = []; //all light points

/*le_init = {
	le_glsData = dml_lightingData;
	if (isNullVar(le_glsData)) exitWith {
		error("LightEngine - gls data is null");
	};
	if (isNULL le_glsData) exitWith {
		error("LightEngine - gls data is nullptr");
	};
	//memfree on repl variable


	le_localGlsData = createObj;

	le_handler_mainThread = startUpdate(le_onUpdate,update_delay_mainThread);
	traceformat("start thread le::onUpdate() - handle %1",le_handler_mainThread);

};*/


//загружает источник освещения или частиц
le_loadLight = {
	params [['_type',-1],"_src"];
	
	#ifdef NOE_DEBUG_HIDE_CLIENT_LIGHT
	if true exitWith {objNull}; //use this code for testing serverside light
	#endif

	if (_type <= 0) exitWith {
		error("LightEngine::LoadLight() - Undefined light type");
		if (!isMultiplayer) then {
			traceformat("LightEngine::LoadLight() - args %1",_this);
		};
	};

	private _code = missionNamespace getVariable ["le_conf_" + str _type,{}];

	if equals(_code,{}) exitWith {
		errorformat("Cant load light from config => %1",_type);
	};

	//выгрузка старого конфига света
	private _oldCfg = _src getvariable "__config";
	if (!isNullVar(_oldCfg)) then {
		if not_equals(_oldCfg,_type) then {
			//Вот этот код может вызывать определённые проблемы в некоторых случаях
			[_src] call le_unloadLight;
		};
	};

	[_src] call _code;
};

//автоматическое событие освещения, эффектов или звука
le_doFireLight = {
	params [["_type",-1],"_src"];

	if (_type <= le_firelight_startindex) exitWith {
		error("LightEngine::doFireLight() - Undefined light type");
	};

	private _code = missionNamespace getVariable ["le_conf_fire_" + str (_type - le_firelight_startindex),{}];

	if equals(_code,{}) exitWith {
		errorformat("Cant load light from config => %1",_type);
	};

	[_src] call _code;
};

le_doShot = {
	params ["_type","_src",["_ctxParams",[]]];

	if (_type <= le_shot_startindex) exitWith {
		error("LightEngine::doShot() - Undefined light type");
	};
	
	private _code = missionNamespace getVariable ["le_conf_shot_" + str (_type - le_shot_startindex),{}];
	
	if equals(_code,{}) exitWith {
		errorformat("Cant load light from config => %1",_type);
	};

	[_src,_ctxParams] call _code;
};	

//выгружает источник освещения
le_unloadLight = {
	params ["_obj"];

	#ifdef NOE_DEBUG_HIDE_CLIENT_LIGHT
	if true exitwith {};
	#endif

	private _light = _obj getvariable ["__light",objNUll];
	private _allEmitters = _obj getVariable ["__allEmitters",[]];
	{
		deleteVehicle _x;
	} foreach _allEmitters;
	_obj setVariable ["__allEmitters",null];
	_obj setvariable ["__config",null];

	_obj setvariable ["__defBright",null];

	le_allLights deleteat (le_allLights find _light);
	le_allLights deleteat (le_allLights find _obj);
	
	
	os_light_list_noProcessedLights deleteAt (os_light_list_noProcessedLights find _light);
	
	
	deleteVehicle _light;
};

//проверяет висит ли на объекте источник света
le_isLoadedLight = {
	params ["_obj"];
	private _light = _obj getvariable ["__light",objNUll];
	not_equals(_light,objNUll)
};

le_isLightConfig = {
	_this > 0 && _this <= le_light_max_index
};

le_isShotConfig = {
	_this >= le_shot_startindex
};

//OBSOLETE
/*le_reloadLightSystem = {
	if (true) exitWith {
		error("le::reloadLightSystem() - obsolete function. Rewrite need");
	};
	stopUpdate(le_handler_mainThread);

	private _chunksToCheck = [];
	{
		_chunkType = _x;

		_chunk = [getPosATL player,_chunkType] call dmlExt_posToChunk;
		[_chunksToCheck,_chunk,_chunkType] call le_collectAroundChunks;
	} foreach le_allChunkTypes;

	//cleanup chunks
	{
		_x params ["_type","_cx","_cy"];
		_localData = getOnlyObjects(getLocalGLSData(_type,_cx,_cy));
		{
			[_x] call le_unloadLight;
		} foreach _localData;
		setLocalGLSData(_type,_cx,_cy,glsNull);
	} foreach _chunksToCheck;

	le_handler_mainThread = startUpdate(le_onUpdate,update_delay_mainThread);
	traceformat("restarted thread le::onUpdate() - new handle %1",le_handler_mainThread);

	//restarting mob vars
	call smd_reloadMobsLighting;

};
*/

le_debug_canViewLight = {
	params ["_src","_isLightObject"];

	//lineIntersectsWith
	//lineIntersectsSurfaces
	//lineIntersectsObjs

	//eyePos player == ATLToASL positionCameraToWorld [0,0,0]

	private _level = 2;
	private _maxLevel = 3;
	private _unit = player;
	private _unipos = AGLToASL (_unit modelToWorld (_unit selectionPosition "spine3"));

	if (_isLightObject) exitWith {

		//pop left
		/*private _nobjs = [];
		{
			deleteVehicle _x;
		} foreach (_src getVariable ['_nobjs',_nobjs]);*/

		_selections = selectionNames _src;
		_pos = [0,0,0];
		if (count _selections > 0) then {
			_pos = AGLToASL (_src modelToWorld (_src selectionPosition (_selections select 0)));
		} else {
			_pos = ATLToASL getposatl _src;
		};

		private _list = lineIntersectsSurfaces [_unipos,_pos,player,_src,true,1000,"VIEW","VIEW",false];
/*		{
			_arrow = "Sign_Arrow_F" createVehicle [0,0,0];
			_arrow setPosASL (_x select 0);
			_arrow setVectorUp (_x select 1);
			_nobjs pushBack _arrow;

			_light = "#lightpoint" createVehicleLocal [0,0,0];
			_light setPosASL (_x select 0);
			_nobjs pushBack _light;

			_light setLightBrightness 6.34;
			_light setLightColor [0.013,0.001,0];
			_light setLightAmbient [0.013,0.001,0];
			_light setLightAttenuation [0,50,3,700,4,1];
			linkLight(_light,player,vector(0,0,0));
			linkLight(_light,_arrow,vector(0,0,0));
		} foreach _list;
		_src setVariable ['_nobjs',_nobjs];*/

		if (count _list == 0) exitWith {true};
		if (count _list >= _maxLevel) exitWith {false};
		true
	};


	private _dist = (eyepos player) distance (ATLToASL getposatl _src);
	//if (((eyepos player) distance (ATLToASL getposatl _src)) <= _level) exitWith {true};

	//pop left
/*	private _nobjs = [];
	{
		deleteVehicle _x;
	} foreach (_src getVariable ['_nobjs',_nobjs]);*/

	private _list = lineIntersectsSurfaces [_unipos,ATLToASL getposatl _src,player,_src,true,1000,"VIEW","VIEW",false];
	/*{
		_arrow = "Sign_Arrow_F" createVehicle [0,0,0];
		_arrow setPosASL (_x select 0);
		_arrow setVectorUp (_x select 1);
		_light = "#lightpoint" createVehicleLocal [0,0,0];
		_light setPosASL (_x select 0);
		_nobjs pushBack _light;

		_light setLightBrightness 6.34;
		_light setLightColor [0.013,0.001,0];
		_light setLightAmbient [0.013,0.001,0];
		_light setLightAttenuation [0,50,3,700,4,1];
		linkLight(_light,player,vector(0,0,0));
		linkLight(_light,_arrow,vector(0,0,0));

		_nobjs pushBack _arrow;
	} foreach _list;
	_src setVariable ['_nobjs',_nobjs];*/

	if (count _list == 0) exitWith {true};
	if (count _list >= _maxLevel) exitWith {false};
	if (true) exitWith {true};

	private _size = 0;

/*	{
		_size = (boundingBoxReal (_x select 2)) select 2;
		MOD(_dist,-_size);
	} foreach _list;

	if (_dist <= 0) exitWith {false};*/

	true
};

le_debug_lightRender = {
	#ifndef usedebuglightrender
		if (true) exitWith {};
	#endif

	private _renderMode = _this; //1 and 2
	_evlight = {
		(_this select 0) params ['lightObject','sourceObject',"_renderMode"];

		if isNullReference(lightObject) then {stopThisUpdate()};

		//_canView = [sourceObject,_renderMode == 2] call le_debug_canViewLight;
		//drawIcon3D ["", [1,0,0,1], ASLToAGL getPosASL sourceObject, 0, 0, 0, format["visible %1 <%2>",_canView,sourceObject], 1, 0.05, "PuristaMedium"];

		_lastResult = sourceObject getvariable ['lightischecked',false];
		if (_lastResult != ([sourceObject,_renderMode == 2] call le_debug_canViewLight)) then {
			if (!_lastResult) then {
				//lightObject setLightIntensity (25 + 10 * ((1 + 1) / 2));
				if (_renderMode == 1) then {
					linkLight(lightObject,sourceObject,vector(0,0,0.05));
				} else {
					lightObject hideObject false;
				};

				//lightObject setLightBrightness .5;
				trace("ENABLE - " + str sourceObject + " as " + str _renderMode);
			} else {

				//lightObject setLightIntensity 0;
				if (_renderMode == 1) then {
					linkLight(lightObject,sourceObject,vector(0,0,-1000.05));
				} else {
					lightObject hideObject true;
				};
				//lightObject setLightBrightness .5 / 10;
				trace("DISABLE - " + str sourceObject + " as " + str _renderMode);
			};
			sourceObject setVariable ['lightischecked',!_lastResult];
		};

	}; startUpdateParams(_evlight,0.01,[lightObject arg sourceObject arg _renderMode]);
};


//OBSOLETE

/*if (!isNull(dml_posToChunk)) then {
	le_debug_getNotEmptyChunks = {
		params ["_categs",["_doOnlyObjs",true]];

		private _dataret = [];

		private _chunksToCheck = [];
		{
			_chunkType = _x;

			_chunk = [getPosATL player,_chunkType] call dmlExt_posToChunk;
			[_chunksToCheck,_chunk,_chunkType] call le_collectAroundChunks;
		} foreach _categs;
		{
			_x params ["_type","_cx","_cy"];
			_localData = if (_doOnlyObjs) then {getOnlyObjects(getLocalGLSData(_type,_cx,_cy))} else {getLocalGLSData(_type,_cx,_cy)};

			_dataret pushBack _localData;
		} foreach _chunksToCheck;

		_dataret
	};

	le_debug_getlightprops = { //"light_1_hide"
		params ["_vehicle", "_light"];

		private _config = configFile >> "CfgVehicles" >> typeOf _vehicle >> "Reflectors" >> _light;

		private _intensity = getNumber (_config >> "intensity");
		private _position = getText (_config >> "position");
		private _direction = getText (_config >> "direction");
		private _innerAngle = getNumber (_config >> "innerAngle");
		private _outerAngle = getNumber (_config >> "outerAngle");

		[_intensity, _position, _direction, _innerAngle, _outerAngle]
	};

	le_debug_getlight = {
		obj = objNULL;
		FHEADER;
		{
			if ("fireplace_f.p3d" in (str _x) || "lampindustrial_01_f.p3d" in (str _x)) exitWith {
				obj = _x;
				RETURN(obj);
			};
		} foreach (player nearObjects 20);
	};
	le_debug_calc = {
		params ["_unit","_lightSource",["_asConfig",false],["_intens",(25 + 10 * ((1 + 1) / 2))]];

		private _unitPos = _unit modelToWorld (_unit selectionPosition "spine3");
		private _lightLevel = 0;

		if _asConfig then {
			_properties = [_lightSource,"light_1_hide"] call le_debug_getlightprops;
			private _innerAngle = (_properties select 3) / 2;
			private _outerAngle = (_properties select 4) / 2;

			// get world position and direction
			private _position = _lightSource modelToWorld (_lightSource selectionPosition (_properties select 1));
			private _direction = _lightSource modelToWorld (_lightSource selectionPosition (_properties select 2));

			_direction = _position vectorFromTo _direction;
			private _directionToUnit = _position vectorFromTo _unitPos;

			private _distance = _unitPos distance _position;
			private _angle = acos (_direction vectorDotProduct _directionToUnit);

			_lightLevel = _lightLevel max ((linearConversion [0, 30, _distance, 1, 0, true]) * (linearConversion [_innerAngle, _outerAngle, _angle, 1, 0, true]));
		} else {
			private _position = _lightSource modelToWorld [0,0,0];
			private _distance = _unitPos distance _position;
			_lightLevel = _lightLevel max (linearConversion [0, 10, _distance, 1, 0, true] * linearConversion [0, 1300,_intens , 0, 1, true]);
		};

		_lightLevel
	};



	le_debug_listObjects = [];
	le_debug_getNearObjects = {

		#define createArrow() "Sign_Arrow_F" createVehicle [0,0,0]

		_chunkType = 2;
		_chunk = [getPosATL player,_chunkType] call dml_posToChunk;

		([_chunk,_chunkType] call dml_chunkToPos) params ["_xPos","_yPos"];

		private _size = (_chunkType) call dmlExt_getChunkSizeByType;

		private _posCenter = [_xPos + _size / 2,_yPos + _size / 2];

		private _objList = _posCenter nearObjects (_size * 1.5);


		_listarrows = [];
		_arrow = "Sign_Arrow_F" createVehicle [0,0,0];
		_arrow setposatl (_posCenter vectorAdd [0,0,0]);
		_listarrows pushBack _arrow;
		{
			_arrow = "Sign_Arrow_F" createVehicle [0,0,0];
			_arrow setposatl ((getPosATL _x) vectorAdd [0,0,0.2]);
			_listarrows pushBack _arrow;
		} foreach _objList;
		invokeAfterDelayParams({{deleteVehicle _x} foreach _this},1.5,_listarrows);

		traceformat("Object in chunk %1: %2",_chunk arg count _objList);
	};


	//отправляет запрос на сервер о том, что ему нужна информация о созданных объектах типа свет
	le_getLocalObjectsData = {
		params ["_chunk","_chunkType"];

		if (_chunkType < 1 && _chunkType > 2) exitWith {
			errorformat("le::getLocalObjectsData() - Unexpected chunk enum - %1",_chunkType);
		};



	};

};*/





