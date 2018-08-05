local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Xelhelpcombined"
	local desc = "[Xel] Spellhelper: Combined"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_hunter_cobrashot) # Cobra Shot (BM)
	Texture(ability_hunter_killcommand) # Kill Command (BM)
	Texture(ability_upgrademoonglaive) # Multi-Shot (BM & Marks)
	Texture(ability_hunter_longevity) # Dire Beast (BM)
	Texture(ability_impalingbolt) # Arcane Shot (Marks)
	Texture(inv_spear_07) # Aimed Shot (Marks)
	Texture(ability_hunter_markedshot) # Marked Shot (Marks)
	Texture(ability_hunter_burstingshot) # Bursting Shot (Marks)
	Texture(ability_hunter_raptorstrike) # Raptor Strike (Surv)
	Texture(ability_hunter_mongoosebite) # Mongoose Bite (Surv)
	Texture(ability_hunter_invigeration) # Flanking Strike (Surv)
	Texture(ability_hunter_laceration) # Lacerate (Surv)
	Texture(ability_hunter_carve) # Carve (Surv)
	Texture(spell_fire_selfdestruct) # Explosive Trap (Surv)
	Texture(ability_hunter_harpoon) # Harpoon (Surv)
	Texture(ability_hunter_negate) # Muzzle (Surv)
	Texture(inv_ammo_arrow_03) # Counter Shot (BM & Marks)

	# Buffs
	Texture(spell_nature_protectionformnature) # Aspect of the Wild (BM)
	Texture(ability_trueshot) # True Shot (Marks)
	Texture(spell_hunter_aspectoftheironhawk) # Aspect of the Eagle (Surv)
	Texture(ability_druid_ferociousbite) # Bestial Wrath (BM)
	Texture(ability_hunter_onewithnature) # Exhilaration (All specs)
	Texture(ability_hunter_mendpet) # Mend Pet (BM & Surv)
	Texture(inv_misc_pheonixpet_01) # Heart of the Phoenix (BM & Surv)
	Texture(ability_hunter_beastsoothe) # Revive Pet (BM & Surv)
	Texture(icon_orangebird_toy) # Call Pet (BM & Surv)
	
	# Artifact
	Texture(inv_firearm_2h_artifactlegion_d_01) # Titan's Thunder (BM)
	Texture(inv_bow_1h_artifactwindrunner_d_02) # Windburst (Marks)
	Texture(inv_polearm_2h_artifacteagle_d_01) # Fury of the Eagle (Surv)

	# Talents
	Texture(inv_throwingaxepvp320_07) # Throwing Axes (T1) (Surv)
	Texture(ability_druid_mangle) # Dire Frenzy (T2) (BM) (replaces Dire Beast)
	Texture(ability_hunter_chimerashot2) # Chimaera Shot (T2) (BM)
	Texture(spell_shadow_painspike) # Black Arrow (T2) (Marks)
	Texture(ability_hunter_murderofcrows) # A Murder of Crows (T2 & T6) (Surv & BM, Marks)
	Texture(achievement_boss_epochhunter) # Snake Hunter (T2) (Surv)
	Texture(spell_nature_sentinal) # Sentinel (T4) (Marks)
	Texture(ability_ironmaidens_incindiarydevice) # Caltrops (T4) (Surv)
	Texture(inv_pet_pettrap02) # Steel Trap (T4) (Surv)
	Texture(spell_shaman_bindelemental) # Binding Shot (T5) (BM & Marks)
	Texture(inv_spear_02) # Wyvern Sting (T5) (BM & Marks)
	Texture(ability_devour) # Intimidation (T5) (BM)
	Texture(ability_hunter_camouflage) # Camouflage (T5) (Marks & Surv)
	Texture(inv_misc_bomb_08) # Sticky Bomb (T5) (Surv)
	Texture(inv_misc_net_01) # Ranger's Net (T5) (Surv)
	Texture(ability_hunter_rapidregeneration) # Barrage (T6) (BM & Marks)
	Texture(ability_marksmanship) # Volley (T6) (BM & Marks)
	Texture(ability_butcher_cleave) # Butchery (T6) (Surv)
	Texture(spell_fire_incinerate) # Dragonsfire Grenade (T6) (Surv)
	Texture(ability_hunter_bestialdiscipline) # Stampede (T7) (BM)
	Texture(ability_hunter_serpentswiftness) # Sidewinders (T7) (Marks) (replaces Arcane Shot & Multi-shot)
	Texture(ability_cheapshot) # Piercing Shot (T7) (Marks)
	Texture(ability_hunter_cobrastrikes) # Spitting Cobra (T7) (Surv)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_ambush) # Shadowmeld (Night elf)
}



































































]]

	OvaleScripts:RegisterScript("HUNTER", "all", name, desc, code, "script")
end
