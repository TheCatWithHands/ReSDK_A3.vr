// ======================================================
// Copyright (c) 2017-2024 the ReSDK_A3 project
// sdk.relicta.ru
// ======================================================

loadFile("src\host\GameObjects\GameObject.sqf");
loadFile("src\host\GameObjects\ScriptedGameObject.sqf");

//mobs
loadFile("src\host\GameObjects\Mobs\BasicMob.sqf");
loadFile("src\host\GameObjects\Mobs\Mob.sqf");
loadFile("src\host\GameObjects\Mobs\MobGhost.sqf");

//items
loadFile("src\host\GameObjects\Items\Item.sqf");
loadFile("src\host\GameObjects\Items\Clothes\cloth.sqf");
	loadFile("src\host\GameObjects\Items\Clothes\Armors.sqf");
loadFile("src\host\GameObjects\Items\MeleeWeapons\Axes.sqf");
	loadFile("src\host\GameObjects\Items\MeleeWeapons\Swords.sqf");
	loadFile("src\host\GameObjects\Items\MeleeWeapons\Knives.sqf");
	loadFile("src\host\GameObjects\Items\MeleeWeapons\NonCategory.sqf");
loadFile("src\host\GameObjects\Items\RangedWeapons\RangedWeapon.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Ammo.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Magazines.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Pistols.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Shotguns.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Rifles.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\Grenades.sqf");
	loadFile("src\host\GameObjects\Items\RangedWeapons\AmmoBoxes.sqf");
loadFile("src\host\GameObjects\Items\Medical\Bandages.sqf");
	loadFile("src\host\GameObjects\Items\Medical\Surgery.sqf");
loadFile("src\host\GameObjects\Items\Stackable\Stack.sqf");
loadFile("src\host\GameObjects\Items\Stackable\Money.sqf");
loadFile("src\host\GameObjects\Items\Containers\Container.sqf");
	loadFile("src\host\GameObjects\Items\Containers\Bags.sqf");
	loadFile("src\host\GameObjects\Items\Containers\Backpacks.sqf");
loadFile("src\host\GameObjects\Items\Lighting\Natural.sqf");
	loadFile("src\host\GameObjects\Items\Lighting\Electronic.sqf");
loadFile("src\host\GameObjects\Items\Instruments\Keys.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Chemical.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Radios.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Engineering.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Wires.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Kitchen.sqf");
	loadFile("src\host\GameObjects\Items\Instruments\Cleaning.sqf");
loadFile("src\host\GameObjects\Items\Chairs\ChairItems.sqf");
loadFile("src\host\GameObjects\Items\ReagentContainers\ReagentContainer.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Kitchen.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Glass.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Instruments.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Medical.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Chemical.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Cleanable.sqf");
	loadFile("src\host\GameObjects\Items\ReagentContainers\Pills.sqf");
loadFile("src\host\GameObjects\Items\Bodyparts\Bodyparts.sqf");
	loadFile("src\host\GameObjects\Items\Bodyparts\NonOrganicBodyParts.sqf");
	loadFile("src\host\GameObjects\Items\Bodyparts\Organs.sqf");
	loadFile("src\host\GameObjects\Items\Bodyparts\Skeletal.sqf");
loadFile("src\host\GameObjects\Items\Food\Foods\Food.sqf");
	loadFile("src\host\GameObjects\Items\Food\Foods\Mushrooms.sqf");
loadFile("src\host\GameObjects\Items\Office\Books.sqf");
	loadFile("src\host\GameObjects\Items\Office\Writters.sqf");
	loadFile("src\host\GameObjects\Items\Office\Instruments.sqf");
loadFile("src\host\GameObjects\Items\Traps\Trap.sqf");
loadFile("src\host\GameObjects\Items\Captives\CaptiveBase.sqf");

//structures
loadFile("src\host\GameObjects\Structures\IStruct.sqf");
loadFile("src\host\GameObjects\Structures\Constructions\Construction.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\DirtPiles.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Fences.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Floors.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Rails.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Garbages.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Vegetation.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Houses.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Pipes.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\MetalConstruction.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Poles.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\StepsLadders.sqf");
	loadFile("src\host\GameObjects\Structures\Constructions\Walls.sqf");
loadFile("src\host\GameObjects\Structures\Lighting\Natural.sqf");
	loadFile("src\host\GameObjects\Structures\Lighting\Campfires.sqf");
loadFile("src\host\GameObjects\Structures\Furniture\Furniture.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Shelfs.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Tables.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Chairs.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Beds.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Benches.sqf");
	loadFile("src\host\GameObjects\Structures\Furniture\Sofas.sqf");
loadFile("src\host\GameObjects\Structures\Kitchen\Kitchen.sqf"); //кухня
loadFile("src\host\GameObjects\Structures\Electronics\PowerManagers.sqf");
	loadFile("src\host\GameObjects\Structures\Electronics\Shields.sqf");
	loadFile("src\host\GameObjects\Structures\Electronics\GeneratorParts.sqf");
		loadFile("src\host\GameObjects\Structures\Electronics\Buttons\Buttons.sqf");
		loadFile("src\host\GameObjects\Structures\Electronics\Lamps\Electrical.sqf");
		loadFile("src\host\GameObjects\Structures\Electronics\Lamps\Signs.sqf");
		loadFile("src\host\GameObjects\Structures\Electronics\Radios\Speakers.sqf");
		loadFile("src\host\GameObjects\Structures\Electronics\Devices\Medical.sqf");
			loadFile("src\host\GameObjects\Structures\Electronics\Devices\Control.sqf");
loadFile("src\host\GameObjects\Structures\Doors\Dynamic\DoorDynamic.sqf");
	loadFile("src\host\GameObjects\Structures\Doors\Dynamic\SteelDoors.sqf");
	loadFile("src\host\GameObjects\Structures\Doors\Dynamic\WoodenDoors.sqf");
loadFile("src\host\GameObjects\Structures\Doors\Static\DoorStatic.sqf");
	loadFile("src\host\GameObjects\Structures\Doors\Static\ElectronicDoors.sqf");
	loadFile("src\host\GameObjects\Structures\Doors\Static\SteelDoors.sqf");
loadFile("src\host\GameObjects\Structures\Containers\Container.sqf");
	loadFile("src\host\GameObjects\Structures\Containers\Closets.sqf");
	loadFile("src\host\GameObjects\Structures\Containers\Cabinets.sqf");
	loadFile("src\host\GameObjects\Structures\Containers\Library.sqf");
	loadFile("src\host\GameObjects\Structures\Containers\Boxes.sqf");
	loadFile("src\host\GameObjects\Structures\Containers\Tech.sqf");
loadFile("src\host\GameObjects\Structures\Effects\AtmEffects.sqf");
	loadFile("src\host\GameObjects\Structures\Effects\Teleport.sqf");
	loadFile("src\host\GameObjects\Structures\Effects\Zones.sqf");
loadFile("src\host\GameObjects\Structures\ReagentContainers\ReagentContainer.sqf");
loadFile("src\host\GameObjects\Structures\Tools\Farming.sqf");
	loadFile("src\host\GameObjects\Structures\Tools\DiggingAndMining.sqf");
	loadFile("src\host\GameObjects\Structures\Tools\Spawners.sqf");
loadFile("src\host\GameObjects\Structures\Interiors\SmallDecorations.sqf");
	loadFile("src\host\GameObjects\Structures\Interiors\InteractibleInteriors.sqf");


//decorations
loadFile("src\host\GameObjects\Decors\Decor.sqf");
loadFile("src\host\GameObjects\Decors\Blocks\Blocks.sqf");
loadFile("src\host\GameObjects\Decors\Ruins.sqf");
loadFile("src\host\GameObjects\Decors\BigWalls.sqf");
loadFile("src\host\GameObjects\Decors\Stones.sqf");
loadFile("src\host\GameObjects\Decors\Houses.sqf");
