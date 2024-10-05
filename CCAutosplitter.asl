state("CrabChampions-Win64-Shipping") {
	// 1: lobby
	// 2: loading (between levels)
	// 3: island in progress
	// 4: island complete
	// 5: activated victory crown
	// 6: victory screen, death screen
	// 7: loading (crab splash screen)
	uint  gamestate : 0x043D8FB8, 0x120, 0x278;
	
	uint  level     : 0x043D8FB8, 0x120, 0x2BC;
	float health    : 0x043C1570, 0x30, 0x228, 0x38C; // read-out of the current health, not the actual health
}

startup {
	settings.Add("splits", true, "Split on level completion (only check one):");
		settings.Add("split1", false, "Every Level", "splits");
		//settings.Add("split4", true, "Every 4 Levels", "splits");
		settings.Add("split7", false, "Every 7 Levels", "splits");
		settings.Add("split14", false, "Every 14 Levels", "splits");
	settings.Add("splitboss", false, "Split bosses separately (i.e: 6, boss, 8... instead of: 7, 14, 21...)");
}

start {
	return old.gamestate == 1 && current.gamestate == 2
		&& current.level == 0;
}

split {
	bool BossSetting = settings["splitboss"];
	switch (BossSetting) {
		case true: //boss setting is ON

			//detect if we went to the boss level (check against old.level 0 to avoid splitting at start)
			if (old.level != current.level && old.level > 0 && current.level % 7 == 0) {
				return true;
			}

			//run normal split logic otherwise
			else { 
				// detect level change (check against old.level 0 to avoid splitting at start)
				if (old.level != current.level && old.level > 0) {
				uint lvl = current.level - 1;
				return settings["split1"]
					//|| settings["split4"] && lvl % 4 == 0
					|| settings["split7"] && lvl % 7 == 0
					|| settings["split14"] && lvl % 14 == 0;
				}
			}
			break;

		case false: //boss setting is OFF, so we run normal split logic

			// detect level change (check against 0 to avoid splitting at start)
			if (old.level != current.level && old.level > 0) {
			uint lvl = current.level - 1;
			return settings["split1"]
				//|| settings["split4"] && lvl % 4 == 0
				|| settings["split7"] && lvl % 7 == 0
				|| settings["split14"] && lvl % 14 == 0;
			}
			break;

		default:
			return false;
			break;
	};

	// Split for winning the game!
	// TODO: Make sure this doesn't split if you die at the boss level.
	// Currently the game seems to set your health to 1 even when you're dead.
	// This could potentially trigger splits incorrectly, but has yet to be reported...
	if (old.gamestate != 6 && current.gamestate == 6 && current.health > 1) {
		return current.level == 28
			|| current.level == 56
			|| current.level == 84
			|| current.level == 112;
	}
}

reset {
	return old.gamestate != 7 && current.gamestate == 7;
}

isLoading {
	return current.gamestate == 2;
}
