local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "MAGEARCANE"
	local desc = "[Xel][BROKEN] Spellhelper: Arcane"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_arcane_blast) # Arcane Blast
	Texture(ability_mage_arcanebarrage) # Arcane Barrage
	Texture(spell_nature_starfall) # Arcane Missiles
	Texture(spell_frost_glacier) # Cone of Cold
	Texture(spell_nature_wispsplode) # Arcane Explosion
	Texture(spell_frost_iceshock) # Counterspell

	# Buffs
	Texture(spell_holy_magicalsentry) # Arcane Brilliance
	Texture(spell_nature_lightning) # Arcane Power
	Texture(spell_nature_enchantarmor) # Presence of Mind
	Texture(spell_nature_purge) # Evocation

	# Talents
	Texture(spell_mage_iceflows) # Ice Floes (T1)
	Texture(spell_ice_lament) # Ice Barrier (T2)
	Texture(ability_mage_frostjaw) # Frostjaw (T3)
	Texture(spell_frost_wizardmark) # Cold Snap (T4)
	Texture(spell_mage_nethertempest) # Nether Tempest (T5)
	Texture(spell_mage_supernova) # Supernova (T5)
	Texture(spell_magic_lesserinvisibilty) # Mirror Image (T6)
	Texture(spell_mage_focusingcrystal) # Prismatic Crystal (T7)
	Texture(spell_mage_arcaneorb) # Arcane Orb (T7)

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
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("MAGE", "arcane", name, desc, code, "script")
end
