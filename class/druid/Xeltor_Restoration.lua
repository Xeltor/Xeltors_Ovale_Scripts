local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_restoration"
	local desc = "[Xel][7.3] Druid: Restoration"
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
Define(germination_buff 155777)
	SpellInfo(germination_buff duration=15)
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
Define(tranquility 740)
	SpellInfo(tranquility cd=180 duration=8)
Define(essence_of_ghanir 208253)
	SpellInfo(essence_of_ghanir cd=90)
Define(cenarion_ward 102351)
	SpellInfo(cenarion_ward cd=30)
	SpellAddTargetBuff(cenarion_ward cenarion_ward_buff=1)
Define(cenarion_ward_buff 102351)
Define(regrowth_restoration 8936)
	SpellAddTargetBuff(regrowth_restoration regrowth_buff=1)
	SpellAddBuff(regrowth_restoration clearcasting_restoration_buff=0)
Define(regrowth_buff 8936)
	SpellInfo(regrowth_buff duration=12)
Define(renewal 108238)
	SpellInfo(renewal cd=120 gcd=0 offgcd=1)
Define(rejuvenation 774)
	SpellAddTargetBuff(rejuvenation rejuvenation_buff=1)
	SpellAddTargetBuff(rejuvenation germination_buff=1 talent=germination_talent)
Define(rejuvenation_buff 774)
	SpellInfo(rejuvenation_buff duration=15)
Define(revitalize 212040)
Define(healing_touch 5185)
Define(swiftmend 18562)
	SpellInfo(swiftmend cd=30)
	SpellInfo(swiftmend max_stacks=2 talent=prosperity_talent)
Define(rebirth 20484)
	SpellInfo(rebirth cd=600)
Define(innervate 29166)
	SpellInfo(innervate cd=300)
	
# Balance Affinity
Define(balance_affinity_talent 7)
Define(moonkin_form 24858)
	SpellInfo(moonkin_form to_stance=druid_moonkin_form)
	SpellInfo(moonkin_form unusable=1 if_stance=druid_moonkin_form)
Define(moonfire 8921)
	SpellAddBuff(moonfire moonfire_debuff=1)
Define(moonfire_debuff 164812)
	SpellInfo(moonfire_debuff duration=20)
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

# Feral Affinity
Define(feral_affinity_talent 8)


# Guardian Affinity
Define(guardian_affinity_talent 9)
Define(bear_form 5487)
	SpellInfo(bear_form to_stance=druid_bear_form)
	SpellInfo(bear_form unusable=1 if_stance=druid_bear_form)
Define(mangle 33917)
	SpellInfo(mangle rage=-5 cd=6 cd_haste=melee)
Define(thrash_bear 77758) # Applies the stacking debuff pulverize uses now
	SpellInfo(thrash_bear rage=-4 cd=6 cd_haste=melee stance=druid_bear_form)
	SpellAddTargetDebuff(thrash_bear thrash_bear_debuff=1)
Define(thrash_bear_debuff 192090)
	SpellInfo(thrash_bear_debuff duration=15 max_stacks=3 tick=3)
Define(ironfur 192081)
	SpellInfo(ironfur rage=45 cd=0.5 offgcd=1)
	SpellAddBuff(ironfur ironfur_buff=1)
Define(frenzied_regeneration 22842)
	SpellInfo(frenzied_regeneration cd=24 offgcd=1 cd_haste=melee)
	SpellAddBuff(frenzied_regeneration frenzied_regeneration_buff=1)
	SpellRequire(frenzied_regeneration unusable 1=buff,frenzied_regeneration_buff)
Define(frenzied_regeneration_buff 22842)
	SpellInfo(frenzied_regeneration_buff duration=3)

# Talents
Define(prosperity_talent 1)
Define(germination_talent 18)

AddIcon specialization=4 help=main
{
	# Don't fucking dismount me asshole script.
	unless Stance(2) or Stance(3) or mounted() or IsDead()
	{
		if not IsDead() and HealthPercent() < 70 Spell(renewal)
		
		# Dont heal if we are not in a healing spec.
		unless BuffPresent(bear_form) and Talent(guardian_affinity_talent)
		{
			# Ress dead ally
			if target.IsDead() and target.IsFriend()
			{
				if InCombat() and Spell(rebirth) and target.InRange(rebirth) and not PreviousGCDSpell(rebirth) Spell(rebirth)
				if not InCombat() and Spell(revitalize) and not PreviousGCDSpell(revitalize) and { Speed() == 0 or CanMove() > 0 } Spell(revitalize)
			}
			
			if CheckBoxOn(auto) Party_Auto_Target()
			
			# Do main rotation.
			if target.Present() and target.IsFriend() and target.InRange(lifebloom) and target.HealthPercent() < 100
			{
				Cooldowns()
				
				Rotation()
			}
			
			# Keep up focus stuff regardless of target.
			if not { target.Present() and target.IsFriend() and target.InRange(lifebloom) and target.HealthPercent() < 100 } and HasFocus()
			{
				# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
				if focus.BuffRemains(lifebloom_buff) <= 4 Spell(lifebloom)
			}
		}
		
		# Alternate DPS rotations.
		if target.InRange(mangle) and HasFullControl() and target.Present() and not target.IsFriend()
		{
			if BuffPresent(bear_form) and Talent(guardian_affinity_talent) Guardian_Affinity()
		}
	}
}
AddCheckBox(hard "Heal harder")
AddCheckBox(auto "Party auto target")

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
	focus.Present() and focus.InRange(lifebloom)
}

# Party auto target system
AddFunction Party_Auto_Target
{
	unless UnitInRaid()
	{
		# Anti non friend selection bit.
		if not target.IsFriend() and target.Exists() and InCombat() ThePlayer()

		# Prioritize low health
		if HealthPercent() < 50 and { target.HealthPercent() >= 50 or not target.Present() } and HealthPercent() < target.HealthPercent() ThePlayer()
		if party1.HealthPercent() < 50 and { target.HealthPercent() >= 50 or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) and party1.HealthPercent() < target.HealthPercent() PartyMemberOne()
		if party2.HealthPercent() < 50 and { target.HealthPercent() >= 50 or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) and party2.HealthPercent() < target.HealthPercent() PartyMemberTwo()
		if party3.HealthPercent() < 50 and { target.HealthPercent() >= 50 or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) and party3.HealthPercent() < target.HealthPercent() PartyMemberThree()
		if party4.HealthPercent() < 50 and { target.HealthPercent() >= 50 or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) and party4.HealthPercent() < target.HealthPercent() PartyMemberFour()
		
		# Prioritize putting rejuvenation on people
		unless HealthPercent() < 50 or party1.HealthPercent() < 50 and party1.Present() and party1.InRange(rejuvenation) or party2.HealthPercent() < 50 and party2.Present() and party2.InRange(rejuvenation) or party3.HealthPercent() < 50 and party3.Present() and party3.InRange(rejuvenation) or party4.HealthPercent() < 50 and party4.Present() and party4.InRange(rejuvenation)
		{
			if HealthPercent() < 100 and BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } ThePlayer()
			if party1.HealthPercent() < 100 and party1.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) PartyMemberOne()
			if party2.HealthPercent() < 100 and party2.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) PartyMemberTwo()
			if party3.HealthPercent() < 100 and party3.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) PartyMemberThree()
			if party4.HealthPercent() < 100 and party4.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) PartyMemberFour()
		}
		
		# Normal healing.
		unless HealthPercent() < 50 or HealthPercent() < 100 and BuffRemains(rejuvenation_buff) <= 3.5 or party1.HealthPercent() < 50 and party1.Present() and party1.InRange(rejuvenation) or party1.HealthPercent() < 100 and party1.BuffRemains(rejuvenation_buff) <= 3.5 and party1.Present() and party1.InRange(rejuvenation) or party2.HealthPercent() < 50 and party2.Present() and party2.InRange(rejuvenation) or party2.HealthPercent() < 100 and party2.BuffRemains(rejuvenation_buff) <= 3.5 and party2.Present() and party2.InRange(rejuvenation) or party3.HealthPercent() < 50 and party3.Present() and party3.InRange(rejuvenation) or party3.HealthPercent() < 100 and party3.BuffRemains(rejuvenation_buff) <= 3.5 and party3.Present() and party3.InRange(rejuvenation) or party4.HealthPercent() < 50 and party4.Present() and party4.InRange(rejuvenation) or party4.HealthPercent() < 100 and party4.BuffRemains(rejuvenation_buff) <= 3.5 and party4.Present() and party4.InRange(rejuvenation)
		{
			if HealthPercent() < 89 and { target.HealthPercent() >= 89 or not target.Present() } and HealthPercent() < target.HealthPercent() ThePlayer()
			if party1.HealthPercent() < 89 and { target.HealthPercent() >= 89 or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) and party1.HealthPercent() < target.HealthPercent() PartyMemberOne()
			if party2.HealthPercent() < 89 and { target.HealthPercent() >= 89 or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) and party2.HealthPercent() < target.HealthPercent() PartyMemberTwo()
			if party3.HealthPercent() < 89 and { target.HealthPercent() >= 89 or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) and party3.HealthPercent() < target.HealthPercent() PartyMemberThree()
			if party4.HealthPercent() < 89 and { target.HealthPercent() >= 89 or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) and party4.HealthPercent() < target.HealthPercent() PartyMemberFour()
		}
	}
}

AddFunction ThePlayer
{
	unless player.IsTarget() Texture(misc_arrowdown)
}

AddFunction PartyMemberOne
{
	unless party1.IsTarget() Texture(ships_ability_boardingparty)
}

AddFunction PartyMemberTwo
{
	unless party2.IsTarget() Texture(ships_ability_boardingpartyalliance)
}

AddFunction PartyMemberThree
{
	unless party3.IsTarget() Texture(ships_ability_boardingpartyhorde)
}

AddFunction PartyMemberFour
{
	unless party4.IsTarget() Texture(inv_helm_misc_starpartyhat)
}

AddFunction PartyMembersWithinFourtyYard
{
	player.InRange(rejuvenation) + party1.InRange(rejuvenation) + party2.InRange(rejuvenation) + party3.InRange(rejuvenation) + party4.InRange(rejuvenation)
}

# Raid Range check
AddFunction RaidMembersWithinFourtyYard
{
	player.InRange(rejuvenation) + raid1.InRange(rejuvenation) + raid2.InRange(rejuvenation) + raid3.InRange(rejuvenation) + raid4.InRange(rejuvenation) + raid5.InRange(rejuvenation) + raid6.InRange(rejuvenation) + raid7.InRange(rejuvenation) + raid8.InRange(rejuvenation) + raid9.InRange(rejuvenation) + raid10.InRange(rejuvenation) + raid11.InRange(rejuvenation) + raid12.InRange(rejuvenation) + raid13.InRange(rejuvenation) + raid14.InRange(rejuvenation) + raid15.InRange(rejuvenation) + raid16.InRange(rejuvenation) + raid17.InRange(rejuvenation) + raid18.InRange(rejuvenation) + raid19.InRange(rejuvenation) + raid20.InRange(rejuvenation) + raid21.InRange(rejuvenation) + raid22.InRange(rejuvenation) + raid23.InRange(rejuvenation) + raid24.InRange(rejuvenation) + raid25.InRange(rejuvenation)
}

# Rotation

AddFunction Cooldowns 
{
	# We are on a healing frenzy
	if CheckBoxOn(hard) and Speed() == 0
	{
		Spell(berserking)
		Spell(innervate)
	}
	if InCombat()
	{
		# Use Cenarion Ward on cooldown.
		Spell(cenarion_ward)
		# Save the tank / save the target.
		if target.HealthPercent() < 50 Spell(ironbark)
	}
	# Use Flourish and Essence of G'Hanir as often as possible (no need to use them together).
	if { UnitInRaid() and BuffCountOnAny(rejuvenation_buff) >= 5 } or { not UnitInRaid() and BuffCountOnAny(wild_growth_buff) >= PartyMemberCount() }
	{
		Spell(flourish)
		Spell(essence_of_ghanir)
	}
}

AddFunction Rotation
{
	# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
	if HasFocus() and focus.BuffRemains(lifebloom_buff) <= 4 Spell(lifebloom)
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() < 35 Spell(swiftmend)
	# Use Wild Growth when at least 6 members of the raid are damaged and you have some Rejuvenation Icon Rejuvenations up.
	# Use Wild Growth when at least 4 members of the group are damaged.
	if { CheckBoxOn(hard) and Speed() == 0 } or { UnitInRaid() and RaidHealthPercent() <= 75 and Speed() == 0 } or { not UnitInRaid() and PartyMemberCount() >= 4 and PartyHealthPercent() <= 75 and Speed() == 0 } Spell(wild_growth)
	# Use Tranquility, if group is still taking heavy damage (it does 100% more healing 5-man content).
	if not UnitInRaid() and PartyMemberCount() >= 4 and PartyMembersWithinFourtyYard() >= PartyMemberCount() and BuffCountOnAny(wild_growth_buff) >= PartyMemberCount() and PartyHealthPercent() <= 55 Spell(tranquility)
	# Heal the raid if its low health and at least 75% of the living members are in range.
	if UnitInRaid() and RaidMembersWithinFourtyYard() >= RaidMemberCount() * 0.75 and RaidHealthPercent() <= 50 Spell(tranquility)
	# Use Regrowth as an emergency heal.
	if target.HealthPercent() <= 60 and not target.BuffPresent(regrowth_buff) and Speed() == 0 Spell(regrowth_restoration)
	# Use Clearcasting procs on one of the tanks.
	if { BuffPresent(clearcasting_restoration_buff) and HasFocus() and target.IsFocus() and Speed() == 0 } or { not HasFocus() and BuffPresent(clearcasting_restoration_buff) and Speed() == 0 and target.HealthPercent() <= 80 } Spell(regrowth_restoration)
	# Keep Rejuvenation on the tank and on members of the group that just took damage or are about to take damage.
	if target.BuffRemains(rejuvenation_buff) <= 3.5 Spell(rejuvenation)
	# Keep up both Rejuvenations on targets on which the damage is too high for a single one.
	if target.HealthPercent() <= 89 and target.BuffPresent(rejuvenation_buff) and target.BuffRemains(germination_buff) < target.BuffRemains(rejuvenation_buff) and target.BuffRemains(germination_buff) <= 3.5 and Talent(germination_talent) Spell(rejuvenation)
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() <= 45 Spell(swiftmend)
	if target.HealthPercent() <= 60 and Speed() == 0 Spell(regrowth_restoration)
	if target.HealthPercent() <= 89 and Speed() == 0 Spell(healing_touch)
}

# Guardian Affinity
AddFunction Guardian_Affinity
{
	if not BuffPresent(bear_form) Spell(bear_form)
	if IncomingDamage(5) / MaxHealth() >= 0.2 or Health() <= MaxHealth() * 0.65 Spell(frenzied_regeneration)
	if Rage() > 55 Spell(ironfur)
	if target.DebuffExpires(moonfire_debuff) Spell(moonfire)
	Spell(thrash_bear)
	Spell(mangle)
}
]]
	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
