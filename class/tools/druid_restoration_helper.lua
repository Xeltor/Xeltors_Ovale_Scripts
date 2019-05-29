local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Restorationhelper"
	local desc = "[Xel][8.x] Spellhelper: Restoration"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(inv_misc_herb_felblossom) # Lifebloom
	Texture(spell_nature_rejuvenation) # Rejuvenation
	Texture(spell_nature_resistnature) # Regrowth
	Texture(inv_relics_idolofrejuvenation) # Swiftmend
	Texture(ability_druid_flourish) # Wild Growth
	Texture(spell_nature_tranquility) # Tranquility
	Texture(spell_nature_reincarnation) # Rebirth
	Texture(ability_druid_empoweredtouch) # Revitalize
	Texture(ability_mage_firestarter) # Sunfire
	Texture(spell_nature_starfall) # Moonfire
	Texture(spell_nature_wrathv2) # Solar Wrath
	
	# Buffs
	Texture(ability_druid_catform) # Cat Form
	Texture(ability_druid_travelform) # Travel Form
	Texture(spell_druid_ironbark) # Ironbark
	Texture(spell_nature_lightning) # Innervate
	
	# Chicken talent
	Texture(spell_nature_forceofnature) # Moonkin Form
	Texture(spell_arcane_starfire) # Lunar Strike
	Texture(spell_arcane_arcane03) # Starsurge
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro
	
	# Talents
	Texture(ability_druid_naturalperfection) # Cenarion Ward (T1)
	Texture(spell_nature_natureblessing) # Renewal (T2)
	Texture(ability_druid_bash) # Mighty Bash (T4)
	Texture(ability_druid_typhoon) # Typhoon (T4)
	Texture(ability_druid_improvedtreeform) # Incarnation: Tree of Life (T5)
	Texture(spell_druid_wildburst) # Flourish (T7)
	
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
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	# Party auto targeting system
	Texture(misc_arrowdown) # Bind to F1 (target self)
	Texture(ships_ability_boardingparty) # Bind to F2 (target party member 2)
	Texture(ships_ability_boardingpartyalliance) # Bind to F3 (target party member 3)
	Texture(ships_ability_boardingpartyhorde) # Bind to F4 (target party member 4)
	Texture(inv_helm_misc_starpartyhat) # Bind to F5 (target party member 5)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
