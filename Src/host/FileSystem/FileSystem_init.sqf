// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================


#include <..\engine.hpp>
#include <..\struct.hpp>


fso_map_tree = createhashMap; //flat object

//initialize filesystem
fso_init = {
	private _nativeCollection = addonFiles ["src\"];
	private _useNativeCollector = count _nativeCollection > 0;
	if (!_useNativeCollector) then {
		assert_str(!isNull(file_getFileList),"file::getFileList function not found");
		_nativeCollection = ["src\",null,null,true] call file_getFileList;
		
		_nativeCollection = _nativeCollection apply {;
			_parts = (tolower _x) splitString "\/";
			_idxSrc = _parts find "src";
			(_parts select [_idxSrc,count _parts]) joinString "\";
		};
	};
	
	fso_map_tree = [_nativeCollection] call fso_buildTree;
};

#define FSO_INDEX_FILES 0
#define FSO_INDEX_FOLDERS 1

#define FSO_PATH_DELIMETER "/"

#define FSO_NEW_DATA [[],[]]

#define FSO_NORMALIZE_PATH(p) ((tolower (p)) splitString "\/" joinString FSO_PATH_DELIMETER)

#define FSO_PATH_JOIN(p1,p2) ([p1,p2] joinString FSO_PATH_DELIMETER)

/*
	tree builder maker
*/
fso_buildTree = {
	params ["_flist"];
	private _tree = createhashMap;
	forceUnicode 0;
	_flist = _flist apply {tolower _x splitString "\/"};
	private _parts = null;
	
	trace("-----------------")
	
	{
		_parts = _x;
		_probFileName = _parts select -1;
		_probDirName = _parts select -2;
		_parentDir = (_parts select [0,(count _parts) - 2]) joinString FSO_PATH_DELIMETER;
		_pathIsFile = ([_probFileName,"\.\w+$"] call regex_isMatch) || fileExists(_probFileName);
		_ptFull = _parts joinString FSO_PATH_DELIMETER;
		_dir = (_parts select [0,(count _parts) - 1]) joinString FSO_PATH_DELIMETER;
		if !(_dir in _tree) then {
			_tree set [_dir,FSO_NEW_DATA]; 
		};
		if !(_parentDir in _tree) then {
			_tree set [_dir,FSO_NEW_DATA];
		};

		traceformat("Check path: %1 + %2",_dir arg _probFileName)
		if (_pathIsFile) then {
			((_tree get _dir) select FSO_INDEX_FILES) pushBack _probFileName;
			((_tree get _parentDir) select FSO_INDEX_FOLDERS) pushBackUnique _probDirName;
		} else {
			((_tree get _dir) select FSO_INDEX_FOLDERS) pushBackUnique _probDirName;
			traceformat("dir: %1",_probDirName);
		};
		
	} foreach _flist;

	_tree
};

/* 
	Get all files in selected directory
	Extension can be with dot or without (".sqf", "")
*/
fso_getFiles = {
	params ["_pathDir",["_extension",""],["_recursive",false],["_internalFlag",true]];
	_pathDir = FSO_NORMALIZE_PATH(_pathDir);
	private _buff = fso_map_tree get _pathDir;
	if isNullVar(_buff) exitWith {[]};

	private _files = (_buff select FSO_INDEX_FILES) apply {FSO_PATH_JOIN(_pathDir,_x)};	

	if (_recursive) then {
		{
			_files append (
				[FSO_PATH_JOIN(_pathDir,_x),_extension,_recursive,false] call fso_getFiles
			);
		} foreach (_buff select FSO_INDEX_FOLDERS);
		
	};
	if (_internalFlag) then {
		
		if (_extension != stringEmpty) then {
			private _cleanup = false;
			{
				if !([_x,_extension] call stringEndWith) then {
					_cleanup = true;
					_files set [_foreachindex,objNull];
				};
			} foreach _files;
			if (_cleanup) then {
				_files = _files - [objNull];
			};
		};
		
		_files sort true;
	};
	_files
};

#ifdef EDITOR
// тестовая функция для просмотра директорий. параметр _t - строка (путь)
fso_debug_createTreeExample = {
	params ["_t"];
	_disp = [] call displayOpen;
	_bg = _disp ctrlCreate ["RscText", -1];
	_bg ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
	_bg ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
	_bg ctrlCommit 0;
	_ctrl = _disp ctrlCreate ["RscTree", -1];
	_ctrl ctrlSetPosition [0, 0, 1, 1];
	_ctrl ctrlCommit 0;
	
	_checkFSO = {
		params ["_dir","_tvRefPath"];

		private _d = fso_map_tree get _dir;
		if isNullVar(_d) exitWith {};

		//create base tree item
		private _idx = _ctrl tvAdd [_tvRefPath,(_dir splitString "\/") select -1];
		_ctrl tvSetTooltip [_tvRefPath + [_idx],_dir];

		{
			private _newFolder = FSO_PATH_JOIN(_dir,_x);
			[_newFolder,_tvRefPath + [_idx]] call _checkFSO;
		} foreach (_d select FSO_INDEX_FOLDERS);

		//create files in current node
		{
			_ctrl tvAdd [_tvRefPath + [_idx
			],_x];
		} foreach (_d select FSO_INDEX_FILES);
	};

	[_t,[]] call _checkFSO;
};
#endif