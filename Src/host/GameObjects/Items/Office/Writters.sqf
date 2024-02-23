// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

#include <..\..\..\engine.hpp>
#include <..\..\..\oop.hpp>
#include <..\..\GameConstants.hpp>

editor_attribute("InterfaceClass")
class(ItemWritter) extends(Item)
	var(name,"Писало");
	var(color,"000000");
	
	func(applyColorToText)
	{
		objParams_1(_txt);
		(format["<t color='#%1'>",getSelf(color)]) + _txt + "</t>";
	};
endclass

class(PenBlack) extends(ItemWritter)
	var(name,"Ручка");
	var(model,"a3\structures_f\items\stationery\penblack_f.p3d");
	var(allowedSlots,[INV_FACE]);
	var(color,"000000");
endclass

class(PenRed) extends(PenBlack)
	var(model,"a3\structures_f\items\stationery\penred_f.p3d");
	var(color,"FF0000");
endclass

