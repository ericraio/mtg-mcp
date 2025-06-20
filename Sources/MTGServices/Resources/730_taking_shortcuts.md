# 730. Taking Shortcuts

*Chapter: Additional Rules*

---

730. Taking Shortcuts



730.1. When playing a game, players typically make use of mutually understood shortcuts rather than explicitly identifying each game choice (either taking an action or passing priority) a player makes.



730.1a The rules for taking shortcuts are largely informal. As long as each player in the game understands the intent of each other player, any shortcut system they use is acceptable.



730.1b Occasionally the game gets into a state in which a set of actions could be repeated indefinitely (thus creating a “loop”). In that case, the shortcut rules can be used to determine how many times those actions are repeated without having to actually perform them, and how the loop is broken.



730.1c Tournaments use a modified version of the rules governing shortcuts and loops. These rules are covered in the Magic: The Gathering Tournament Rules (found at WPN.Wizards.com/en/resources/rules-documents). Whenever the Tournament Rules contradict these rules during a tournament, the Tournament Rules take precedence.



730.2. Taking a shortcut follows the following procedure.



730.2a At any point in the game, the player with priority may suggest a shortcut by describing a sequence of game choices, for all players, that may be legally taken based on the current game state and the predictable results of the sequence of choices. This sequence may be a non-repetitive series of choices, a loop that repeats a specified number of times, multiple loops, or nested loops, and may even cross multiple turns. It can’t include conditional actions, where the outcome of a game event determines the next action a player takes. The ending point of this sequence must be a place where a player has priority, though it need not be the player proposing the shortcut.

Example: A player controls a creature enchanted by Presence of Gond, which grants the creature the ability “{T}: Create a 1/1 green Elf Warrior creature token,” and another player controls Intruder Alarm, which reads, in part, “Whenever a creature enters, untap all creatures.” When the player has priority, they may suggest “I’ll create a million tokens,” indicating the sequence of activating the creature’s ability, all players passing priority, letting the creature’s ability resolve and create a token (which causes Intruder Alarm’s ability to trigger), Intruder Alarm’s controller putting that triggered ability on the stack, all players passing priority, Intruder Alarm’s triggered ability resolving, all players passing priority until the player proposing the shortcut has priority, and repeating that sequence 999,999 more times, ending just after the last token-creating ability resolves.



730.2b Each other player, in turn order starting after the player who suggested the shortcut, may either accept the proposed sequence, or shorten it by naming a place where they will make a game choice that’s different than what’s been proposed. (The player doesn’t need to specify at this time what the new choice will be.) This place becomes the new ending point of the proposed sequence.

Example: The active player draws a card during her draw step, then says, “Go.” The nonactive player is holding Into the Fray (an instant that says “Target creature attacks this turn if able”) and says, “I’d like to cast a spell during your beginning of combat step.” The current proposed shortcut is that all players pass priority at all opportunities during the turn until the nonactive player has priority during the beginning of combat step.



730.2c Once the last player has either accepted or shortened the shortcut proposal, the shortcut is taken. The game advances to the last proposed ending point, with all game choices contained in the shortcut proposal having been taken. If the shortcut was shortened from the original proposal, the player who now has priority must make a different game choice than what was originally proposed for that player.



730.3. Sometimes a loop can be fragmented, meaning that each player involved in the loop performs an independent action that results in the same game state being reached multiple times. If that happens, the active player (or, if the active player is not involved in the loop, the first player in turn order who is involved) must then make a different game choice so the loop does not continue.

Example: In a two-player game, the active player controls a creature with the ability “{0}: This creature gains flying,” the nonactive player controls a permanent with the ability “{0}: Target creature loses flying,” and nothing in the game cares how many times an ability has been activated. Say the active player activates his creature’s ability, it resolves, then the nonactive player activates her permanent’s ability targeting that creature, and it resolves. This returns the game to a game state it was at before. The active player must make a different game choice (in other words, anything other than activating that creature’s ability again). The creature doesn’t have flying. Note that the nonactive player could have prevented the fragmented loop simply by not activating her permanent’s ability, in which case the creature would have had flying. The nonactive player always has the final choice and is therefore able to determine whether the creature has flying.



730.4. If a loop contains only mandatory actions, the game is a draw. (See rules 104.4b and 104.4f.)



730.5. No player can be forced to perform an action that would end a loop other than actions called for by objects involved in the loop.

Example: A player controls Seal of Cleansing, an enchantment that reads, “Sacrifice Seal of Cleansing: Destroy target artifact or enchantment.” A mandatory loop that involves an artifact begins. The player is not forced to sacrifice Seal of Cleansing to destroy the artifact and end the loop.



730.6. If a loop contains an effect that says “[A] unless [B],” where [A] and [B] are each actions, no player can be forced to perform [B] to break the loop. If no player chooses to perform [B], the loop will continue as though [A] were mandatory.


