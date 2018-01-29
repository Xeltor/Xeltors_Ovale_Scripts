local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "ROGUESTABBY"
	local desc = "[Xel][7.x] Spellhelper: Stabby (Assassination)"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_rogue_shadowstrikes) # Mutilate
	Texture(ability_rogue_garrote) # Garrote
	Texture(ability_rogue_rupture) # Rupture
	Texture(ability_rogue_disembowel) # Envenom
	Texture(ability_rogue_fanofknives) # Fan of Knives
	Texture(ability_kick) # Kick
	Texture(ability_rogue_kidneyshot) # Kidney Shot
	Texture(ability_cheapshot) # Cheap Shot

	# Artifact
	Texture(inv_knife_1h_artifactgarona_d_01) # Kingsbane
	
	# Buffs
	Texture(ability_stealth) # Stealth
	Texture(ability_rogue_deadliness) # Vendetta
	Texture(ability_vanish) # Vanish
	Texture(ability_rogue_crimsonvial) # Crimson Vial
	Texture(ability_rogue_shadowstep) # Shadow Step

	# Talents
	Texture(spell_shadow_lifedrain) # Hemorrhage (T1)
	Texture(rogue_leeching_poison) # Leeching Poison (T4)
	Texture(inv_weapon_shortblade_62) # Toxic Blade (T6)
	Texture(ability_deathwing_bloodcorruption_earth) # Exsanguinate (T6)
	Texture(achievement_bg_killingblow_berserker) # Marked for Death (T7)
	Texture(spell_rogue_deathfromabove) # Death from Above (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "assassination", name, desc, code, "script")
end
