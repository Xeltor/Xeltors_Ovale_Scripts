local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "DKFhelp"
	local desc = "[Xel][7.x] Spellhelper: Frost"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_deathknight_classicon) # Obliterate
	Texture(spell_deathknight_empowerruneblade2) # Frost STrike
	Texture(spell_frost_arcticwinds) # Howling Blast
	Texture(spell_frost_chainsofice) # Chains of Ice
	Texture(ability_deathknight_remorselesswinters2) # Remorseless Winter
	Texture(spell_deathknight_mindfreeze) # Mind Freeze
	Texture(spell_deathknight_butcher2) # Death Strike

	# Buffs
	Texture(ability_deathknight_pillaroffrost) # Pillar of Frost
	Texture(spell_deathknight_iceboundfortitude) # Icebound Fortitude
	Texture(inv_sword_62) # Empower Rune Weapon
	
	# Artifact
	Texture(achievement_boss_sindragosa) # Sindragosa's Fury

	# Talents
	Texture(inv_misc_horn_02) # Horn of Winter (T2)
	Texture(ability_hunter_glacialtrap) # Glacial Advance (T3)
	Texture(spell_frost_chillingblast) # Blinding Sleet (T4)
	Texture(inv_misc_2h_farmscythe_a_01) # Frostscythe (T6)
	Texture(inv_axe_114) # Obliteration (T7)
	Texture(spell_deathknight_breathofsindragosa) # Breath of Sindragosa(T7)
	Texture(ability_deathknight_hungeringruneblade) # Hungering Rune Weapon (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night elf)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "frost", name, desc, code, "script")
end
