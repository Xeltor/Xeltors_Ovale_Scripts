local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WARRFURYhelp"
	local desc = "[Xel][7.0.3] Spellhelper: Fury"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_whirlwind) # Whirlwind
	Texture(ability_warrior_weaponmastery) # Furious Slash
	Texture(spell_nature_bloodlust) # Bloodthirst
	Texture(warrior_wild_strike) # Raging Blow
	Texture(inv_sword_48) # Execute
	Texture(ability_warrior_rampage) # Rampage
	Texture(ability_warrior_charge) # Charge
	Texture(inv_axe_66) # Heroic Throw
	Texture(inv_gauntlets_04) # Pummel

	# Buffs
	Texture(warrior_talent_icon_innerrage) # Battle Cry
	Texture(spell_nature_ancestralguardian) # Berserker Rage

	# Artifact
	Texture(inv_sword_1h_artifactvigfus_d_01) # Odyn's Fury

	# Talents
	Texture(ability_warrior_shockwave) # Shockwave (T2)
	Texture(warrior_talent_icon_stormbolt) # Storm Bolt (T2)
	Texture(warrior_talent_icon_avatar) # Avatar (T3)
	Texture(ability_warrior_defensivestance) # Defensive Stance (T4)
	Texture(ability_warrior_focusedrage) # Focused Rage (T5)
	Texture(ability_warrior_bloodbath) # Bloodbath (T6)
	Texture(ability_warrior_bladestorm) # Bladestorm (T7)
	Texture(ability_warrior_dragonroar) # Dragon Roar (T7)

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
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "fury", name, desc, code, "script")
end
