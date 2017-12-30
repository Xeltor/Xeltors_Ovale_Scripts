local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "ROGUEPOKEY"
	local desc = "[Xel][7.1.5] Spellhelper: Pokey (Outlaw)"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_rogue_sabreslash) # Saber Slash
	Texture(ability_rogue_ambush) # Ambush (Stealth only)
	Texture(ability_rogue_pistolshot) # Pistol Shot
	Texture(inv_weapon_rifle_07) # Blunderbuss (Replaces Pistol Shot)
	Texture(inv_weapon_rifle_01) # Between the Eyes
	Texture(ability_rogue_waylay) # Run Through
	Texture(ability_kick) # Kick
	Texture(ability_gouge) # Gouge

	# Artifact
	Texture(inv_sword_1h_artifactskywall_d_01dual) # Curse of the Dreadblades
	
	# Buffs
	Texture(ability_rogue_rollthebones) # Roll the Bones
	Texture(spell_shadow_nethercloak) # Cloak of Shadows
	Texture(ability_stealth) # Stealth
	Texture(ability_vanish) # Vanish
	Texture(spell_shadow_shadowworddominate) # Adrenaline Rush
	Texture(ability_rogue_crimsonvial) # Crimson Vial
	Texture(ability_warrior_punishingblow) # Blade Flurry On
	Texture(ability_warrior_warbringer) # Blade Flurry Off
	Texture(ability_rogue_sprint) # Sprint

	# Talents
	Texture(ability_creature_cursed_02) # Ghostly Strike (T1)
	Texture(ability_rogue_cannonballbarrage) # Cannonball Barrage (T6)
	Texture(ability_rogue_murderspree) # Killing Spree (T6)
	Texture(ability_rogue_slicedice) # Slice and Dice (T7)
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

	OvaleScripts:RegisterScript("ROGUE", "outlaw", name, desc, code, "script")
end
