local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "MBMhelp"
	local desc = "[Xel][BROKEN] Spellhelper: Brewmaster"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_monk_jab) # Jab Fist
	Texture(ability_monk_staffstrike) # Jab Staff
	Texture(inv_sword_10) # Jab Sword
	Texture(inv_mace_08) # Jab Mace
	Texture(inv_spear_03) # Jab Polearm
	Texture(inv_axe_97) # Jab Axe
	Texture(achievement_brewery_2) # Keg Smash
	Texture(ability_monk_tigerpalm) # Tiger Palm
	Texture(ability_monk_roundhousekick) # Blackout Kick
	Texture(ability_monk_breathoffire) # Breath of Fire
	Texture(ability_monk_expelharm) # Expel Harm
	Texture(ability_monk_touchofdeath) # Touch of Death
	Texture(ability_monk_cranekick_new) # Spinning Crane Kick
	Texture(ability_monk_spearhand) # Spear Hand Strike
	Texture(ability_monk_paralysis) # Paralysis

	# Buffs
	Texture(ability_monk_guard) # Guard
	Texture(ability_monk_elusiveale) # Elusive Brew
	Texture(ability_monk_fortifyingale_new) # Fortifying Brew
	Texture(inv_misc_beer_06) # Purifying Brew
	Texture(spell_monk_nimblebrew) # Nimble Brew
	Texture(ability_monk_prideofthetiger) # Legacy of the White Tiger

	# Talents
	Texture(ability_monk_chiwave) # Chi Wave (T2)
	Texture(ability_monk_forcesphere) # Zen Sphere (T2)
	Texture(spell_arcane_arcanetorrent) # Chi Burst (T2)
	Texture(ability_monk_chibrew) # Chi Brew (T3)
	Texture(ability_monk_dampenharm) # Dampen Harm (T5)
	Texture(ability_monk_rushingjadewind) # Rushing Jade Wind (T6)
	Texture(ability_monk_summontigerstatue) # Invoke Xuen, the White Tiger (T6)
	Texture(ability_monk_chiexplosion) # Chi Explosion (T7)
	Texture(ability_monk_serenity) # Serenity (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end
