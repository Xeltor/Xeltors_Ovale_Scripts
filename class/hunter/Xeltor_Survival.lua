local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_survival_hunter"
	local desc = "[Xel][8.0] Hunter: Survival"
	local code = [[
# Common functions.
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

AddIcon specialization=3 help=main
{
	# Silence
	if InCombat() and { not target.IsFriend() or target.IsPvP() } InterruptActions()
	
	if HasFullControl() and InCombat() and target.Present() and target.InRange(serpent_sting_sv)
	{
		# Pet we needs it.
		SummonPet()
		if { not IsDead() and HealthPercent() < 50 } or { not pet.IsDead() and pet.HealthPercent() < 15 } Spell(exhilaration)
	
		# Cooldowns
		if Boss() and target.InRange(muzzle) SurvivalDefaultCdActions()
		
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

# Common functions.
AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } or { target.Level() >= Level() and { target.Classification(elite) or target.Classification(rare) } }
}

AddFunction SummonPet
{
 if pet.IsDead()
 {
  if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
  Spell(revive_pet)
 }
 if not pet.IsDead() and pet.HealthPercent() < 85 and not pet.BuffStacks(mend_pet) and pet.InRange(mend_pet) Spell(mend_pet)
 if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(icon_orangebird_toy)
}

AddFunction InterruptActions
{
	if { target.HasManagedInterrupts() and target.MustBeInterrupted() } or { not target.HasManagedInterrupts() and target.IsInterruptible() }
	{
		if target.InRange(muzzle) and target.IsInterruptible() Spell(muzzle)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

### Functions

AddFunction carve_cdr
{
 if Enemies(tagged=1) < 5 Enemies(tagged=1)
 unless Enemies(tagged=1) < 5 5
}

AddFunction SurvivalUseItemActions
{
 if Item(Trinket0Slot usable=1) Texture(inv_jewelry_talisman_12)
 if Item(Trinket1Slot usable=1) Texture(inv_jewelry_talisman_12)
}

### actions.default

AddFunction SurvivalDefaultMainActions
{
 #call_action_list,name=cds
 SurvivalCdsMainActions()

 unless SurvivalCdsMainPostConditions()
 {
  #call_action_list,name=mb_ap_wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled&talent.alpha_predator.enabled&talent.mongoose_bite.enabled
  if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) SurvivalMbApWfiStMainActions()

  unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStMainPostConditions()
  {
   #call_action_list,name=wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled
   if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) SurvivalWfiStMainActions()

   unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStMainPostConditions()
   {
    #call_action_list,name=st,if=active_enemies<2
    if Enemies(tagged=1) < 2 SurvivalStMainActions()

    unless Enemies(tagged=1) < 2 and SurvivalStMainPostConditions()
    {
     #call_action_list,name=cleave,if=active_enemies>1
     if Enemies(tagged=1) > 1 SurvivalCleaveMainActions()
    }
   }
  }
 }
}

AddFunction SurvivalDefaultMainPostConditions
{
 SurvivalCdsMainPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStMainPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStMainPostConditions() or Enemies(tagged=1) < 2 and SurvivalStMainPostConditions() or Enemies(tagged=1) > 1 and SurvivalCleaveMainPostConditions()
}

AddFunction SurvivalDefaultShortCdActions
{
 #auto_attack
 # SurvivalGetInMeleeRange()
 #call_action_list,name=cds
 SurvivalCdsShortCdActions()

 unless SurvivalCdsShortCdPostConditions()
 {
  #call_action_list,name=mb_ap_wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled&talent.alpha_predator.enabled&talent.mongoose_bite.enabled
  if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) SurvivalMbApWfiStShortCdActions()

  unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStShortCdPostConditions()
  {
   #call_action_list,name=wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled
   if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) SurvivalWfiStShortCdActions()

   unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStShortCdPostConditions()
   {
    #call_action_list,name=st,if=active_enemies<2
    if Enemies(tagged=1) < 2 SurvivalStShortCdActions()

    unless Enemies(tagged=1) < 2 and SurvivalStShortCdPostConditions()
    {
     #call_action_list,name=cleave,if=active_enemies>1
     if Enemies(tagged=1) > 1 SurvivalCleaveShortCdActions()
    }
   }
  }
 }
}

AddFunction SurvivalDefaultShortCdPostConditions
{
 SurvivalCdsShortCdPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStShortCdPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStShortCdPostConditions() or Enemies(tagged=1) < 2 and SurvivalStShortCdPostConditions() or Enemies(tagged=1) > 1 and SurvivalCleaveShortCdPostConditions()
}

AddFunction SurvivalDefaultCdActions
{
 # SurvivalInterruptActions()
 #use_items
 SurvivalUseItemActions()
 #call_action_list,name=cds
 SurvivalCdsCdActions()

 unless SurvivalCdsCdPostConditions()
 {
  #call_action_list,name=mb_ap_wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled&talent.alpha_predator.enabled&talent.mongoose_bite.enabled
  if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) SurvivalMbApWfiStCdActions()

  unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStCdPostConditions()
  {
   #call_action_list,name=wfi_st,if=active_enemies<3&talent.wildfire_infusion.enabled
   if Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) SurvivalWfiStCdActions()

   unless Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStCdPostConditions()
   {
    #call_action_list,name=st,if=active_enemies<2
    if Enemies(tagged=1) < 2 SurvivalStCdActions()

    unless Enemies(tagged=1) < 2 and SurvivalStCdPostConditions()
    {
     #call_action_list,name=cleave,if=active_enemies>1
     if Enemies(tagged=1) > 1 SurvivalCleaveCdActions()

     unless Enemies(tagged=1) > 1 and SurvivalCleaveCdPostConditions()
     {
      #arcane_torrent
      Spell(arcane_torrent_focus)
     }
    }
   }
  }
 }
}

AddFunction SurvivalDefaultCdPostConditions
{
 SurvivalCdsCdPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and Talent(alpha_predator_talent) and Talent(mongoose_bite_talent) and SurvivalMbApWfiStCdPostConditions() or Enemies(tagged=1) < 3 and Talent(wildfire_infusion_talent) and SurvivalWfiStCdPostConditions() or Enemies(tagged=1) < 2 and SurvivalStCdPostConditions() or Enemies(tagged=1) > 1 and SurvivalCleaveCdPostConditions()
}

### actions.cds

AddFunction SurvivalCdsMainActions
{
}

AddFunction SurvivalCdsMainPostConditions
{
}

AddFunction SurvivalCdsShortCdActions
{
 #aspect_of_the_eagle,if=target.distance>=6
 if target.Distance(more 6) Spell(aspect_of_the_eagle)
}

AddFunction SurvivalCdsShortCdPostConditions
{
}

AddFunction SurvivalCdsCdActions
{
 #blood_fury,if=cooldown.coordinated_assault.remains>30
 if SpellCooldown(coordinated_assault) > 30 Spell(blood_fury_ap)
 #ancestral_call,if=cooldown.coordinated_assault.remains>30
 if SpellCooldown(coordinated_assault) > 30 Spell(ancestral_call)
 #fireblood,if=cooldown.coordinated_assault.remains>30
 if SpellCooldown(coordinated_assault) > 30 Spell(fireblood)
 #lights_judgment
 Spell(lights_judgment)
 #berserking,if=cooldown.coordinated_assault.remains>60|time_to_die<11
 if SpellCooldown(coordinated_assault) > 60 or target.TimeToDie() < 11 Spell(berserking)
 #potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)|time_to_die<26
 # if { BuffPresent(coordinated_assault_buff) and { BuffPresent(berserking_buff) or BuffPresent(blood_fury_ap_buff) or not Race(Troll) and not Race(Orc) } or target.TimeToDie() < 26 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
}

AddFunction SurvivalCdsCdPostConditions
{
}

### actions.cleave

AddFunction SurvivalCleaveMainActions
{
 #carve,if=dot.shrapnel_bomb.ticking
 if target.DebuffPresent(shrapnel_bomb_debuff) and target.InRange(muzzle) Spell(carve)
 #wildfire_bomb,if=!talent.guerrilla_tactics.enabled|full_recharge_time<gcd
 if not Talent(guerrilla_tactics_talent) or SpellFullRecharge(wildfire_bomb) < GCD() Spell(wildfire_bomb)
 #mongoose_bite,target_if=max:debuff.latent_poison.stack,if=debuff.latent_poison.stack=10
 if target.DebuffStacks(latent_poison) == 10 and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #chakrams
 Spell(chakrams)
 #kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
 if Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() Spell(kill_command_survival)
 #butchery,if=full_recharge_time<gcd|!talent.wildfire_infusion.enabled|dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3
 if { SpellFullRecharge(butchery) < GCD() or not Talent(wildfire_infusion_talent) or target.DebuffPresent(shrapnel_bomb_debuff) and target.DebuffStacks(internal_bleeding_debuff) < 3 } and target.InRange(butchery) Spell(butchery)
 #carve,if=talent.guerrilla_tactics.enabled
 if Talent(guerrilla_tactics_talent) and target.InRange(muzzle) Spell(carve)
 #wildfire_bomb,if=dot.wildfire_bomb.refreshable|talent.wildfire_infusion.enabled
 if target.DebuffRefreshable(wildfire_bomb_debuff) or Talent(wildfire_infusion_talent) Spell(wildfire_bomb)
 #serpent_sting,target_if=min:remains,if=buff.vipers_venom.up
 if BuffPresent(vipers_venom_buff) Spell(serpent_sting_sv)
 #carve,if=cooldown.wildfire_bomb.remains>variable.carve_cdr%2
 if SpellCooldown(wildfire_bomb) > carve_cdr() / 2 and target.InRange(muzzle) Spell(carve)
 #harpoon,if=talent.terms_of_engagement.enabled
 if Talent(terms_of_engagement_talent) and target.InRange(harpoon) Spell(harpoon)
 #serpent_sting,target_if=min:remains,if=refreshable&buff.tip_of_the_spear.stack<3
 if target.Refreshable(serpent_sting_sv_debuff) and BuffStacks(tip_of_the_spear_buff) < 3 Spell(serpent_sting_sv)
 #mongoose_bite,target_if=max:debuff.latent_poison.stack
 if target.InRange(mongoose_bite) Spell(mongoose_bite)
 #raptor_strike,target_if=max:debuff.latent_poison.stack
 if target.InRange(raptor_strike) Spell(raptor_strike)
}

AddFunction SurvivalCleaveMainPostConditions
{
}

AddFunction SurvivalCleaveShortCdActions
{
 #variable,name=carve_cdr,op=setif,value=active_enemies,value_else=5,condition=active_enemies<5
 #a_murder_of_crows
 Spell(a_murder_of_crows)

 unless target.DebuffPresent(shrapnel_bomb_debuff) and Spell(carve) or { not Talent(guerrilla_tactics_talent) or SpellFullRecharge(wildfire_bomb) < GCD() } and Spell(wildfire_bomb) or target.DebuffStacks(latent_poison) == 10 and Spell(mongoose_bite) or Spell(chakrams) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and Spell(kill_command_survival) or { SpellFullRecharge(butchery) < GCD() or not Talent(wildfire_infusion_talent) or target.DebuffPresent(shrapnel_bomb_debuff) and target.DebuffStacks(internal_bleeding_debuff) < 3 } and Spell(butchery) or Talent(guerrilla_tactics_talent) and Spell(carve)
 {
  #flanking_strike,if=focus+cast_regen<focus.max
  if Focus() + FocusCastingRegen(flanking_strike) < MaxFocus() and target.InRange(flanking_strike) Spell(flanking_strike)

  unless { target.DebuffRefreshable(wildfire_bomb_debuff) or Talent(wildfire_infusion_talent) } and Spell(wildfire_bomb) or BuffPresent(vipers_venom_buff) and Spell(serpent_sting_sv) or SpellCooldown(wildfire_bomb) > carve_cdr() / 2 and Spell(carve)
  {
   #steel_trap
   if target.InRange(muzzle) Spell(steel_trap)
  }
 }
}

AddFunction SurvivalCleaveShortCdPostConditions
{
 target.DebuffPresent(shrapnel_bomb_debuff) and Spell(carve) or { not Talent(guerrilla_tactics_talent) or SpellFullRecharge(wildfire_bomb) < GCD() } and Spell(wildfire_bomb) or target.DebuffStacks(latent_poison) == 10 and Spell(mongoose_bite) or Spell(chakrams) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and Spell(kill_command_survival) or { SpellFullRecharge(butchery) < GCD() or not Talent(wildfire_infusion_talent) or target.DebuffPresent(shrapnel_bomb_debuff) and target.DebuffStacks(internal_bleeding_debuff) < 3 } and Spell(butchery) or Talent(guerrilla_tactics_talent) and Spell(carve) or { target.DebuffRefreshable(wildfire_bomb_debuff) or Talent(wildfire_infusion_talent) } and Spell(wildfire_bomb) or BuffPresent(vipers_venom_buff) and Spell(serpent_sting_sv) or SpellCooldown(wildfire_bomb) > carve_cdr() / 2 and Spell(carve) or Talent(terms_of_engagement_talent) and target.InRange(harpoon) and Spell(harpoon) or target.Refreshable(serpent_sting_sv_debuff) and BuffStacks(tip_of_the_spear_buff) < 3 and Spell(serpent_sting_sv) or Spell(mongoose_bite) or Spell(raptor_strike)
}

AddFunction SurvivalCleaveCdActions
{
 unless Spell(a_murder_of_crows)
 {
  #coordinated_assault
  Spell(coordinated_assault)
 }
}

AddFunction SurvivalCleaveCdPostConditions
{
 Spell(a_murder_of_crows) or target.DebuffPresent(shrapnel_bomb_debuff) and Spell(carve) or { not Talent(guerrilla_tactics_talent) or SpellFullRecharge(wildfire_bomb) < GCD() } and Spell(wildfire_bomb) or target.DebuffStacks(latent_poison) == 10 and Spell(mongoose_bite) or Spell(chakrams) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and Spell(kill_command_survival) or { SpellFullRecharge(butchery) < GCD() or not Talent(wildfire_infusion_talent) or target.DebuffPresent(shrapnel_bomb_debuff) and target.DebuffStacks(internal_bleeding_debuff) < 3 } and Spell(butchery) or Talent(guerrilla_tactics_talent) and Spell(carve) or { target.DebuffRefreshable(wildfire_bomb_debuff) or Talent(wildfire_infusion_talent) } and Spell(wildfire_bomb) or BuffPresent(vipers_venom_buff) and Spell(serpent_sting_sv) or SpellCooldown(wildfire_bomb) > carve_cdr() / 2 and Spell(carve) or Spell(steel_trap) or Talent(terms_of_engagement_talent) and target.InRange(harpoon) and Spell(harpoon) or target.Refreshable(serpent_sting_sv_debuff) and BuffStacks(tip_of_the_spear_buff) < 3 and Spell(serpent_sting_sv) or Spell(mongoose_bite) or Spell(raptor_strike)
}

### actions.mb_ap_wfi_st

AddFunction SurvivalMbApWfiStMainActions
{
 #serpent_sting,if=!dot.serpent_sting.ticking
 if not target.DebuffPresent(serpent_sting_sv_debuff) Spell(serpent_sting_sv)
 #wildfire_bomb,if=full_recharge_time<gcd|(focus+cast_regen<focus.max)&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
 if SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } Spell(wildfire_bomb)
 #mongoose_bite,if=buff.mongoose_fury.remains&next_wi_bomb.pheromone
 if BuffPresent(mongoose_fury_buff) and SpellUsable(270323) and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
 if Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } Spell(kill_command_survival)
 #wildfire_bomb,if=next_wi_bomb.shrapnel&focus>60&dot.serpent_sting.remains>3*gcd
 if SpellUsable(270335) and Focus() > 60 and target.DebuffRemaining(serpent_sting_sv_debuff) > 3 * GCD() Spell(wildfire_bomb)
 #serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|!talent.vipers_venom.enabled|next_wi_bomb.volatile&!dot.shrapnel_bomb.ticking|azerite.latent_poison.enabled|azerite.venomous_fangs.enabled)
 if BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } Spell(serpent_sting_sv)
 #mongoose_bite,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
 if { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #serpent_sting,if=refreshable
 if target.Refreshable(serpent_sting_sv_debuff) Spell(serpent_sting_sv)
 #wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
 if SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 Spell(wildfire_bomb)
}

AddFunction SurvivalMbApWfiStMainPostConditions
{
}

AddFunction SurvivalMbApWfiStShortCdActions
{
 unless not target.DebuffPresent(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb)
 {
  #a_murder_of_crows
  Spell(a_murder_of_crows)
  #steel_trap
  if target.InRange(muzzle) Spell(steel_trap)
 }
}

AddFunction SurvivalMbApWfiStShortCdPostConditions
{
 not target.DebuffPresent(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb) or BuffPresent(mongoose_fury_buff) and SpellUsable(270323) and Spell(mongoose_bite) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or SpellUsable(270335) and Focus() > 60 and target.DebuffRemaining(serpent_sting_sv_debuff) > 3 * GCD() and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and Spell(mongoose_bite) or target.Refreshable(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 } and Spell(wildfire_bomb)
}

AddFunction SurvivalMbApWfiStCdActions
{
 unless not target.DebuffPresent(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb)
 {
  #coordinated_assault
  Spell(coordinated_assault)
 }
}

AddFunction SurvivalMbApWfiStCdPostConditions
{
 not target.DebuffPresent(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb) or Spell(a_murder_of_crows) or Spell(steel_trap) or BuffPresent(mongoose_fury_buff) and SpellUsable(270323) and Spell(mongoose_bite) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or SpellUsable(270335) and Focus() > 60 and target.DebuffRemaining(serpent_sting_sv_debuff) > 3 * GCD() and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and Spell(mongoose_bite) or target.Refreshable(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 } and Spell(wildfire_bomb)
}

### actions.precombat

AddFunction SurvivalPrecombatMainActions
{
 #harpoon
 # if CheckBoxOn(opt_harpoon) Spell(harpoon)
}

AddFunction SurvivalPrecombatMainPostConditions
{
}

AddFunction SurvivalPrecombatShortCdActions
{
 #flask
 #augmentation
 #food
 #summon_pet
 # SurvivalSummonPet()
 #steel_trap
 # Spell(steel_trap)
}

AddFunction SurvivalPrecombatShortCdPostConditions
{
 # CheckBoxOn(opt_harpoon) and Spell(harpoon)
}

AddFunction SurvivalPrecombatCdActions
{
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
}

AddFunction SurvivalPrecombatCdPostConditions
{
 # Spell(steel_trap) or Spell(harpoon)
}

### actions.st

AddFunction SurvivalStMainActions
{
 #mongoose_bite,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&(buff.coordinated_assault.remains<gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd)
 if Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #raptor_strike,if=talent.birds_of_prey.enabled&buff.coordinated_assault.up&(buff.coordinated_assault.remains<gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd)
 if Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and target.InRange(raptor_strike) Spell(raptor_strike)
 #serpent_sting,if=buff.vipers_venom.up&buff.vipers_venom.remains<gcd
 if BuffPresent(vipers_venom_buff) and BuffRemaining(vipers_venom_buff) < GCD() Spell(serpent_sting_sv)
 #kill_command,if=focus+cast_regen<focus.max&(!talent.alpha_predator.enabled|full_recharge_time<gcd)
 if Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { not Talent(alpha_predator_talent) or SpellFullRecharge(kill_command_survival) < GCD() } Spell(kill_command_survival)
 #wildfire_bomb,if=focus+cast_regen<focus.max&(full_recharge_time<gcd|!dot.wildfire_bomb.ticking&(buff.mongoose_fury.down|full_recharge_time<4.5*gcd))
 if Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellFullRecharge(wildfire_bomb) < GCD() or not target.DebuffPresent(wildfire_bomb_debuff) and { BuffExpires(mongoose_fury_buff) or SpellFullRecharge(wildfire_bomb) < 4.5 * GCD() } } Spell(wildfire_bomb)
 #serpent_sting,if=buff.vipers_venom.up&dot.serpent_sting.remains<4*gcd|!talent.vipers_venom.enabled&!dot.serpent_sting.ticking&!buff.coordinated_assault.up|refreshable&(azerite.latent_poison.enabled|azerite.venomous_fangs.enabled)
 if BuffPresent(vipers_venom_buff) and target.DebuffRemaining(serpent_sting_sv_debuff) < 4 * GCD() or not Talent(vipers_venom_talent) and not target.DebuffPresent(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) or target.Refreshable(serpent_sting_sv_debuff) and { HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } Spell(serpent_sting_sv)
 #harpoon,if=talent.terms_of_engagement.enabled|azerite.up_close_and_personal.enabled
 if { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) Spell(harpoon)
 #chakrams
 Spell(chakrams)
 #kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<4|focus<action.mongoose_bite.cost)
 if Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 4 or Focus() < PowerCost(mongoose_bite) } Spell(kill_command_survival)
 #mongoose_bite,if=buff.mongoose_fury.up|focus>60
 if { BuffPresent(mongoose_fury_buff) or Focus() > 60 } and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #raptor_strike
 if target.InRange(raptor_strike) Spell(raptor_strike)
 #serpent_sting,if=dot.serpent_sting.refreshable&!buff.coordinated_assault.up
 if target.DebuffRefreshable(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) Spell(serpent_sting_sv)
 #wildfire_bomb,if=dot.wildfire_bomb.refreshable
 if target.DebuffRefreshable(wildfire_bomb_debuff) Spell(wildfire_bomb)
}

AddFunction SurvivalStMainPostConditions
{
}

AddFunction SurvivalStShortCdActions
{
 #a_murder_of_crows
 Spell(a_murder_of_crows)

 unless Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(mongoose_bite) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(raptor_strike) or BuffPresent(vipers_venom_buff) and BuffRemaining(vipers_venom_buff) < GCD() and Spell(serpent_sting_sv) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { not Talent(alpha_predator_talent) or SpellFullRecharge(kill_command_survival) < GCD() } and Spell(kill_command_survival) or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellFullRecharge(wildfire_bomb) < GCD() or not target.DebuffPresent(wildfire_bomb_debuff) and { BuffExpires(mongoose_fury_buff) or SpellFullRecharge(wildfire_bomb) < 4.5 * GCD() } } and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) and target.DebuffRemaining(serpent_sting_sv_debuff) < 4 * GCD() or not Talent(vipers_venom_talent) and not target.DebuffPresent(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) or target.Refreshable(serpent_sting_sv_debuff) and { HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv)
 {
  #steel_trap
  if target.InRange(muzzle) Spell(steel_trap)

  unless { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon) or Spell(chakrams)
  {
   #flanking_strike,if=focus+cast_regen<focus.max
   if Focus() + FocusCastingRegen(flanking_strike) < MaxFocus() and target.InRange(flanking_strike) Spell(flanking_strike)
  }
 }
}

AddFunction SurvivalStShortCdPostConditions
{
 Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(mongoose_bite) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(raptor_strike) or BuffPresent(vipers_venom_buff) and BuffRemaining(vipers_venom_buff) < GCD() and Spell(serpent_sting_sv) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { not Talent(alpha_predator_talent) or SpellFullRecharge(kill_command_survival) < GCD() } and Spell(kill_command_survival) or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellFullRecharge(wildfire_bomb) < GCD() or not target.DebuffPresent(wildfire_bomb_debuff) and { BuffExpires(mongoose_fury_buff) or SpellFullRecharge(wildfire_bomb) < 4.5 * GCD() } } and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) and target.DebuffRemaining(serpent_sting_sv_debuff) < 4 * GCD() or not Talent(vipers_venom_talent) and not target.DebuffPresent(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) or target.Refreshable(serpent_sting_sv_debuff) and { HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv) or { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon) or Spell(chakrams) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 4 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 } and Spell(mongoose_bite) or Spell(raptor_strike) or target.DebuffRefreshable(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) and Spell(serpent_sting_sv) or target.DebuffRefreshable(wildfire_bomb_debuff) and Spell(wildfire_bomb)
}

AddFunction SurvivalStCdActions
{
 unless Spell(a_murder_of_crows) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(mongoose_bite) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(raptor_strike) or BuffPresent(vipers_venom_buff) and BuffRemaining(vipers_venom_buff) < GCD() and Spell(serpent_sting_sv) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { not Talent(alpha_predator_talent) or SpellFullRecharge(kill_command_survival) < GCD() } and Spell(kill_command_survival) or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellFullRecharge(wildfire_bomb) < GCD() or not target.DebuffPresent(wildfire_bomb_debuff) and { BuffExpires(mongoose_fury_buff) or SpellFullRecharge(wildfire_bomb) < 4.5 * GCD() } } and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) and target.DebuffRemaining(serpent_sting_sv_debuff) < 4 * GCD() or not Talent(vipers_venom_talent) and not target.DebuffPresent(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) or target.Refreshable(serpent_sting_sv_debuff) and { HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv) or Spell(steel_trap) or { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon)
 {
  #coordinated_assault
  Spell(coordinated_assault)
 }
}

AddFunction SurvivalStCdPostConditions
{
 Spell(a_murder_of_crows) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(mongoose_bite) or Talent(birds_of_prey_talent) and BuffPresent(coordinated_assault_buff) and { BuffRemaining(coordinated_assault_buff) < GCD() or BuffPresent(blur_of_talons_buff) and BuffRemaining(blur_of_talons_buff) < GCD() } and Spell(raptor_strike) or BuffPresent(vipers_venom_buff) and BuffRemaining(vipers_venom_buff) < GCD() and Spell(serpent_sting_sv) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { not Talent(alpha_predator_talent) or SpellFullRecharge(kill_command_survival) < GCD() } and Spell(kill_command_survival) or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellFullRecharge(wildfire_bomb) < GCD() or not target.DebuffPresent(wildfire_bomb_debuff) and { BuffExpires(mongoose_fury_buff) or SpellFullRecharge(wildfire_bomb) < 4.5 * GCD() } } and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) and target.DebuffRemaining(serpent_sting_sv_debuff) < 4 * GCD() or not Talent(vipers_venom_talent) and not target.DebuffPresent(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) or target.Refreshable(serpent_sting_sv_debuff) and { HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) } } and Spell(serpent_sting_sv) or Spell(steel_trap) or { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon) or Spell(chakrams) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and { BuffStacks(mongoose_fury_buff) < 4 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 } and Spell(mongoose_bite) or Spell(raptor_strike) or target.DebuffRefreshable(serpent_sting_sv_debuff) and not BuffPresent(coordinated_assault_buff) and Spell(serpent_sting_sv) or target.DebuffRefreshable(wildfire_bomb_debuff) and Spell(wildfire_bomb)
}

### actions.wfi_st

AddFunction SurvivalWfiStMainActions
{
 #mongoose_bite,if=azerite.wilderness_survival.enabled&next_wi_bomb.volatile&dot.serpent_sting.remains>2.1*gcd&dot.serpent_sting.remains<3.5*gcd&cooldown.wildfire_bomb.remains>2.5*gcd
 if HasAzeriteTrait(wilderness_survival_trait) and SpellUsable(271045) and target.DebuffRemaining(serpent_sting_sv_debuff) > 2.1 * GCD() and target.DebuffRemaining(serpent_sting_sv_debuff) < 3.5 * GCD() and SpellCooldown(wildfire_bomb) > 2.5 * GCD() and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #wildfire_bomb,if=full_recharge_time<gcd|(focus+cast_regen<focus.max)&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
 if SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } Spell(wildfire_bomb)
 #kill_command,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3&(!talent.alpha_predator.enabled|buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
 if Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and BuffStacks(tip_of_the_spear_buff) < 3 and { not Talent(alpha_predator_talent) or BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } Spell(kill_command_survival)
 #raptor_strike,if=dot.internal_bleeding.stack<3&dot.shrapnel_bomb.ticking&!talent.mongoose_bite.enabled
 if target.DebuffStacks(internal_bleeding_debuff) < 3 and target.DebuffPresent(shrapnel_bomb_debuff) and not Talent(mongoose_bite_talent) and target.InRange(raptor_strike) Spell(raptor_strike)
 #wildfire_bomb,if=next_wi_bomb.shrapnel&buff.mongoose_fury.down&(cooldown.kill_command.remains>gcd|focus>60)&!dot.serpent_sting.refreshable
 if SpellUsable(270335) and BuffExpires(mongoose_fury_buff) and { SpellCooldown(kill_command_survival) > GCD() or Focus() > 60 } and not target.DebuffRefreshable(serpent_sting_sv_debuff) Spell(wildfire_bomb)
 #serpent_sting,if=buff.vipers_venom.up|refreshable&(!talent.mongoose_bite.enabled|!talent.vipers_venom.enabled|next_wi_bomb.volatile&!dot.shrapnel_bomb.ticking|azerite.latent_poison.enabled|azerite.venomous_fangs.enabled|buff.mongoose_fury.stack=5)
 if BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) or BuffStacks(mongoose_fury_buff) == 5 } Spell(serpent_sting_sv)
 #harpoon,if=talent.terms_of_engagement.enabled|azerite.up_close_and_personal.enabled
 if { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) Spell(harpoon)
 #mongoose_bite,if=buff.mongoose_fury.up|focus>60|dot.shrapnel_bomb.ticking
 if { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and target.InRange(mongoose_bite) Spell(mongoose_bite)
 #raptor_strike
 if target.InRange(raptor_strike) Spell(raptor_strike)
 #serpent_sting,if=refreshable
 if target.Refreshable(serpent_sting_sv_debuff) Spell(serpent_sting_sv)
 #wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
 if SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 Spell(wildfire_bomb)
}

AddFunction SurvivalWfiStMainPostConditions
{
}

AddFunction SurvivalWfiStShortCdActions
{
 #a_murder_of_crows
 Spell(a_murder_of_crows)

 unless HasAzeriteTrait(wilderness_survival_trait) and SpellUsable(271045) and target.DebuffRemaining(serpent_sting_sv_debuff) > 2.1 * GCD() and target.DebuffRemaining(serpent_sting_sv_debuff) < 3.5 * GCD() and SpellCooldown(wildfire_bomb) > 2.5 * GCD() and Spell(mongoose_bite) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and BuffStacks(tip_of_the_spear_buff) < 3 and { not Talent(alpha_predator_talent) or BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or target.DebuffStacks(internal_bleeding_debuff) < 3 and target.DebuffPresent(shrapnel_bomb_debuff) and not Talent(mongoose_bite_talent) and Spell(raptor_strike) or SpellUsable(270335) and BuffExpires(mongoose_fury_buff) and { SpellCooldown(kill_command_survival) > GCD() or Focus() > 60 } and not target.DebuffRefreshable(serpent_sting_sv_debuff) and Spell(wildfire_bomb)
 {
  #steel_trap
  if target.InRange(muzzle) Spell(steel_trap)
  #flanking_strike,if=focus+cast_regen<focus.max
  if Focus() + FocusCastingRegen(flanking_strike) < MaxFocus() and target.InRange(flanking_strike) Spell(flanking_strike)
 }
}

AddFunction SurvivalWfiStShortCdPostConditions
{
 HasAzeriteTrait(wilderness_survival_trait) and SpellUsable(271045) and target.DebuffRemaining(serpent_sting_sv_debuff) > 2.1 * GCD() and target.DebuffRemaining(serpent_sting_sv_debuff) < 3.5 * GCD() and SpellCooldown(wildfire_bomb) > 2.5 * GCD() and Spell(mongoose_bite) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and BuffStacks(tip_of_the_spear_buff) < 3 and { not Talent(alpha_predator_talent) or BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or target.DebuffStacks(internal_bleeding_debuff) < 3 and target.DebuffPresent(shrapnel_bomb_debuff) and not Talent(mongoose_bite_talent) and Spell(raptor_strike) or SpellUsable(270335) and BuffExpires(mongoose_fury_buff) and { SpellCooldown(kill_command_survival) > GCD() or Focus() > 60 } and not target.DebuffRefreshable(serpent_sting_sv_debuff) and Spell(wildfire_bomb) or { BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) or BuffStacks(mongoose_fury_buff) == 5 } } and Spell(serpent_sting_sv) or { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and Spell(mongoose_bite) or Spell(raptor_strike) or target.Refreshable(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 } and Spell(wildfire_bomb)
}

AddFunction SurvivalWfiStCdActions
{
 unless Spell(a_murder_of_crows)
 {
  #coordinated_assault
  Spell(coordinated_assault)
 }
}

AddFunction SurvivalWfiStCdPostConditions
{
 Spell(a_murder_of_crows) or HasAzeriteTrait(wilderness_survival_trait) and SpellUsable(271045) and target.DebuffRemaining(serpent_sting_sv_debuff) > 2.1 * GCD() and target.DebuffRemaining(serpent_sting_sv_debuff) < 3.5 * GCD() and SpellCooldown(wildfire_bomb) > 2.5 * GCD() and Spell(mongoose_bite) or { SpellFullRecharge(wildfire_bomb) < GCD() or Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() and { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) and target.DebuffRefreshable(serpent_sting_sv_debuff) or SpellUsable(270323) and not BuffPresent(mongoose_fury_buff) and Focus() + FocusCastingRegen(wildfire_bomb) < MaxFocus() - FocusCastingRegen(kill_command_survival) * 3 } } and Spell(wildfire_bomb) or Focus() + FocusCastingRegen(kill_command_survival) < MaxFocus() and BuffStacks(tip_of_the_spear_buff) < 3 and { not Talent(alpha_predator_talent) or BuffStacks(mongoose_fury_buff) < 5 or Focus() < PowerCost(mongoose_bite) } and Spell(kill_command_survival) or target.DebuffStacks(internal_bleeding_debuff) < 3 and target.DebuffPresent(shrapnel_bomb_debuff) and not Talent(mongoose_bite_talent) and Spell(raptor_strike) or SpellUsable(270335) and BuffExpires(mongoose_fury_buff) and { SpellCooldown(kill_command_survival) > GCD() or Focus() > 60 } and not target.DebuffRefreshable(serpent_sting_sv_debuff) and Spell(wildfire_bomb) or Spell(steel_trap) or { BuffPresent(vipers_venom_buff) or target.Refreshable(serpent_sting_sv_debuff) and { not Talent(mongoose_bite_talent) or not Talent(vipers_venom_talent) or SpellUsable(271045) and not target.DebuffPresent(shrapnel_bomb_debuff) or HasAzeriteTrait(latent_poison_trait) or HasAzeriteTrait(venomous_fangs_trait) or BuffStacks(mongoose_fury_buff) == 5 } } and Spell(serpent_sting_sv) or { Talent(terms_of_engagement_talent) or HasAzeriteTrait(up_close_and_personal_trait) } and target.InRange(harpoon) and Spell(harpoon) or { BuffPresent(mongoose_fury_buff) or Focus() > 60 or target.DebuffPresent(shrapnel_bomb_debuff) } and Spell(mongoose_bite) or Spell(raptor_strike) or target.Refreshable(serpent_sting_sv_debuff) and Spell(serpent_sting_sv) or { SpellUsable(271045) and target.DebuffPresent(serpent_sting_sv_debuff) or SpellUsable(270323) or SpellUsable(270335) and Focus() > 50 } and Spell(wildfire_bomb)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
