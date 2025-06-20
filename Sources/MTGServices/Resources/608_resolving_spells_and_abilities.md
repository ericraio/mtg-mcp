# 608. Resolving Spells and Abilities

*Chapter: Spells, Abilities, and Effects*

---

608. Resolving Spells and Abilities



608.1. Each time all players pass in succession, the spell or ability on top of the stack resolves. (See rule 609, “Effects.”)



608.2. If the object that’s resolving is an instant spell, a sorcery spell, or an ability, its resolution may involve several steps. The steps described in rules 608.2a and 608.2b are followed first. The steps described in rules 608.2c–m are then followed as appropriate, in no specific order. The steps described in rule 608.2n and 608.2p are followed last.



608.2a If a triggered ability has an intervening “if” clause, it checks whether the clause’s condition is true. If it isn’t, the ability is removed from the stack and does nothing. Otherwise, it continues to resolve. See rule 603.4.



608.2b If the spell or ability specifies targets, it checks whether the targets are still legal. A target that’s no longer in the zone it was in when it was targeted is illegal. Other changes to the game state may cause a target to no longer be legal; for example, its characteristics may have changed or an effect may have changed the text of the spell. If the source of an ability has left the zone it was in, its last known information is used during this process. If all its targets, for every instance of the word “target,” are now illegal, the spell or ability doesn’t resolve. It’s removed from the stack and, if it’s a spell, put into its owner’s graveyard. Otherwise, the spell or ability will resolve normally. Illegal targets, if any, won’t be affected by parts of a resolving spell’s effect for which they’re illegal. Other parts of the effect for which those targets are not illegal may still affect them. If the spell or ability creates any continuous effects that affect game rules (see rule 613.11), those effects don’t apply to illegal targets. If part of the effect requires information about an illegal target, it fails to determine any such information. Any part of the effect that requires that information won’t happen.

Example: Sorin’s Thirst is a black instant that reads, “Sorin’s Thirst deals 2 damage to target creature and you gain 2 life.” If the creature isn’t a legal target during the resolution of Sorin’s Thirst (say, if the creature has gained protection from black or left the battlefield), then Sorin’s Thirst doesn’t resolve. Its controller doesn’t gain any life.

Example: Plague Spores reads, “Destroy target nonblack creature and target land. They can’t be regenerated.” Suppose the same creature land is chosen both as the nonblack creature and as the land, and the color of the creature land is changed to black before Plague Spores resolves. Plague Spores still resolves because the black creature land is still a legal target for the “target land” part of the spell. The “destroy target nonblack creature” part of the spell won’t affect that permanent, but the “destroy target land” part of the spell will still destroy it. It can’t be regenerated.



608.2c The controller of the spell or ability follows its instructions in the order written. However, replacement effects may modify these actions. In some cases, later text on the card may modify the meaning of earlier text (for example, “Destroy target creature. It can’t be regenerated” or “Counter target spell. If that spell is countered this way, put it on top of its owner’s library instead of into its owner’s graveyard.”) Don’t just apply effects step by step without thinking in these cases—read the whole text and apply the rules of English to the text.



608.2d If an effect of a spell or ability offers any choices other than choices already made as part of casting the spell, activating the ability, or otherwise putting the spell or ability on the stack, the player announces these while applying the effect. The player can’t choose an option that’s illegal or impossible, with the exception that having a library with no cards in it doesn’t make drawing a card an impossible action (see rule 121.3). If an effect divides or distributes something, such as damage or counters, as a player chooses among any number of untargeted players and/or objects, the player chooses the amount and division such that each chosen player or object receives at least one of whatever is being divided. (Note that if an effect divides or distributes something, such as damage or counters, as a player chooses among some number of target objects and/or players, the amount and division were determined as the spell or ability was put onto the stack rather than at this time; see rule 601.2d.)

Example: A spell’s instruction reads, “You may sacrifice a creature. If you don’t, you lose 4 life.” A player who controls no creatures can’t choose the sacrifice option.



608.2e Some spells and abilities have multiple steps or actions, denoted by separate sentences or clauses, that involve multiple players. In these cases, the choices for the first action are made in APNAP order, and then the first action is processed simultaneously. Then the choices for the second action are made in APNAP order, and then that action is processed simultaneously, and so on. See rule 101.4.



608.2f Some spells and abilities include actions taken on multiple players and/or objects. In most cases, each such action is processed simultaneously. If the action can’t be processed simultaneously, it’s instead processed considering each affected player or object individually. APNAP order is used to make the primary determination of the order of those actions. Secondarily, if the action is to be taken on both a player and an object they control or on multiple objects controlled by the same player, the player who controls the resolving spell or ability chooses the relative order of those actions.

Example: Blatant Thievery says “For each opponent, gain control of target permanent that player controls.” As Blatant Thievery resolves, its controller gains control of all permanents chosen as targets simultaneously.

Example: Soulfire Eruption says, in part, “Choose any number of target creatures, planeswalkers, and/or players. For each of them, exile the top card of your library, then Soulfire Eruption deals damage equal to that card’s mana value to that permanent or player.” A player casts Soulfire Eruption targeting an opponent and a creature that opponent controls. As Soulfire Eruption resolves, the player can’t exile the top card of their library multiple times at the same time, so they first choose which target they are considering, then they exile the top card of their library, and finally Soulfire Eruption deals damage to that target. They then repeat this process for the remaining target. 



608.2g If an effect gives a player the option to pay mana, they may activate mana abilities before taking that action. If an effect specifically instructs or allows a player to cast a spell during resolution, they do so by following the steps in rules 601.2a–i, except no player receives priority after it’s cast. That spell becomes the topmost object on the stack, and the currently resolving spell or ability continues to resolve, which may include casting other spells this way. No other spells can normally be cast and no other abilities can normally be activated during resolution.



608.2h If an effect requires information from the game (such as the number of creatures on the battlefield), the answer is determined only once, when the effect is applied. If the effect requires information from a specific object, including the source of the ability itself, the effect uses the current information of that object if it’s in the public zone it was expected to be in; if it’s no longer in that zone, or if the effect has moved it from a public zone to a hidden zone, the effect uses the object’s last known information. See rule 113.7a. If an ability states that an object does something, it’s the object as it exists—or as it most recently existed—that does it, not the ability.



608.2i Some effects look back in time and require information about previous game states and actions rather than considering the current game state. If such an effect requires information from the game about an object or group of objects, and that effect is not taking any actions on those objects, they don’t need to be currently in the zone they were in at the time of that previous game state or action, nor do they need to currently meet the criteria described in the action, as long as they did so at the specified time. This is an exception to 608.2h.

Example: A player attacks with Bear Cub. Later in the turn, an effect causes Bear Cub to become a noncreature permanent. The same player then casts Search Party Captain, a spell that says in part “This spell costs {1} less to cast for each creature you attacked with this turn.” That spell costs {1} less because the player attacked with a creature, even though the Bear Cub they attacked with is no longer a creature.



608.2j If an effect refers to certain characteristics, it checks only for the value of the specified characteristics, regardless of any related ones an object may also have.

Example: An effect that reads “Destroy all black creatures” destroys a white-and-black creature, but one that reads “Destroy all nonblack creatures” doesn’t.



608.2k If an ability’s effect refers to a specific untargeted object that has been previously referred to by that ability’s cost or trigger condition, it still affects that object even if the object has changed characteristics.

Example: Wall of Tears says “Whenever this creature blocks a creature, return that creature to its owner’s hand at end of combat.” If Wall of Tears blocks a creature, then that creature ceases to be a creature before the triggered ability resolves, the permanent will still be returned to its owner’s hand.



608.2m If an instant spell, sorcery spell, or ability that can legally resolve leaves the stack once it starts to resolve, it will continue to resolve fully.



608.2n As the final part of an instant or sorcery spell’s resolution, the spell is put into its owner’s graveyard. As the final part of an ability’s resolution, the ability is removed from the stack and ceases to exist.



608.2p Once all possible steps described in 608.2c–n are completed, any abilities that trigger when that spell or ability resolves trigger.



608.3. If the object that’s resolving is a permanent spell, its resolution may involve several steps. The instructions in rules 608.3a and b are always performed first. Then one of the steps in rule 608.3c–e is performed, if appropriate.



608.3a If the object that’s resolving has no targets, it becomes a permanent and enters the battlefield under the control of the spell’s controller.



608.3b If the object that’s resolving has a target, it checks whether the target is still legal, as described in 608.2b. If a spell with an illegal target is a bestowed Aura spell (see rule 702.103e) or a mutating creature spell (see rule 702.140b), it becomes a creature spell and will resolve as described in rule 608.3a. Otherwise, the spell doesn’t resolve. It is removed from the stack and put into its owner’s graveyard.



608.3c If the object that’s resolving is an Aura spell, it becomes a permanent and is put onto the battlefield under the control of the spell’s controller attached to the player or object it was targeting.



608.3d If the object that’s resolving is a mutating creature spell, the object representing that spell merges with the permanent it is targeting (see rule 728, “Merging with Permanents”).



608.3e If a permanent spell resolves but its controller can’t put it onto the battlefield, that player puts it into its owner’s graveyard.

Example: Worms of the Earth has the ability “Lands can’t enter the battlefield.” Clone says “You may have this creature enter as a copy of any creature on the battlefield.” If a player casts Clone and chooses to copy Dryad Arbor (a land creature) while Worms of the Earth is on the battlefield, Clone can’t enter the battlefield from the stack. It’s put into its owner’s graveyard.



608.3f If the object that’s resolving is a copy of a permanent spell, it will become a token permanent as it is put onto the battlefield in any of the steps above. A token put onto the battlefield this way is no longer a copy of a spell and is not “created” for the purposes of any rules or effects that refer to creating a token.



608.3g If the object that’s resolving has a static ability that functions on the stack and creates a delayed triggered ability, that delayed triggered ability is created as that permanent is put onto the battlefield in any of the steps above. (See rules 702.109, “Dash,” and rule 702.152, “Blitz.”)


