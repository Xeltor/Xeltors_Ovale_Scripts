local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "ROGUESHANKY"
	local desc = "[Xel][8.x] Spellhelper: Shanky (Subtlety)"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_backstab) # Backstab
	Texture(ability_rogue_shadowstrike) # Shadowstrike
	Texture(ability_rogue_eviscerate) # Eviscerate
	Texture(ability_rogue_nightblade) # Nightblade
	Texture(ability_rogue_shurikenstorm) # Shuriken Storm
	Texture(ability_kick) # Kick
	Texture(ability_rogue_kidneyshot) # Kidney Shot
	Texture(ability_cheapshot) # Cheap Shot

	# Buffs
	Texture(ability_stealth) # Stealth
	Texture(ability_rogue_shadowstep) # Shadowstep
	Texture(spell_shadow_rune) # Symbols of Death
	Texture(ability_rogue_crimsonvial) # Crimson Vial
	Texture(ability_rogue_shadowdance) # Shadow Dance
	Texture(ability_vanish) # Vanish
	Texture(inv_knife_1h_grimbatolraid_d_03) # Shadow Blades
	
	# Talents
	Texture(ability_ironmaidens_convulsiveshadows) # Gloomblade (T1) (Replaces Backstab)
	Texture(achievement_bg_killingblow_berserker) # Marked for Death (T3)
	Texture(ability_rogue_sinistercalling) # Secret Technique (T7)
	Texture(ability_rogue_throwingspecialization) # Shuriken Tornado (T7)

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

	OvaleScripts:RegisterScript("ROGUE", "subtlety", name, desc, code, "script")
end
