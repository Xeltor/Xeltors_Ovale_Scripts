local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_restoration"
	local desc = "[Xel][7.2.5] Druid: Restoration"
	local code = [[
# Required macros (every line is a macro)
# /cast [@focus, help][@target, help] Ironbark
# /cast [@focus, help][@target, help] Lifebloom
# /cast [@player] Innervate

# Optional macros (every line is a macro)
# /focus
# /cast [@cursor] Efflorescence

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
#Include(ovale_druid_spells)

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
Define(rejuvenation_germination 155777)
	SpellInfo(rejuvenation_germination duration=15)
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
	SpellAddBuff(regrowth_restoration clearcasting_restoration_buff=0)
Define(renewal 108238)
	SpellInfo(renewal cd=120 gcd=0 offgcd=1)
Define(rejuvenation 774)
	SpellAddTargetBuff(rejuvenation rejuvenation_buff=1)
	SpellAddTargetBuff(rejuvenation rejuvenation_germination=1 talent=germination_talent)
Define(rejuvenation_buff 774)
	SpellInfo(rejuvenation_buff duration=15)
Define(healing_touch 5185)
Define(swiftmend 18562)
	SpellInfo(swiftmend cd=30)
	SpellInfo(swiftmend max_stacks=2 talent=prosperity_talent)
Define(rebirth 20484)
	SpellInfo(rebirth cd=600)
Define(innervate 29166)
	SpellInfo(innervate cd=300)
	
# Moonkin stuff
Define(moonkin_form 24858)
	SpellInfo(moonkin_form to_stance=druid_moonkin_form)
	SpellInfo(moonkin_form unusable=1 if_stance=druid_moonkin_form)
Define(moonfire 8921)
	SpellAddBuff(moonfire moonfire_debuff=1)
Define(moonfire_debuff 164812)
	SpellInfo(moonfire_debuff duration=16)
Define(sunfire 93402)
	SpellAddTargetDebuff(sunfire sunfire_debuff=1)
Define(sunfire_debuff 164815)
	SpellInfo(sunfire_debuff duration=12)
Define(lunar_empowerment_buff 164547)
Define(lunar_strike 197628)
	SpellAddBuff(lunar_strike lunar_empowerment_buff=0)
Define(solar_empowerment_buff 164545)
Define(solar_wrath 190984)
	SpellAddBuff(solar_wrath solar_empowerment_buff=-1)

# Talents
Define(prosperity_talent 1)
Define(germination_talent 18)

AddIcon specialization=4 help=main
{
	if not { Stance(3) }
	{
		if HealthPercent() < 70 Spell(renewal)
	}
	
	# Ress dead ally
	if target.IsDead() and target.IsFriend() and InCombat() Spell(rebirth)

	if target.Present() and target.Exists() and target.IsFriend() and target.InRange(lifebloom) and not { mounted() or Stance(3) }
	{
		Cooldowns()
		
		Rotation()
	}
	
	Travel()
}

# Travel!
AddFunction Travel
{
	if not InCombat() and Falling()
	{
		if not Stance(3) and not Indoors() and not mounted() Spell(travel_form)
		# if not Stance(3) and not Stance(druid_cat_form) and not Wet() and Indoors() Spell(cat_form)
	}
}

AddFunction HasFocus
{
	focus.Present() and focus.Exists() and focus.InRange(lifebloom)
}

AddFunction Cooldowns 
{
	# We are on a healing frenzy
	if { UnitInRaid() and BuffCountOnAny(cultivation_buff) >= 6 and Speed() == 0 } or { not UnitInRaid() and BuffCountOnAny(cultivation_buff) >= 4 and Speed() == 0 } 
	{
		Spell(berserking)
		Spell(innervate)
	}
	# Use Cenarion Ward on cooldown.
	Spell(cenarion_ward)
	if { HasFocus() and focus.HealthPercent() < 60 } or { not HasFocus() and target.HealthPercent() < 40 } Spell(ironbark)
	# Use Flourish and Essence of G'Hanir as often as possible (no need to use them together).
	if { UnitInRaid() and BuffCountOnAny(rejuvenation_buff) >= 5 } or { not UnitInRaid() and BuffCountOnAny(wild_growth_buff) >= 1 }
	{
		Spell(flourish)
		Spell(essence_of_ghanir)
	}
}

AddFunction Rotation
{
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() <= 25 Spell(swiftmend)
	# Use Regrowth as an emergency heal.
	if target.HealthPercent() <= 40 and Speed() == 0 Spell(regrowth_restoration)
	# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
	if HasFocus() and focus.BuffRemains(lifebloom_buff) <= 4 Spell(lifebloom)
	# Use Clearcasting procs on one of the tanks.
	if { BuffPresent(clearcasting_restoration_buff) and HasFocus() and target.IsFocus() and Speed() == 0 } or { not HasFocus() and BuffPresent(clearcasting_restoration_buff) and Speed() == 0 and target.HealthPercent() <= 80 } Spell(regrowth_restoration)
	# Keep Rejuvenation on the tank and on members of the group that just took damage or are about to take damage. Keep up both Rejuvenations on targets on which the damage is too high for a single one.
	if target.BuffRemains(rejuvenation_buff) <= 3.5 or not target.BuffPresent(rejuvenation_buff) or { target.BuffPresent(cultivation_buff) and not target.BuffPresent(rejuvenation_germination) and Talent(germination_talent) } Spell(rejuvenation)
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() <= 40 Spell(swiftmend)
	# Use Wild Growth when at least 6 members of the raid are damaged and you have some Rejuvenation Icon Rejuvenations up.
	# Use Wild Growth when at least 4 members of the group are damaged.
	if { UnitInRaid() and BuffCountOnAny(cultivation_buff) >= 6 and Speed() == 0 } or { not UnitInRaid() and BuffCountOnAny(cultivation_buff) >= 4 and Speed() == 0 } Spell(wild_growth)
	if target.HealthPercent() <= 85 and Speed() == 0 Spell(healing_touch)
}
]]
	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
