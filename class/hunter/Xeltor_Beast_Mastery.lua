local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_beast_mastery_functions"
	local desc = "[Xel][7.3.5] Hunter: Beast Mastery Functions"
	local code = [[
### actions.default

AddFunction BeastMasteryDefaultMainActions
{
 #barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
 if pet.BuffPresent(pet_frenzy_buff) and pet.BuffRemaining(pet_frenzy_buff) <= GCD() Spell(barbed_shot)
 #multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
 if Enemies(tagged=1) > 2 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
 #chimaera_shot
 Spell(chimaera_shot)
 #kill_command
 if pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() Spell(kill_command)
 #dire_beast
 Spell(dire_beast)
 #barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
 if pet.BuffExpires(pet_frenzy_buff) and Charges(barbed_shot count=0) > 1.4 or SpellFullRecharge(barbed_shot) < GCD() or target.TimeToDie() < 9 Spell(barbed_shot)
 #multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
 if Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
 #cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)
 if { Enemies(tagged=1) < 2 or SpellCooldown(kill_command) > TimeToMaxFocus() } and { BuffPresent(bestial_wrath_buff) and Enemies(tagged=1) > 1 or SpellCooldown(kill_command) > 1 + GCD() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or Focus() - PowerCost(cobra_shot) + FocusRegenRate() * { SpellCooldown(kill_command) - 1 } > PowerCost(kill_command) } Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultMainPostConditions
{
}

AddFunction BeastMasteryDefaultShortCdActions
{
 unless pet.BuffPresent(pet_frenzy_buff) and pet.BuffRemaining(pet_frenzy_buff) <= GCD() and Spell(barbed_shot)
 {
  #a_murder_of_crows
  Spell(a_murder_of_crows)
  #spitting_cobra
  Spell(spitting_cobra)
  #bestial_wrath,if=!buff.bestial_wrath.up
  if not BuffPresent(bestial_wrath_buff) Spell(bestial_wrath)

  unless Enemies(tagged=1) > 2 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Spell(chimaera_shot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Spell(dire_beast) or { pet.BuffExpires(pet_frenzy_buff) and Charges(barbed_shot count=0) > 1.4 or SpellFullRecharge(barbed_shot) < GCD() or target.TimeToDie() < 9 } and Spell(barbed_shot)
  {
   #barrage
   Spell(barrage)
  }
 }
}

AddFunction BeastMasteryDefaultShortCdPostConditions
{
 pet.BuffPresent(pet_frenzy_buff) and pet.BuffRemaining(pet_frenzy_buff) <= GCD() and Spell(barbed_shot) or Enemies(tagged=1) > 2 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Spell(chimaera_shot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Spell(dire_beast) or { pet.BuffExpires(pet_frenzy_buff) and Charges(barbed_shot count=0) > 1.4 or SpellFullRecharge(barbed_shot) < GCD() or target.TimeToDie() < 9 } and Spell(barbed_shot) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or { Enemies(tagged=1) < 2 or SpellCooldown(kill_command) > TimeToMaxFocus() } and { BuffPresent(bestial_wrath_buff) and Enemies(tagged=1) > 1 or SpellCooldown(kill_command) > 1 + GCD() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or Focus() - PowerCost(cobra_shot) + FocusRegenRate() * { SpellCooldown(kill_command) - 1 } > PowerCost(kill_command) } and Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultCdActions
{
 #auto_shot
 #counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
 # if HasEquippedItem(sephuzs_secret) and target.IsInterruptible() and not SpellCooldown(buff_sephuzs_secret) > 0 and not BuffPresent(sephuzs_secret_buff) BeastMasteryInterruptActions()
 #use_items
 # BeastMasteryUseItemActions()
 #berserking,if=cooldown.bestial_wrath.remains>30
 if SpellCooldown(bestial_wrath) > 30 Spell(berserking)
 #blood_fury,if=cooldown.bestial_wrath.remains>30
 if SpellCooldown(bestial_wrath) > 30 Spell(blood_fury_ap)
 #ancestral_call,if=cooldown.bestial_wrath.remains>30
 if SpellCooldown(bestial_wrath) > 30 Spell(ancestral_call)
 #fireblood,if=cooldown.bestial_wrath.remains>30
 if SpellCooldown(bestial_wrath) > 30 Spell(fireblood)
 #lights_judgment
 # Spell(lights_judgment)
 #potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
 # if BuffPresent(bestial_wrath_buff) and BuffPresent(aspect_of_the_wild_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

 unless pet.BuffPresent(pet_frenzy_buff) and pet.BuffRemaining(pet_frenzy_buff) <= GCD() and Spell(barbed_shot) or Spell(a_murder_of_crows) or Spell(spitting_cobra)
 {
  #stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
  if BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) < GCD() or target.TimeToDie() < 15 Spell(stampede)
  #aspect_of_the_wild
  Spell(aspect_of_the_wild)
 }
}

AddFunction BeastMasteryDefaultCdPostConditions
{
 pet.BuffPresent(pet_frenzy_buff) and pet.BuffRemaining(pet_frenzy_buff) <= GCD() and Spell(barbed_shot) or Spell(a_murder_of_crows) or Spell(spitting_cobra) or Enemies(tagged=1) > 2 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Spell(chimaera_shot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Spell(dire_beast) or { pet.BuffExpires(pet_frenzy_buff) and Charges(barbed_shot count=0) > 1.4 or SpellFullRecharge(barbed_shot) < GCD() or target.TimeToDie() < 9 } and Spell(barbed_shot) or Spell(barrage) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or { Enemies(tagged=1) < 2 or SpellCooldown(kill_command) > TimeToMaxFocus() } and { BuffPresent(bestial_wrath_buff) and Enemies(tagged=1) > 1 or SpellCooldown(kill_command) > 1 + GCD() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or Focus() - PowerCost(cobra_shot) + FocusRegenRate() * { SpellCooldown(kill_command) - 1 } > PowerCost(kill_command) } and Spell(cobra_shot)
}

### actions.precombat

AddFunction BeastMasteryPrecombatMainActions
{
}

AddFunction BeastMasteryPrecombatMainPostConditions
{
}

AddFunction BeastMasteryPrecombatShortCdActions
{
 #flask
 #augmentation
 #food
 #summon_pet
 # BeastMasterySummonPet()
}

AddFunction BeastMasteryPrecombatShortCdPostConditions
{
}

AddFunction BeastMasteryPrecombatCdActions
{
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #aspect_of_the_wild
 Spell(aspect_of_the_wild)
}

AddFunction BeastMasteryPrecombatCdPostConditions
{
}
]]

	OvaleScripts:RegisterScript("HUNTER", nil, name, desc, code, "include")
end
