local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Xelhelpmark"
	local desc = "[Xel][7.0.3] Spellhelper: Marksman"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_impalingbolt) # Arcane Shot
	Texture(inv_spear_07) # Aimed Shot
	Texture(ability_hunter_markedshot) # Marked Shot
	Texture(ability_upgrademoonglaive) # Multi-Shot
	Texture(ability_hunter_burstingshot) # Bursting Shot
	Texture(inv_ammo_arrow_03) # Counter Shot

	# Buffs
	Texture(ability_trueshot) # True Shot
	Texture(ability_hunter_onewithnature) # Exhilaration
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro
	
	# Heart of Azeroth Skills
	Texture(spell_azerite_essence_15) # Concentrated Flame
	Texture(spell_azerite_essence05) # Memory of Lucid Dreams
	Texture(inv__azerite-explosion) # Blood of the Enemy
	Texture(spell_azerite_essence14) # Guardian of Azeroth
	Texture(spell_azerite_essence12) # Focused Azerite Beam
	Texture(spell_azerite_essence04) # Purifying Blast
	Texture(spell_azerite_essence10) # Ripple in Space
	Texture(spell_azerite_essence03) # The Unbound Force
	Texture(inv_misc_azerite_01) # Worldvein Resonance

	# Talents
	Texture(spell_shadow_painspike) # Black Arrow (T2)
	Texture(ability_hunter_explosiveshot) # Explosive Shot (T4)
	Texture(spell_nature_sentinal) # Sentinel (T4)
	Texture(spell_shaman_bindelemental) # Binding Shot (T5)
	Texture(inv_spear_02) # Wyvern Sting (T5)
	Texture(ability_hunter_camouflage) # Camouflage (T5)
	Texture(ability_hunter_murderofcrows) # A Murder of Crows (T6)
	Texture(ability_hunter_rapidregeneration) # Barrage (T6)
	Texture(ability_marksmanship) # Volley (T6)
	Texture(ability_hunter_serpentswiftness) # Sidewinders (T7)
	Texture(ability_cheapshot) # Piercing Shot (T7)

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

	OvaleScripts:RegisterScript("HUNTER", "marksmanship", name, desc, code, "script")
end
