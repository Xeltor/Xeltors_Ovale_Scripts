local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "DKBhelp"
	local desc = "[Xel][8.x] Spellhelper: Blood"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_deathknight_marrowrend) # Marrowrend
	Texture(inv_weapon_shortblade_40) # Heart Strike
	Texture(spell_deathknight_butcher2) # Death Strike
	Texture(spell_deathknight_bloodboil) # Blood Boil
	Texture(spell_shadow_deathanddecay) # Death and Decay
	Texture(spell_deathknight_mindfreeze) # Mind Freeze
	Texture(ability_deathknight_asphixiate) # Asphyxiate

	# Buffs
	Texture(spell_shadow_lifedrain) # Vampiric Blood
	Texture(inv_sword_07) # Dancing Rune Weapon
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro

	# Talents
	Texture(ability_animusdraw) # Blooddrinker (T1)
	Texture(spell_deathknight_darkconviction) # Rune Strike (T1)
	Texture(inv_axe_2h_artifactmaw_d_02) # Consumption (T2)
	Texture(ability_fiegndead) # Tombstone (T3)
	Texture(spell_deathknight_runetap) # Rune Tap (T4)
	Texture(ability_hunter_rapidkilling) # Mark of Blood (T6)
	Texture(achievement_boss_lordmarrowgar) # Bonestorm (T7)

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

	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end
