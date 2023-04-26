state("CrabChampions-Win64-Shipping") {
	// 1: lobby
	// 2: loading (between levels)
	// 3: island in progress
	// 4: island complete
	// 5: activated victory crown
	// 6: victory screen, death screen
	// 7: loading (crab splash screen)
	int   gamestate : 0x0429AC40, 0x120, 0x278;
	
	int   level     : 0x0429AC40, 0x120, 0x2A8;
	float health    : 0x04283260, 0x30, 0x228, 0x38C; // read-out of the current health, not the actual health
}

startup {
	settings.Add("splits", true, "Split on level completion (only check one):");
		settings.Add("split1", false, "Every Level", "splits");
		settings.Add("split5", true, "Every 5 Levels", "splits");
		settings.Add("split10", false, "Every 10 Levels", "splits");
		settings.Add("split15", false, "Every 15 Levels", "splits");
}

start {
	return old.gamestate == 1 && current.gamestate == 2
		&& current.level == 0;
}

split {
	// detect level change (check against 0 to avoid splitting at start)
	if (old.level != current.level && old.level > 0) {
		int lvl = current.level - 1;

		return settings["split1"]
			|| settings["split5"] && lvl % 5 == 0
			|| settings["split10"] && lvl % 10 == 0
			|| settings["split15"] && lvl % 15 == 0;
	}


	// TODO: Make sure this doesn't split if you die at the boss level.
	// Currently the game seems to set your health to 1 even when you're dead?
	// This could potentially trigger splits at death instead of only victory
	//
	if (old.gamestate != 6 && current.gamestate == 6 && current.health > 1) {
		return current.level == 30
			|| current.level == 60
			|| current.level == 90
			|| current.level == 120;
	}
}

reset {
	return old.gamestate != 7 && current.gamestate == 7;
}

isLoading {
	return current.gamestate == 2;
}
