local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_survival"
	local desc = "[Xel][7.1.5] Hunter: Survival"
	local code = [[
# Based on SimulationCraft profile "Hunter_SV_T18M".
#	class=hunter
#	spec=survival
#	talents=3202022

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(weakened_heart 55711)
Define(heart_of_the_phoenix 55709)
Define(mend_pet 136)
	SpellInfo(mend_pet duration=10)
	SpellAddBuff(mend_pet mend_pet=1)
Define(PETGROWL 2649)

# Survival
AddIcon specialization=3 help=main
{
	# Silence
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if InCombat() and HasFullControl() and target.Present() and target.InRange(raptor_strike)
	{
		# Survival
		HunterTankStuff()
		
		# Cooldowns
		if Boss()
		{
			SurvivalDefaultCdActions()
		}
		
		# Short Cooldowns
		SurvivalDefaultShortCdActions()
		
		# Default Actions
		SurvivalDefaultMainActions()
	}
	
	# Go forth and murder
	if InCombat() and HasFullControl() and target.Present() and not target.InRange(raptor_strike) and { TimeInCombat() < 6 or Falling() }
	{
		if target.InRange(harpoon) Spell(harpoon)
	}
}
AddCheckBox(tonk "Tank mode")

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction HunterTankStuff
{
	if not pet.Present() and pet.Exists() and not DeBuffStacks(weakened_heart) and SpellKnown(heart_of_the_phoenix) and CanCast(heart_of_the_phoenix) Spell(heart_of_the_phoenix usable=1)
	if not pet.Present() and pet.Exists() and Focus() >=35 and Speed() ==0 Spell(revive_pet)
	if pet.Present() and pet.Exists() and pet.LifePercent() <85 and not pet.BuffStacks(mend_pet) and pet.InRange(mend_pet) Spell(mend_pet)
	if CheckBoxOn(tonk)
	{
		if not focus.Present()
		{
			if pet.Present() and pet.Exists() Spell(PETGROWL)
		}
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(muzzle) Spell(muzzle)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction SurvivalDefaultMainActions
{
	#potion,name=old_war,if=buff.aspect_of_the_eagle.remains
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalMainActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalMainPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokMainActions()
	}
}

AddFunction SurvivalDefaultMainPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalMainPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokMainPostConditions()
}

AddFunction SurvivalDefaultShortCdActions
{
	#potion,name=old_war,if=buff.aspect_of_the_eagle.remains
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalShortCdActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalShortCdPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokShortCdActions()
	}
}

AddFunction SurvivalDefaultShortCdPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalShortCdPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokShortCdPostConditions()
}

AddFunction SurvivalDefaultCdActions
{
	#auto_attack
	#muzzle
	# SurvivalInterruptActions()
	#arcane_torrent,if=focus.deficit>=30
	if FocusDeficit() >= 30 Spell(arcane_torrent_focus)
	#berserking
	Spell(berserking)
	#blood_fury
	Spell(blood_fury_ap)
	#use_item,name=tirathons_betrayal
	# SurvivalUseItemActions()
	#potion,name=old_war,if=buff.aspect_of_the_eagle.remains
	#call_action_list,name=moknathal,if=talent.way_of_the_moknathal.enabled
	if Talent(way_of_the_moknathal_talent) SurvivalMoknathalCdActions()

	unless Talent(way_of_the_moknathal_talent) and SurvivalMoknathalCdPostConditions()
	{
		#call_action_list,name=nomok,if=!talent.way_of_the_moknathal.enabled
		if not Talent(way_of_the_moknathal_talent) SurvivalNomokCdActions()
	}
}

AddFunction SurvivalDefaultCdPostConditions
{
	Talent(way_of_the_moknathal_talent) and SurvivalMoknathalCdPostConditions() or not Talent(way_of_the_moknathal_talent) and SurvivalNomokCdPostConditions()
}

### actions.moknathal

AddFunction SurvivalMoknathalMainActions
{
	#raptor_strike,if=buff.moknathal_tactics.stack<=1
	if BuffStacks(moknathal_tactics_buff) <= 1 Spell(raptor_strike)
	#raptor_strike,if=buff.moknathal_tactics.remains<gcd
	if BuffRemaining(moknathal_tactics_buff) < GCD() Spell(raptor_strike)
	#caltrops,if=(buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4&!dot.caltrops.ticking)
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=0&buff.aspect_of_the_eagle.remains>=gcd&focus>75
	if SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Focus() > 75 Spell(flanking_strike)
	#lacerate,if=focus>60&buff.mongoose_fury.duration>=gcd&dot.lacerate.remains<=3&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
	if Focus() > 60 and BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 3 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(lacerate)
	#raptor_strike,if=talent.serpent_sting.enabled&dot.serpent_sting.remains<gcd
	if Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() Spell(raptor_strike)
	#raptor_strike,if=buff.moknathal_tactics.remains<4&buff.mongoose_fury.stack=6&buff.mongoose_fury.remains>=gcd
	if BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) >= GCD() Spell(raptor_strike)
	#mongoose_bite,if=buff.aspect_of_the_eagle.up&buff.mongoose_fury.up&buff.moknathal_tactics.stack>=4
	if BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 Spell(mongoose_bite)
	#raptor_strike,if=buff.moknathal_tactics.stack<=3
	if BuffStacks(moknathal_tactics_buff) <= 3 Spell(raptor_strike)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=2&buff.mongoose_fury.remains>(1+action.mongoose_bite.charges*gcd)&focus>75
	if SpellChargeCooldown(mongoose_bite) <= 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Focus() > 75 Spell(flanking_strike)
	#mongoose_bite,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<cooldown.aspect_of_the_eagle.remains
	if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) Spell(mongoose_bite)
	#caltrops,if=(!dot.caltrops.ticking)
	if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#lacerate,if=(!dot.lacerate.ticking|dot.lacerate.remains<3)
	if not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 Spell(lacerate)
	#butchery,if=(charges=3&focus>65)
	if Charges(butchery) == 3 and Focus() > 65 Spell(butchery)
	#mongoose_bite,if=(charges>=2&cooldown.mongoose_bite.remains<=gcd|charges=3)
	if Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 Spell(mongoose_bite)
	#butchery,if=focus>65
	if Focus() > 65 Spell(butchery)
	#flanking_strike,if=focus>75
	if Focus() > 75 Spell(flanking_strike)
	#raptor_strike,if=focus>75-cooldown.flanking_strike.remains*focus.regen
	if Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() Spell(raptor_strike)
}

AddFunction SurvivalMoknathalMainPostConditions
{
}

AddFunction SurvivalMoknathalShortCdActions
{
	unless BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike)
	{
		#snake_hunter,if=cooldown.mongoose_bite.charges<=0&buff.mongoose_fury.remains>3*gcd
		if SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() Spell(snake_hunter)
		#a_murder_of_crows,if=focus>55&buff.mongoose_fury.stack<4&buff.mongoose_fury.duration>=gcd
		if Focus() > 55 and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() Spell(a_murder_of_crows)
		#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 Spell(steel_trap)

		unless BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Focus() > 75 and Spell(flanking_strike) or Focus() > 60 and BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 3 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate)
		{
			#spitting_cobra,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
			if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(spitting_cobra)
			#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4
			if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 Spell(steel_trap)
			#explosive_trap,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
			if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(explosive_trap)
			#dragonsfire_grenade,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
			if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(dragonsfire_grenade)

			unless Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(raptor_strike)
			{
				#fury_of_the_eagle,if=buff.moknathal_tactics.remains>4&buff.mongoose_fury.stack=6&cooldown.mongoose_bite.charges<=2
				if BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 Spell(fury_of_the_eagle)

				unless BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite)
				{
					#fury_of_the_eagle,if=(buff.moknathal_tactics.remains>4&(buff.mongoose_fury.stack=6&cooldown.mongoose_bite.charges<=0|buff.mongoose_fury.up&buff.mongoose_fury.remains<=2*gcd))
					if BuffRemaining(moknathal_tactics_buff) > 4 and { BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 0 or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() } Spell(fury_of_the_eagle)

					unless BuffStacks(moknathal_tactics_buff) <= 3 and Spell(raptor_strike) or SpellChargeCooldown(mongoose_bite) <= 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Focus() > 75 and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite)
					{
						#a_murder_of_crows,if=focus>55
						if Focus() > 55 Spell(a_murder_of_crows)
						#spitting_cobra
						Spell(spitting_cobra)
						#steel_trap
						Spell(steel_trap)
						#explosive_trap
						Spell(explosive_trap)

						unless not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate)
						{
							#dragonsfire_grenade
							Spell(dragonsfire_grenade)
						}
					}
				}
			}
		}
	}
}

AddFunction SurvivalMoknathalShortCdPostConditions
{
	BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Focus() > 75 and Spell(flanking_strike) or Focus() > 60 and BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 3 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(raptor_strike) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffStacks(moknathal_tactics_buff) <= 3 and Spell(raptor_strike) or SpellChargeCooldown(mongoose_bite) <= 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Focus() > 75 and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate) or Charges(butchery) == 3 and Focus() > 65 and Spell(butchery) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Focus() > 65 and Spell(butchery) or Focus() > 75 and Spell(flanking_strike) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

AddFunction SurvivalMoknathalCdActions
{
	unless BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and Spell(snake_hunter) or Focus() > 55 and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() and Spell(a_murder_of_crows) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Focus() > 75 and Spell(flanking_strike) or Focus() > 60 and BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 3 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(explosive_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(dragonsfire_grenade) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffRemaining(moknathal_tactics_buff) > 4 and { BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 0 or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() } and Spell(fury_of_the_eagle) or BuffStacks(moknathal_tactics_buff) <= 3 and Spell(raptor_strike)
	{
		#aspect_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.remains>6&cooldown.mongoose_bite.charges>=2
		if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) > 6 and SpellChargeCooldown(mongoose_bite) >= 2 Spell(aspect_of_the_eagle)
	}
}

AddFunction SurvivalMoknathalCdPostConditions
{
	BuffStacks(moknathal_tactics_buff) <= 1 and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < GCD() and Spell(raptor_strike) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and Spell(snake_hunter) or Focus() > 55 and BuffStacks(mongoose_fury_buff) < 4 and BaseDuration(mongoose_fury_buff) >= GCD() and Spell(a_murder_of_crows) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Focus() > 75 and Spell(flanking_strike) or Focus() > 60 and BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 3 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(explosive_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(dragonsfire_grenade) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) < 4 and BuffStacks(mongoose_fury_buff) == 6 and BuffRemaining(mongoose_fury_buff) >= GCD() and Spell(raptor_strike) or BuffRemaining(moknathal_tactics_buff) > 4 and BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and BuffStacks(moknathal_tactics_buff) >= 4 and Spell(mongoose_bite) or BuffRemaining(moknathal_tactics_buff) > 4 and { BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 0 or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) <= 2 * GCD() } and Spell(fury_of_the_eagle) or BuffStacks(moknathal_tactics_buff) <= 3 and Spell(raptor_strike) or SpellChargeCooldown(mongoose_bite) <= 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Focus() > 75 and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Focus() > 55 and Spell(a_murder_of_crows) or Spell(spitting_cobra) or Spell(steel_trap) or Spell(explosive_trap) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate) or Spell(dragonsfire_grenade) or Charges(butchery) == 3 and Focus() > 65 and Spell(butchery) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Focus() > 65 and Spell(butchery) or Focus() > 75 and Spell(flanking_strike) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

### actions.nomok

AddFunction SurvivalNomokMainActions
{
	#caltrops,if=(buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4&!dot.caltrops.ticking)
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#flanking_strike,if=cooldown.mongoose_bite.charges<=0&buff.aspect_of_the_eagle.remains>=gcd
	if SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() Spell(flanking_strike)
	#lacerate,if=buff.mongoose_fury.duration>=gcd&dot.lacerate.remains<=1&&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
	if BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 1 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(lacerate)
	#raptor_strike,if=talent.serpent_sting.enabled&dot.serpent_sting.remains<gcd
	if Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() Spell(raptor_strike)
	#mongoose_bite,if=buff.aspect_of_the_eagle.up&buff.mongoose_fury.up
	if BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) Spell(mongoose_bite)
	#flanking_strike,if=cooldown.mongoose_bite.charges<2&buff.mongoose_fury.remains>(1+action.mongoose_bite.charges*gcd)
	if SpellChargeCooldown(mongoose_bite) < 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() Spell(flanking_strike)
	#mongoose_bite,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<cooldown.aspect_of_the_eagle.remains
	if BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) Spell(mongoose_bite)
	#flanking_strike,if=talent.animal_instincts.enabled&cooldown.mongoose_bite.charges<3
	if Talent(animal_instincts_talent) and SpellChargeCooldown(mongoose_bite) < 3 Spell(flanking_strike)
	#caltrops,if=(!dot.caltrops.ticking)
	if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
	#lacerate,if=(!dot.lacerate.ticking|dot.lacerate.remains<3)
	if not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 Spell(lacerate)
	#butchery,if=(charges=3)
	if Charges(butchery) == 3 Spell(butchery)
	#throwing_axes,if=cooldown.throwing_axes.charges=2
	if SpellChargeCooldown(throwing_axes) == 2 Spell(throwing_axes)
	#mongoose_bite,if=(charges>=2&cooldown.mongoose_bite.remains<=gcd|charges=3)
	if Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 Spell(mongoose_bite)
	#butchery
	Spell(butchery)
	#throwing_axes
	Spell(throwing_axes)
	#flanking_strike
	Spell(flanking_strike)
	#raptor_strike,if=focus>75-cooldown.flanking_strike.remains*focus.regen
	if Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() Spell(raptor_strike)
}

AddFunction SurvivalNomokMainPostConditions
{
}

AddFunction SurvivalNomokShortCdActions
{
	#a_murder_of_crows,if=cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
	if SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(a_murder_of_crows)
	#snake_hunter,if=action.mongoose_bite.charges<=0&buff.mongoose_fury.remains>3*gcd
	if Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() Spell(snake_hunter)
	#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4
	if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 Spell(steel_trap)

	unless BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 1 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate)
	{
		#spitting_cobra,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(spitting_cobra)
		#steel_trap,if=buff.mongoose_fury.duration>=gcd&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 Spell(steel_trap)
		#explosive_trap,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(explosive_trap)
		#dragonsfire_grenade,if=buff.mongoose_fury.duration>=gcd&cooldown.mongoose_bite.charges>=0&buff.mongoose_fury.stack<4
		if BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 Spell(dragonsfire_grenade)

		unless Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike)
		{
			#fury_of_the_eagle,if=buff.mongoose_fury.stack=6&cooldown.mongoose_bite.charges<=2
			if BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 Spell(fury_of_the_eagle)

			unless BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite)
			{
				#fury_of_the_eagle,if=cooldown.mongoose_bite.charges<=0&buff.mongoose_fury.duration>6
				if SpellChargeCooldown(mongoose_bite) <= 0 and BaseDuration(mongoose_fury_buff) > 6 Spell(fury_of_the_eagle)

				unless SpellChargeCooldown(mongoose_bite) < 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellChargeCooldown(mongoose_bite) < 3 and Spell(flanking_strike)
				{
					#a_murder_of_crows
					Spell(a_murder_of_crows)
					#spitting_cobra
					Spell(spitting_cobra)
					#steel_trap
					Spell(steel_trap)
					#explosive_trap
					Spell(explosive_trap)

					unless not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate)
					{
						#dragonsfire_grenade
						Spell(dragonsfire_grenade)
					}
				}
			}
		}
	}
}

AddFunction SurvivalNomokShortCdPostConditions
{
	BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 1 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or SpellChargeCooldown(mongoose_bite) < 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellChargeCooldown(mongoose_bite) < 3 and Spell(flanking_strike) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate) or Charges(butchery) == 3 and Spell(butchery) or SpellChargeCooldown(throwing_axes) == 2 and Spell(throwing_axes) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(butchery) or Spell(throwing_axes) or Spell(flanking_strike) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

AddFunction SurvivalNomokCdActions
{
	unless SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(a_murder_of_crows) or Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 1 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(explosive_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(dragonsfire_grenade) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite)
	{
		#aspect_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.duration>6&cooldown.mongoose_bite.charges>=2
		if BuffPresent(mongoose_fury_buff) and BaseDuration(mongoose_fury_buff) > 6 and SpellChargeCooldown(mongoose_bite) >= 2 Spell(aspect_of_the_eagle)
	}
}

AddFunction SurvivalNomokCdPostConditions
{
	SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(a_murder_of_crows) or Charges(mongoose_bite) <= 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and Spell(snake_hunter) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or SpellChargeCooldown(mongoose_bite) <= 0 and BuffRemaining(aspect_of_the_eagle_buff) >= GCD() and Spell(flanking_strike) or BaseDuration(mongoose_fury_buff) >= GCD() and target.DebuffRemaining(lacerate_debuff) <= 1 and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(lacerate) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(spitting_cobra) or BaseDuration(mongoose_fury_buff) >= GCD() and BuffStacks(mongoose_fury_buff) < 4 and Spell(steel_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(explosive_trap) or BaseDuration(mongoose_fury_buff) >= GCD() and SpellChargeCooldown(mongoose_bite) >= 0 and BuffStacks(mongoose_fury_buff) < 4 and Spell(dragonsfire_grenade) or Talent(serpent_sting_talent) and target.DebuffRemaining(serpent_sting_debuff) < GCD() and Spell(raptor_strike) or BuffStacks(mongoose_fury_buff) == 6 and SpellChargeCooldown(mongoose_bite) <= 2 and Spell(fury_of_the_eagle) or BuffPresent(aspect_of_the_eagle_buff) and BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or SpellChargeCooldown(mongoose_bite) <= 0 and BaseDuration(mongoose_fury_buff) > 6 and Spell(fury_of_the_eagle) or SpellChargeCooldown(mongoose_bite) < 2 and BuffRemaining(mongoose_fury_buff) > 1 + Charges(mongoose_bite) * GCD() and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and BuffRemaining(mongoose_fury_buff) < SpellCooldown(aspect_of_the_eagle) and Spell(mongoose_bite) or Talent(animal_instincts_talent) and SpellChargeCooldown(mongoose_bite) < 3 and Spell(flanking_strike) or Spell(a_murder_of_crows) or Spell(spitting_cobra) or Spell(steel_trap) or Spell(explosive_trap) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { not target.DebuffPresent(lacerate_debuff) or target.DebuffRemaining(lacerate_debuff) < 3 } and Spell(lacerate) or Spell(dragonsfire_grenade) or Charges(butchery) == 3 and Spell(butchery) or SpellChargeCooldown(throwing_axes) == 2 and Spell(throwing_axes) or { Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) <= GCD() or Charges(mongoose_bite) == 3 } and Spell(mongoose_bite) or Spell(butchery) or Spell(throwing_axes) or Spell(flanking_strike) or Focus() > 75 - SpellCooldown(flanking_strike) * FocusRegenRate() and Spell(raptor_strike)
}

### actions.precombat

AddFunction SurvivalPrecombatMainActions
{
	#snapshot_stats
	#potion,name=old_war
	#augmentation,type=defiled
	Spell(augmentation)
	#harpoon
	Spell(harpoon)
}

AddFunction SurvivalPrecombatMainPostConditions
{
}

AddFunction SurvivalPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=fishbrul_special
	#summon_pet
	# SurvivalSummonPet()

	unless Spell(augmentation)
	{
		#dragonsfire_grenade
		Spell(dragonsfire_grenade)
	}
}

AddFunction SurvivalPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(harpoon)
}

AddFunction SurvivalPrecombatCdActions
{
}

AddFunction SurvivalPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(dragonsfire_grenade) or Spell(harpoon)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
