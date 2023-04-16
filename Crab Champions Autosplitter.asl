/*
Created by Mitz, find me on the official Discord!
v0.12
for version Early Access 1772 - Update 3
*/

state("CrabChampions-Win64-Shipping")
{
	//level and gamestate are actually both stored as 4 bytes, in case you want to search in CE easier.
	byte level : 0x04299B00, 0x148, 0x98, 0xA8, 0xB10, 0x540, 0x80, 0x2A8;
	byte gamestate : 0x04299B00, 0x148, 0x98, 0xA8, 0xB10, 0x540, 0x80, 0x278;
	
	//this is only a readout of the current health, not the actual health
	float health : 0x04299B00, 0x38, 0x140, 0x118, 0x280, 0x238, 0x0, 0x38C;
}

init{
	print("[CrabAutoSplit] INIT");
}

startup{
	print("[CrabAutoSplit] STARTUP");
	settings.Add("comment", true, "Only use one at a time!");
	settings.Add("split1", false, "Split Every Level", "comment");
	settings.Add("split5", true, "Split Every 5 Levels (Default)", "comment");
	settings.Add("split10", false, "Split Every 10 Levels", "comment");
	settings.Add("split15", false, "Split Every 15 Levels", "comment");
}

update{
	return true;
}

/*
gamestate 1: lobby
gamestate 2: loading (between levels)
gamestate 3: island in progress
gamestate 4: island complete
gamestate 5: activated victory crown
gamestate 6: victory screen, death screen
gamestate 7: loading (crab splash screen)
*/

start{
	//level 0 is lobby
	if (current.level == 0 & current.gamestate == 2) {
		print("[CrabAutoSplit] START");
		return true;
	};
}

isLoading{
	if(current.gamestate == 2){
		return true;
	};
	if(current.gamestate != 2){
		return false;
	};
}

split{
	//detect level change (0 check is to prevent it from spamming splits when starting a new run)
	if (current.level != old.level & old.level > 0) {
			print("[CrabAutoSplit] LEVEL CHANGED!");
			if (settings["split15"] == true) {  
				print("[CrabAutoSplit] 15 SPLIT ENABLED");
				if ((current.level - 1) % 15 == 0) {
					print("[CrabAutoSplit] SPLIT DONE!");
					return true;
				};
			};
			if (settings["split10"] == true) {
				print("[CrabAutoSplit] 10 SPLIT ENABLED");
				if ((current.level - 1) % 10 == 0) {
					print("[CrabAutoSplit] SPLIT DONE!");
					return true;
				};
			};
			if (settings["split5"] == true) {  
				print("[CrabAutoSplit] 5 SPLIT ENABLED");
				if ((current.level - 1) % 5 == 0) {
					print("[CrabAutoSplit] SPLIT DONE!");
					return true;
				};
			};
			
			if (settings["split1"] == true) {  
				print("[CrabAutoSplit] SPLIT AT 1");
				print("[CrabAutoSplit] SPLIT DONE!");
				return true;
			};
			
			//in case no settings are picked, for some reason
			print("[CrabAutoSplit] NO SPLIT DONE BY US");
			return false;
	};
	//TODO: Make sure this doesn't split if you die at level 30. Currently the game seems to set your health to 1 even when you're dead? This could potentially trigger splits at death instead of only victory 
	if (current.gamestate == 6 & current.level%30 == 0 & current.health > 1) {
		print("[CrabAutoSplit] VICTORY SCREEN");
		return true;
	};
}

reset{
	if (current.gamestate == 7) {
	print("[CrabAutoSplit] SPLITS RESET");
	return true;
	};
}
