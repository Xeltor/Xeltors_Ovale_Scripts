local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_restoration_a"
	local desc = "[Xel][8.1] Druid: Restoration"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)
Include(druid_common_functions)

AddIcon specialization=4 help=main
{
	# Don't fucking dismount me asshole script.
	if not Stance(2) and not Stance(3) and not mounted()
	{
		if HealthPercent() > 0 and HealthPercent() < 70 Spell(renewal)
		
		# Ress dead ally
		if target.HealthPercent() <= 0 and target.IsFriend()
		{
			if InCombat() and not focus.Present() and focus.Exists() and focus.InRange(lifebloom) and target.IsFocus() and Spell(rebirth) and target.InRange(rebirth) and not PreviousGCDSpell(rebirth) Spell(rebirth)
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
		if HasFocus()
		{
			# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
			if focus.BuffRemains(lifebloom_buff) <= GCD() * 2 Spell(lifebloom)
		}
		
		# Bored do some dps.
		if target.IsFriend() and targettarget.Present() and not targettarget.IsFriend() and targettarget.HealthPercent() < 100 and InCombat() and targettarget.InRange(moonfire) TTDPS()
		if not target.IsFriend() and target.Present() and target.InRange(moonfire) and InCombat() DPS()
	}
}
AddCheckBox(auto "Party auto target")

AddFunction HasFocus
{
	focus.Present() and focus.InRange(lifebloom) and focus.HealthPercent() > 0
}

# Party auto target system
AddFunction Party_Auto_Target
{
	unless UnitInRaid()
	{
		if PartyMemberWithLowestHealth() == 1 ThePlayer()
		if PartyMemberWithLowestHealth() == 2 PartyMemberOne()
		if PartyMemberWithLowestHealth() == 3 PartyMemberTwo()
		if PartyMemberWithLowestHealth() == 4 PartyMemberThree()
		if PartyMemberWithLowestHealth() == 5 PartyMemberFour()
	}
}

AddFunction HotCount
{
	BuffCountOnAny(rejuvenation_buff) + BuffCountOnAny(regrowth_buff) + BuffCountOnAny(wild_growth_buff) + BuffCountOnAny(lifebloom_buff) + BuffCountOnAny(tranquility_buff) + BuffCountOnAny(cenarion_ward_hot_buff)
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

# Rotation

AddFunction Cooldowns 
{
	if UnitInRaid() and RaidMembersInRange(wild_growth) >= 6 and RaidMembersWithHealthPercent(less 90) >= 6 and { Speed() == 0 or CanMove() > 0 } or not UnitInRaid() and PartyMembersInRange(wild_growth) >= 4 and PartyMembersWithHealthPercent(less 90) >= 4 and { Speed() == 0 or CanMove() > 0 }
	{
		Spell(berserking)
		Spell(innervate)
		if BuffCountOnAny(wild_growth_buff) == 0 and SpellCooldown(wild_growth) > GCD() Spell(tranquility)
	}
	if HotCount() >= 10 Spell(flourish)
}

AddFunction Rotation
{
	# Save dying players immediate.
	if target.HealthPercent() < 35 HotFix()
	# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
	if HasFocus() and focus.BuffRemains(lifebloom_buff) <= 4 Spell(lifebloom)
	# Use Wild Growth when at least 6 members of the raid are damaged and you have some Rejuvenations up.
	if UnitInRaid() and RaidMembersInRange(wild_growth) >= 6 and RaidMembersWithHealthPercent(less 90) >= 6 and { Speed() == 0 or CanMove() > 0 } Spell(wild_growth)
	# Use Wild Growth when at least 4 members of the group are damaged.
	if not UnitInRaid() and PartyMembersInRange(rejuvenation) >= 4 and PartyMembersWithHealthPercent(less 90) >= 3 and { Speed() == 0 or CanMove() > 0 } Spell(wild_growth)
	if InCombat() Spell(cenarion_ward)
	# Keep Rejuvenation on the tank and on members of the group that just took damage or are about to take damage.
	if not Talent(germination_talent) and target.BuffRemains(rejuvenation_buff) <= 3.5 Spell(rejuvenation)
	if Talent(germination_talent) and target.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(germination_buff) > target.BuffRemains(rejuvenation_buff) or not target.BuffPresent(germination_buff) } Spell(rejuvenation)
	# Keep up both Rejuvenations on targets on which the damage is too high for a single one.
	if Talent(germination_talent) and { Talent(abundance_talent) or target.HealthPercent() < 89 } and target.BuffRemains(germination_buff) <= 3.5 and target.BuffPresent(rejuvenation_buff) and target.BuffRemains(germination_buff) < target.BuffRemains(rejuvenation_buff) Spell(rejuvenation)
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() <= 45 Spell(swiftmend)
	if target.HealthPercent() <= 80 and { Speed() == 0 or CanMove() > 0 } Spell(regrowth)
}

AddFunction HotFix
{
	if SpellCooldown(swiftmend) > GCD() Spell(ironbark)
	Spell(swiftmend)
}

AddFunction TTDPS
{
	if targettarget.DebuffRemains(sunfire_debuff) <= GCD() * 2 and ManaPercent() > 75 Spell(sunfire)
	if targettarget.DebuffRemains(moonfire_debuff) <= GCD() * 2 and ManaPercent() > 75 Spell(moonfire)
	if Speed() == 0 or CanMove() > 0 Spell(solar_wrath)
}

AddFunction DPS
{
	if HealthPercent() < 100
	{
		Spell(cenarion_ward)
		if BuffRemains(rejuvenation_buff) <= 3.5 Spell(rejuvenation)
		if Speed() == 0 and HealthPercent() < 50 Spell(regrowth)
	}
	
	if Talent(balance_affinity_talent) and not Stance(4) Spell(moonkin_form)
	if target.DebuffRemains(sunfire_debuff) <= GCD() * 2 Spell(sunfire)
	if target.DebuffRemains(moonfire_debuff) <= GCD() * 2 Spell(moonfire)
	if Speed() == 0 or CanMove() > 0
	{
		if Talent(balance_affinity_talent) Spell(starsurge)
		if { BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) > 3 } and Talent(balance_affinity_talent) Spell(lunar_strike)
		Spell(solar_wrath)
	}
}
]]

	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
