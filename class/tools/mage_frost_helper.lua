local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "MAGEFROST"
	local desc = "[Xel][7.x] Spellhelper: Frost"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_frost_frostbolt02) # Frostbolt
	Texture(spell_frost_frostblast) # Ice Lance
	Texture(ability_warlock_burningembersblue) # Flurry
	Texture(spell_frost_frozenorb) # Frozen Orb
	Texture(spell_frost_icestorm) # Blizzard

	# Pet skills (For non lonely winter rotation)
	Texture(ability_vehicle_sonicshockwave) # Water Jet (DO NOT SET TO AUTOCAST)
	
	# Buffs
	Texture(spell_frost_coldhearted) # Icy Veins
	Texture(spell_ice_lament) # Ice Barrier
	Texture(ability_mage_timewarp) # Time Warp

	# Artifact
	Texture(artifactability_frostmage_ebonbolt) # Ebonbolt

	# Talents
	Texture(ability_mage_rayoffrost) # Ray of Frost (T1)
	Texture(spell_arcane_massdispel) # Shimmer (T2)
	Texture(spell_mage_iceflows) # Ice Floes (T2)
	Texture(spell_magic_lesserinvisibilty) # Mirror Image (T3)
	Texture(spell_mage_runeofpower) # Rune of Power (T3)
	Texture(spell_mage_icenova) # Ice Nova (T4)
	Texture(ability_mage_coldasice) # Frozen Touch (T4)
	Texture(spell_mage_frostbomb) # Frost Bomb (T6)
	Texture(ability_mage_glacialspike) # Glacial Spike (T7)
	Texture(spell_mage_cometstorm) # Comet Storm (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
}
]]

	OvaleScripts:RegisterScript("MAGE", "frost", name, desc, code, "script")
end
