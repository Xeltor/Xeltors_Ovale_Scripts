local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_restoration"
	local desc = "[Xel][7.3] Druid: Restoration"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

AddIcon specialization=4 help=main
{
	# Don't fucking dismount me asshole script.
	unless Stance(2) or Stance(3) or mounted() or IsDead()
	{
		if not IsDead() and HealthPercent() < 70 Spell(renewal)
		
		# Dont heal if we are not in a healing spec.
		unless BuffPresent(bear_form)
		{
			# Ress dead ally
			if target.IsDead() and target.IsFriend()
			{
				if InCombat() and Spell(rebirth) and target.InRange(rebirth) and not PreviousGCDSpell(rebirth) Spell(rebirth)
				if not InCombat() and Spell(revitalize) and not PreviousGCDSpell(revitalize) and { Speed() == 0 or CanMove() > 0 } Spell(revitalize)
			}
			
			if CheckBoxOn(auto) Party_Auto_Target()
			
			# Do main rotation.
			if target.Present() and target.IsFriend() and target.InRange(lifebloom) and { target.Health() / target.MaxHealth() } * 100 < 100
			{
				Cooldowns()
				
				Rotation()
			}
			
			# Keep up focus stuff regardless of target.
			if HasFocus()
			{
				# Keep Lifebloom on an active tank. Refreshing it with less than 4.5 seconds left in order to proc the final Bloom and not lose any ticks is recommended.
				if focus.BuffRemains(lifebloom_buff) <= 4 Spell(lifebloom)
			}
		}
		
		# Alternate DPS rotations.
		if target.InRange(mangle) and HasFullControl() and target.Present() and not target.IsFriend()
		{
			if BuffPresent(bear_form) Guardian_Affinity()
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
	focus.Present() and focus.InRange(lifebloom) and not focus.IsDead()
}

# Party auto target system
AddFunction Party_Auto_Target
{
	unless UnitInRaid()
	{
		# Anti non friend selection bit.
		if not target.IsFriend() and target.Exists() and InCombat() ThePlayer()

		# Prioritize low health
		if HealthPercent() < 60 and { target.HealthPercent() >= 60 or HealthPercent() < target.HealthPercent() or not target.Present() } ThePlayer()
		if party1.HealthPercent() < 60 and { target.HealthPercent() >= 60 or party1.HealthPercent() < target.HealthPercent() or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) PartyMemberOne()
		if party2.HealthPercent() < 60 and { target.HealthPercent() >= 60 or party2.HealthPercent() < target.HealthPercent() or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) PartyMemberTwo()
		if party3.HealthPercent() < 60 and { target.HealthPercent() >= 60 or party3.HealthPercent() < target.HealthPercent() or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) PartyMemberThree()
		if party4.HealthPercent() < 60 and { target.HealthPercent() >= 60 or party4.HealthPercent() < target.HealthPercent() or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) PartyMemberFour()
		
		# Prioritize putting rejuvenation on people
		unless HealthPercent() < 60 or party1.HealthPercent() < 60 and party1.Present() and party1.InRange(rejuvenation) or party2.HealthPercent() < 60 and party2.Present() and party2.InRange(rejuvenation) or party3.HealthPercent() < 60 and party3.Present() and party3.InRange(rejuvenation) or party4.HealthPercent() < 60 and party4.Present() and party4.InRange(rejuvenation)
		{
			if HealthPercent() < 100 and BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } ThePlayer()
			if party1.HealthPercent() < 100 and party1.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) PartyMemberOne()
			if party2.HealthPercent() < 100 and party2.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) PartyMemberTwo()
			if party3.HealthPercent() < 100 and party3.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) PartyMemberThree()
			if party4.HealthPercent() < 100 and party4.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(rejuvenation_buff) > 3.5 or target.HealthPercent() >= 100 or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) PartyMemberFour()
		}
		
		# Normal healing.
		unless HealthPercent() < 60 or HealthPercent() < 100 and BuffRemains(rejuvenation_buff) <= 3.5 or party1.HealthPercent() < 60 and party1.Present() and party1.InRange(rejuvenation) or party1.HealthPercent() < 100 and party1.BuffRemains(rejuvenation_buff) <= 3.5 and party1.Present() and party1.InRange(rejuvenation) or party2.HealthPercent() < 60 and party2.Present() and party2.InRange(rejuvenation) or party2.HealthPercent() < 100 and party2.BuffRemains(rejuvenation_buff) <= 3.5 and party2.Present() and party2.InRange(rejuvenation) or party3.HealthPercent() < 60 and party3.Present() and party3.InRange(rejuvenation) or party3.HealthPercent() < 100 and party3.BuffRemains(rejuvenation_buff) <= 3.5 and party3.Present() and party3.InRange(rejuvenation) or party4.HealthPercent() < 60 and party4.Present() and party4.InRange(rejuvenation) or party4.HealthPercent() < 100 and party4.BuffRemains(rejuvenation_buff) <= 3.5 and party4.Present() and party4.InRange(rejuvenation)
		{
			if HealthPercent() < 89 and { target.HealthPercent() >= 89 or HealthPercent() < target.HealthPercent() or not target.Present() } ThePlayer()
			if party1.HealthPercent() < 89 and { target.HealthPercent() >= 89 or party1.HealthPercent() < target.HealthPercent() or not target.Present() } and party1.Present() and party1.InRange(rejuvenation) PartyMemberOne()
			if party2.HealthPercent() < 89 and { target.HealthPercent() >= 89 or party2.HealthPercent() < target.HealthPercent() or not target.Present() } and party2.Present() and party2.InRange(rejuvenation) PartyMemberTwo()
			if party3.HealthPercent() < 89 and { target.HealthPercent() >= 89 or party3.HealthPercent() < target.HealthPercent() or not target.Present() } and party3.Present() and party3.InRange(rejuvenation) PartyMemberThree()
			if party4.HealthPercent() < 89 and { target.HealthPercent() >= 89 or party4.HealthPercent() < target.HealthPercent() or not target.Present() } and party4.Present() and party4.InRange(rejuvenation) PartyMemberFour()
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

# Rotation

AddFunction Cooldowns 
{
	# We are on a healing frenzy
	if CheckBoxOn(hard) and { Speed() == 0 or CanMove() }
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
	# Force wild growth
	if CheckBoxOn(hard) and { Speed() == 0 or CanMove() > 0 } Spell(wild_growth)
	# Use Wild Growth when at least 6 members of the raid are damaged and you have some Rejuvenations up.
	if UnitInRaid() and RaidMembersInRange(wild_growth) >= 4 and { RaidMembersWithHealthPercent(less 70) >= 4 or RaidMembersWithHealthPercent(less 80) >= 6 } and { Speed() == 0 or CanMove() > 0 } Spell(wild_growth)
	# Use Wild Growth when at least 4 members of the group are damaged.
	if not UnitInRaid() and PartyMembersInRange(wild_growth) >= 3 and { PartyMembersWithHealthPercent(less 70) >= 3 or PartyMembersWithHealthPercent(less 80) >= 4 } and { Speed() == 0 or CanMove() > 0 } Spell(wild_growth)
	# Use Regrowth as an emergency heal.
	if target.HealthPercent() <= 60 and not target.BuffPresent(regrowth_buff) and { Speed() == 0 or CanMove() > 0 } Spell(regrowth_restoration)
	# Use Clearcasting procs on one of the tanks.
	if { BuffPresent(clearcasting_restoration_buff) and HasFocus() and target.IsFocus() and { Speed() == 0 or CanMove() > 0 } } or { not HasFocus() and BuffPresent(clearcasting_restoration_buff) and { Speed() == 0 or CanMove() > 0 } and target.HealthPercent() <= 80 } Spell(regrowth_restoration)
	# Keep Rejuvenation on the tank and on members of the group that just took damage or are about to take damage.
	if not Talent(germination_talent) and target.BuffRemains(rejuvenation_buff) <= 3.5 Spell(rejuvenation)
	if Talent(germination_talent) and target.BuffRemains(rejuvenation_buff) <= 3.5 and { target.BuffRemains(germination_buff) > target.BuffRemains(rejuvenation_buff) or not target.BuffPresent(germination_buff) } Spell(rejuvenation)
	# Keep up both Rejuvenations on targets on which the damage is too high for a single one.
	if Talent(germination_talent) and { Talent(abundance_talent) or target.HealthPercent() < 89 } and target.BuffRemains(germination_buff) <= 3.5 and target.BuffPresent(rejuvenation_buff) and target.BuffRemains(germination_buff) < target.BuffRemains(rejuvenation_buff) Spell(rejuvenation)
	# Use Swiftmend on a player that just took heavy damage. If they are not in immediate danger, you should apply Rejuvenation to him first.
	if target.HealthPercent() <= 45 Spell(swiftmend)
	if target.HealthPercent() <= 60 and { Speed() == 0 or CanMove() > 0 } Spell(regrowth_restoration)
	if target.HealthPercent() <= 89 and { Speed() == 0 or CanMove() > 0 } Spell(healing_touch)
}

# Guardian Affinity
AddFunction Guardian_Affinity
{
	if not BuffPresent(bear_form) Spell(bear_form)
	if IncomingDamage(5) / MaxHealth() >= 0.2 or Health() <= MaxHealth() * 0.65 Spell(frenzied_regeneration)
	if Rage() > 55 Spell(ironfur)
	Spell(thrash_bear)
	if target.DebuffExpires(moonfire_debuff) Spell(moonfire)
	Spell(mangle)
}
]]
	OvaleScripts:RegisterScript("DRUID", "restoration", name, desc, code, "script")
end
