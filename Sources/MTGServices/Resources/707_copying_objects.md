# 707. Copying Objects

*Chapter: Additional Rules*

---

707. Copying Objects



707.1. Some objects become or turn another object into a “copy” of a spell, permanent, or card. Some effects create a token that’s a copy of another object. (Certain older cards were printed with the phrase “search for a copy.” This section doesn’t cover those cards, which have received new text in the Oracle card reference.)



707.2. When copying an object, the copy acquires the copiable values of the original object’s characteristics and, for an object on the stack, choices made when casting or activating it (mode, targets, the value of X, whether it was kicked, how it will affect multiple targets, and so on). The copiable values are the values derived from the text printed on the object (that text being name, mana cost, color indicator, card type, subtype, supertype, rules text, power, toughness, and/or loyalty), as modified by other copy effects, by its face-down status, and by “as . . . enters” and “as . . . is turned face up” abilities that set power and toughness (and may also set additional characteristics). Other effects (including type-changing and text-changing effects), status, counters, and stickers are not copied.

Example: Chimeric Staff is an artifact that reads, “{X}: This artifact becomes an X/X Construct artifact creature until end of turn.” Clone is a creature that reads, “You may have this creature enter as a copy of any creature on the battlefield.” After a Staff has become a 5/5 Construct artifact creature, a Clone enters the battlefield as a copy of it. The Clone is an artifact, not a 5/5 Construct artifact creature. (The copy has the Staff’s ability, however, and will become a creature if that ability is activated.)

Example: Clone enters the battlefield as a copy of a face-down Grinning Demon (a creature with morph {2}{B}{B}). The Clone is a colorless 2/2 creature with no name, no types, no abilities, and no mana cost. It will still be face up. Its controller can’t pay {2}{B}{B} to turn it face up.



707.2a A copy acquires the color of the object it’s copying because that value is derived from its mana cost or color indicator. A copy acquires the abilities of the object it’s copying because those values are derived from its rules text. A copy doesn’t wind up with two values of each ability (that is, it doesn’t copy the object’s abilities and its rules text, then have that rules text define a new set of abilities).



707.2b Once an object has been copied, changing the copiable values of the original object won’t cause the copy to change.



707.2c If a static ability generates a continuous effect that’s a copy effect, the copiable values that effect grants are determined only at the time that effect first starts to apply.



707.3. The copy’s copiable values become the copied information, as modified by the copy’s status (see rule 110.5). Objects that copy the object will use the new copiable values.

Example: Vesuvan Doppelganger reads, “You may have this creature enter as a copy of any creature on the battlefield, except it doesn’t copy that creature’s color and it has ‘At the beginning of your upkeep, you may have this creature become a copy of target creature, except it doesn’t copy that creature’s color and it has this ability.’” A Vesuvan Doppelganger enters the battlefield as a copy of Runeclaw Bear (a 2/2 green Bear creature with no abilities). Then a Clone enters the battlefield as a copy of the Doppelganger. The Clone is a 2/2 blue Bear named Runeclaw Bear that has the Doppelganger’s upkeep-triggered ability.

Example: Tomoya the Revealer (a flipped flip card) becomes a copy of Nezumi Shortfang (an unflipped flip card). Tomoya’s characteristics become the characteristics of Stabwhisker the Odious, which is the flipped version of Nezumi Shortfang.

Example: A face-down Grinning Demon (a creature with morph) becomes a copy of a face-up Branchsnap Lorian (a 4/1 green creature with trample and morph {G}). The Demon’s characteristics become the characteristics of Branchsnap Lorian. However, since the creature is face down, it remains a 2/2 colorless creature with no name, types, or abilities, and no mana cost. It can be turned face up for {G}. If it’s turned face up, it will have the characteristics of Branchsnap Lorian.

Example: A face-down Grinning Demon (a creature with morph) becomes a copy of Wandering Ones (a 1/1 blue Spirit creature that doesn’t have morph). It will be a face-down Wandering Ones. It remains a 2/2 colorless creature with no name, types, or abilities, and no mana cost. Its controller can’t turn it face up as a special action. If an effect turns it face up, it will have the characteristics of Wandering Ones.



707.4. Some effects cause a permanent that’s copying a permanent to copy a different object while remaining on the battlefield. The change doesn’t cause enters-the-battlefield or leaves-the-battlefield abilities to trigger. This also doesn’t change any noncopy effects presently affecting the permanent.

Example: Unstable Shapeshifter reads, “Whenever another creature enters, this creature becomes a copy of that creature, except it has this ability.” It’s affected by Giant Growth, which reads “Target creature gets +3/+3 until end of turn.” If a creature enters the battlefield later this turn, Unstable Shapeshifter will become a copy of that creature, but it will still get +3/+3 from the Giant Growth.



707.5. An object that enters the battlefield “as a copy” or “that’s a copy” of another object becomes a copy as it enters the battlefield. It doesn’t enter the battlefield, and then become a copy of that permanent. If the text that’s being copied includes any abilities that replace the enters-the-battlefield event (such as “enters with” or “as [this] enters” abilities), those abilities will take effect. Also, any enters-the-battlefield triggered abilities of the copy will have a chance to trigger.

Example: Skyshroud Behemoth reads, “Fading 2 (This creature enters with two fade counters on it. At the beginning of your upkeep, remove a fade counter from it. If you can’t, sacrifice it.)” and “This creature enters tapped.” A Clone that enters the battlefield as a copy of a Skyshroud Behemoth will also enter the battlefield tapped with two fade counters on it.

Example: Wall of Omens reads, “When this creature enters, draw a card.” A Clone enters the battlefield as a copy of Wall of Omens. The Clone has the Wall’s enters-the-battlefield triggered ability, so the Clone’s controller draws a card.



707.6. When copying a permanent, any choices that have been made for that permanent aren’t copied. Instead, if an object enters the battlefield as a copy of another permanent, the object’s controller will get to make any “as [this] enters the battlefield” choices for it.

Example: A Clone enters the battlefield as a copy of Adaptive Automaton. Adaptive Automaton reads, in part, “As this creature enters, choose a creature type.” The Clone won’t copy the creature type choice of the Automaton; rather, the controller of the Clone will get to make a new choice.



707.7. If a pair of linked abilities are copied, those abilities will be similarly linked to one another on the object that copied them. One ability refers only to actions that were taken or objects that were affected by the other. They can’t be linked to any other ability, regardless of what other abilities the copy may currently have or may have had in the past. See rule 607, “Linked Abilities.”



707.8. When copying a melded permanent or other double-faced permanent, use the copiable values of the face that’s currently up to determine the characteristics of the copy. See rule 712, “Double-Faced Cards.”



707.8a If an effect creates a token that is a copy of a transforming permanent or a transforming double-faced card not on the battlefield, the resulting token is a transforming token that has both a front face and a back face. The characteristics of each face are determined by the copiable values of the same face of the permanent it is a copy of, as modified by any other copy effects that apply to that permanent. If the token is a copy of a transforming permanent with its back face up, the token enters the battlefield with its back face up. This rule does not apply to tokens that are created with their own set of characteristics and enter the battlefield as a copy of a transforming permanent due to a replacement effect.

Example: Afflicted Deserter is the front face of a transforming double-faced card, and the name of its back face is Werewolf Ransacker. If an effect creates a token that is a copy of that transforming permanent, the token also has the same two faces and can transform. It enters the battlefield with the same face up as the permanent that it is a copy of.

Example: Clone is not a transforming double-faced card, so a token that is created as a copy of a Clone is not a transforming token, even if it enters the battlefield as a copy of a transforming permanent due to Clone’s replacement effect.



707.9. Copy effects may include modifications or exceptions to the copying process.



707.9a Some copy effects cause the copy to gain an ability as part of the copying process. This ability becomes part of the copiable values for the copy, along with any other abilities that were copied.

Example: Quirion Elves enters the battlefield and an Unstable Shapeshifter copies it. The copiable values of the Shapeshifter now match those of the Elves, except that the Shapeshifter also has the ability “Whenever another creature enters, this creature becomes a copy of that creature, except it has this ability.” Then a Clone enters the battlefield as a copy of the Unstable Shapeshifter. The Clone copies the new copiable values of the Shapeshifter, including the ability that the Shapeshifter gave itself when it copied the Elves.



707.9b Some copy effects modify a characteristic as part of the copying process. The final set of values for that characteristic becomes part of the copiable values of the copy.

Example: Copy Artifact is an enchantment that reads, “You may have this enchantment enter as a copy of any artifact on the battlefield, except it’s an enchantment in addition to its other types.” It enters the battlefield as a copy of Juggernaut. The copiable values of the Copy Artifact now match those of Juggernaut with one modification: its types are now artifact, creature, and enchantment.



707.9c Some copy effects specifically state that they don’t copy certain characteristics and the affected objects instead retain their original values. Copy effects may also simply state that certain characteristics are not copied.



707.9d When applying a copy effect that doesn’t copy a certain characteristic, retains one or more original values for a certain characteristic, or provides a specific set of values for a certain characteristic, any characteristic-defining ability (see rule 604.3) of the object being copied that defines that characteristic is not copied. If that characteristic is color, any color indicator (see rule 204) of that object is also not copied. This rule does not apply to copy effects with exceptions that state the object is a certain card type, supertype, and/or subtype “in addition to its other types.” In those cases, any characteristic-defining ability that defines card type, supertype, and/or subtype is copied.

Example: Quicksilver Gargantuan is a creature that reads, “You may have this creature enter as a copy of any creature on the battlefield, except it’s 7/7.” Quicksilver Gargantuan enters the battlefield as a copy of Tarmogoyf, which has a characteristic-defining ability that defines its power and toughness. Quicksilver Gargantuan does not have that ability. It will be 7/7.

Example: Glasspool Mimic is a creature that reads “You may have this creature enter as a copy of a creature you control, except it’s a Shapeshifter Rogue in addition to its other types.” Glasspool Mimic enters as a copy of a creature with changeling. Glasspool Mimic will have changeling and will have all creature types.



707.9e Some replacement effects that generate copy effects include an exception that’s an additional effect rather than a modification of the affected object’s characteristics. If another copy effect is applied to that object after applying the copy effect with that exception, the exception’s effect doesn’t happen.

Example: Altered Ego reads, “You may have this creature enter as a copy of any creature on the battlefield, except it enters with X additional +1/+1 counters on it.” You choose for it to enter the battlefield as a copy of Clone, which reads “You may have this creature enter as a copy of any creature on the battlefield,” for which no creature was chosen as it entered the battlefield. If you then choose a creature to copy as you apply the replacement effect Altered Ego gains by copying Clone, Altered Ego’s replacement effect won’t cause it to enter the battlefield with any +1/+1 counters on it.



707.9f Some exceptions to the copying process apply only if the copy is or has certain characteristics. To determine whether such an exception applies, consider what the resulting permanent’s characteristics would be if the copy effect were applied without that exception, taking into account any other exceptions that effect includes.

Example: Moritte of the Frost says, in part, “You may have Moritte enter as a copy of a permanent you control, except it’s legendary and snow in addition to its other types and, if it’s a creature, it enters with two additional +1/+1 counters on it and it has changeling.” Moritte of the Frost copies a land that has become a creature until end of turn. It would enter as a noncreature permanent, so it won’t enter with two additional +1+1 counters on it and it won’t have changeling, even if it becomes a creature later in the turn.



707.9g Some replacement effects that generate copy effects are linked to triggered abilities written in the same paragraph. (See rule 603.11.) If another copy effect is applied to that object after applying the copy effect with the linked triggered ability, the ability doesn’t trigger.



707.10. To copy a spell, activated ability, or triggered ability means to put a copy of it onto the stack; a copy of a spell isn’t cast and a copy of an activated ability isn’t activated. A copy of a spell or ability copies both the characteristics of the spell or ability and all decisions made for it, including modes, targets, the value of X, and additional or alternative costs. (See rule 601, “Casting Spells.”) Choices that are normally made on resolution are not copied. If an effect of the copy refers to objects used to pay its costs, it uses the objects used to pay the costs of the original spell or ability. A copy of a spell is owned by the player under whose control it was put on the stack. A copy of a spell or ability is controlled by the player under whose control it was put on the stack. A copy of a spell is itself a spell, even though it has no spell card associated with it. A copy of an ability is itself an ability.

Example: A player casts Fork, targeting an Emerald Charm. Fork reads, “Copy target instant or sorcery spell, except that the copy is red. You may choose new targets for the copy.” Emerald Charm is a modal green instant. When the Fork resolves, it puts a copy of the Emerald Charm on the stack except the copy is red, not green. The copy has the same mode that was chosen for the original Emerald Charm. It does not necessarily have the same target, but only because Fork allows choosing of new targets.

Example: Fling is an instant that reads, “As an additional cost to cast this spell, sacrifice a creature” and “Fling deals damage equal to the sacrificed creature’s power to any target.” When determining how much damage a copy of Fling deals, it checks the power of the creature sacrificed to pay for the original Fling.

Example: Dawnglow Infusion is a sorcery that reads, “You gain X life if {G} was spent to cast this spell and X life if {W} was spent to cast it.” Because mana isn’t an object, a copy of Dawnglow Infusion won’t cause you to gain any life, no matter what mana was spent to cast the original spell.



707.10a If a copy of a spell is in a zone other than the stack, it ceases to exist. If a copy of a card is in any zone other than the stack or the battlefield, it ceases to exist. These are state-based actions. See rule 704.



707.10b A copy of an ability has the same source as the original ability. If the ability refers to its source by name, the copy refers to that same object and not to any other object with the same name. The copy is considered to be the same ability by effects that count how many times that ability has resolved during the turn.



707.10c Some effects copy a spell or ability and state that its controller may choose new targets for the copy. The player may leave any number of the targets unchanged, even if those targets would be illegal. If the player chooses to change some or all of the targets, the new targets must be legal. Once the player has decided what the copy’s targets will be, the copy is put onto the stack with those targets.



707.10d Some effects copy a spell or ability for each player or object it “could target.” The copies are put onto the stack with those targets in the order of their controller’s choice. If the spell or ability has more than one target, each of its targets must be the same player or object. If that player or object isn’t a legal target for each instance of the word “target,” a copy isn’t created for that player or object.



707.10e Some effects copy a spell or ability and specify a new target for the copy. If the spell or ability has more than one target, each of the copy’s targets must be that player or object. If that player or object isn’t a legal target for each instance of the word “target,” the copy isn’t created. In the case where a replacement effect causes the copy to target more than one object, the copy’s controller chooses one of them to be the new target. The chosen target must be a legal target for that spell or ability.

Example: Frontline Heroism is an enchantment with the ability “Whenever you cast a spell that targets only a single creature you control, create a 1/1 red Soldier creature token with haste, then copy that spell. The copy targets that token.” Anointed Procession is an enchantment with the ability “If an effect would create one or more tokens under your control, it creates twice that many of those tokens instead.” If you control both and cast Moment of Triumph targeting a creature you control, Frontline Heroism’s ability triggers. As that ability resolves, you create two 1/1 red Soldier creature tokens with haste, then copy Moment of Triumph and the copy targets one of those tokens of your choice. The copy doesn’t target both the tokens.



707.10f Some effects copy a permanent spell. As that copy resolves, it ceases being a copy of a spell and becomes a token permanent. (See rule 608.3f.)



707.10g If an effect creates a copy of a transforming permanent spell, the copy is also a transforming permanent spell that has both a front face and a back face. The characteristics of its front and back face are determined by the copiable values of the same face of the spell it is a copy of, as modified by any other copy effects. If the spell it is a copy of has its back face up, the copy is created with its back face up. The token that’s put onto the battlefield as that spell resolves is a transforming token.



707.11. If an effect refers to a permanent by name, the effect still tracks that permanent even if it changes names or becomes a copy of something else.

Example: An Unstable Shapeshifter copies an Olivia Voldaren. Olivia Voldaren reads, “{1}{R}: Olivia Voldaren deals 1 damage to another target creature. That creature becomes a Vampire in addition to its other types. Put a +1/+1 counter on Olivia Voldaren.” If this ability of the Shapeshifter is activated, the Shapeshifter will deal 1 damage and you will put a +1/+1 counter on it, even if it’s no longer a copy of Olivia Voldaren at that time.



707.12. An effect that instructs a player to cast a copy of an object (and not just copy a spell) follows the rules for casting spells, except that the copy is created in the same zone the object is in and then cast while another spell or ability is resolving. Casting a copy of an object follows steps 601.2a–h of rule 601, “Casting Spells,” and then the copy becomes cast. Once cast, the copy is a spell on the stack, and just like any other spell it can resolve or be countered.



707.13. One card (Garth One-Eye) instructs a player to create a copy of a card defined by name rather than by indicating an object to be copied. To do so, the player uses the Oracle card reference to determine the characteristics of the copy and creates the copy outside of the game.



707.14. One card (Magar of the Magic Strings) instructs a player to note the name of a particular card in a graveyard and create a copy of the card with the noted name. To do so, use the characteristics of that card as it last existed in the graveyard to determine the copiable values of the copy. (See rule 608.2h.)


