local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_restoration"
	local desc = "[Xel][7.1.5] Druid: Restoration"
	local code = [[
# Based on XeltorCraft profile "I_AM_AWESOME".
#	class=druid
#	spec=restoration
	
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

Define(ironbark 102342)
	SpellInfo(ironbark cd=90)
Define(dream_of_cenarius_talent 17)
Define(lifebloom 33763)
	SpellAddTargetBuff(lifebloom lifebloom_buff=1)
Define(lifebloom_buff 33763)
	SpellInfo(lifebloom_buff duration=15)
Define(soul_of_the_forest_buff 114108)
	SpellInfo(soul_of_the_forest_buff duration=15)
Define(rejuvenation_buff 774)
	SpellInfo(rejuvenation_buff duration=15)
Define(cultivation_buff 200389)
	SpellInfo(cultivation_buff duration=6)
Define(wild_growth 48438)
	SpellInfo(wild_growth cd=10)
	SpellAddTargetBuff(wild_growth wild_growth_buff=1)
Define(wild_growth_buff 48438)
Define(flourish 197721)
	SpellInfo(flourish cd=60)
Define(clearcasting_restoration_buff 16870)
	SpellInfo(clearcasting_restoration_buff duration=15)
Define(starsurge_restoration 197626)
	SpellInfo(starsurge_restoration cd=10 astralpower=0)
	SpellAddBuff(starsurge_restoration lunar_empowerment_buff=1)
	SpellAddBuff(starsurge_restoration solar_empowerment_buff=1)
Define(travel_form 783)
Define(travel_form_buff 783)
Define(essence_of_ghanir 208253)
	SpellInfo(essence_of_ghanir cd=90)
Define(cenarion_ward 102351)
	SpellInfo(cenarion_ward cd=30)
	SpellAddTargetBuff(cenarion_ward cenarion_ward_buff=1)
Define(cenarion_ward_buff 102351)
Define(regrowth_restoration 8936)
	SpellAddTargetBuff(regrowth_restoration regrowth_buff=1)
	SpellAddBuff(regrowth_restoration clearcasting_restoration_buff=-1)

AddIcon specialization=4 help=main
{
	if not { Stance(3) }
	{
		if HealthPercent() < 70 Spell(renewal)
		if Stance(druid_moonkin_form) and HealthPercent() < 50 and SpellCooldown(renewal) >= CastTime(regrowth) and Speed() == 0 Spell(regrowth)
	}

	if target.Present() and target.Exists() and { target.InRange(lifebloom) or target.InRange(moonfire) } and not { mounted() or Stance(3) }
	{
		if target.IsFriend() Healing()
	}
	
	Travel()
}
AddCheckBox(groupHealz "Group Healer" specialization=4)
# AddCheckBox(noDeeps "Dont DPS" specialization=4)

# Travel!
AddFunction Travel
{
	if not InCombat() and Speed() > 0
	{
		if not Stance(3) and not Indoors() Spell(travel_form)
		# if not Stance(3) and not Stance(druid_cat_form) and not Wet() and Indoors() Spell(cat_form)
	}
}

AddFunction HasFocus
{
	focus.Present() and focus.Exists() and focus.InRange(lifebloom)
}

AddFunction Healing
{
	# Drop form if we are in one.
	if Stance(druid_moonkin_form) Texture(spell_nature_forceofnature)
	if Stance(druid_cat_form) Texture(ability_druid_catform)
	if Stance(druid_bear_form) Texture(ability_racial_bearform)
	
	# Extend Wild Growth as per Icy veins recommendation.
	if PreviousGCDSpell(wild_growth) Spell(flourish)
	# Boost Wild Growth as per Icy veins recommendation.
	if PreviousGCDSpell(flourish) Spell(essence_of_ghanir)
	
	# Oh shit.
	if focus.HealthPercent() <= 35 and HasFocus() Spell(ironbark)
	if target.HealthPercent() <= 45
	{
		# Use on anyone unless we have a focus.
		if not HasFocus() and target.HealthPercent() <= 35 Spell(ironbark)
		Spell(swiftmend)
	}
	
	# Hots.
	if HasFocus() and { focus.BuffRemaining(lifebloom_buff) <= CastTime(healing_touch) or not focus.BuffPresent(lifebloom_buff) } Spell(lifebloom)
	if target.HealthPercent() <= 99 and { not target.BuffPresent(rejuvenation_buff) or target.BuffRemaining(rejuvenation_buff) <= CastTime(healing_touch) } Spell(rejuvenation)
	
	# Healing.
	if target.HealthPercent() <= 85
	{
		# Cenarion Ward the tank.
		if HasFocus() and not focus.BuffPresent(cenarion_ward_buff) Spell(cenarion_ward)
		# Cenarion Ward.
		if not HasFocus() and target.BuffPresent(cenarion_ward_buff) Spell(cenarion_ward)
		# Use berserking for extra casting speed.
		if Speed() == 0 and target.HealthPercent() <= 45 Spell(berserking)
		# Many targets need healing.
		if { BuffCountOnAny(cultivation_buff) >= 3 or CheckBoxOn(groupHealz) } and Speed() == 0 Spell(wild_growth)
		# Procced regrowth gets pref.
		if { BuffRemaining(clearcasting_restoration_buff) >= CastTime(regrowth_restoration) or target.HealthPercent() <= 45 } and Speed() == 0 Spell(regrowth_restoration)
		# Healing touch
		if Speed() == 0 Spell(healing_touch)
	}
	
	# Germination.
	if Talent(germination_talent) and target.BuffCount(rejuvenation_buff) < 2 Spell(rejuvenation)
}

AddFunction Dpsing
{
	# Boomkin time.
	unless Stance(druid_moonkin_form) Spell(moonkin_form)
	
	# Dots.
	#moonfire
	if target.DebuffRemaining(moonfire_debuff) < 3 Spell(moonfire)
	#sunfire
	if target.DebuffRemaining(sunfire_debuff) < 3 Spell(sunfire)
	if Speed() == 0
	{
		Spell(starsurge_restoration)
		if Enemies(tagged=1) > 1 or BuffPresent(lunar_empowerment_buff) Spell(lunar_strike)
		Spell(solar_wrath)
	}
}
]]
	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
