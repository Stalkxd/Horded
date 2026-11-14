ITEM = {}

ITEM.Category = "Special"
ITEM.Name = "Pheropod"
ITEM.Class = "horde_pheropod"
ITEM.Price = 0
ITEM.Weight = 0
ITEM.Description = [[Only usable by Hatcher subclass!
    Pheropods that can hatch and control alien Antlions.

    LMB: Throw Pod
    Throws a Pheropod at the target, forcing the Antlions to perform range attacks at the target.
    The enemy closest to the pod becomes their focus target for 6 seconds.
    Pods can also heal Antlion for 5% health.

    RMB: Raise Antlion (40 Energy)
    Creates an Antlion that follows you around. Heal Antlion to accelerate evolution.
    HOLD RMB to force Antlions to your location and stop them chasing.
    Press USE (E) on an Antlion to switch its mode:
    - Follow: walks beside you and spits while moving. Two Antlions form a line.
    - Guard: holds its position no matter what.
    - Attacker: hunts enemies on its own with leaps, claws and spit.
    Antlion gains new effects each stage:
    - Stage I:
        - Bug Pulse: Every 5 seconds, generates a pulse that heals players nearby for 5% health.
    - Stage II:
        - Increased health and damage.
        - Increased Aroma Pulse radius and reduce Bug Pulse cooldown.
        - 50% increased Poison damage resistance.
    - Stage III:
        - Increased health, damage and attack speed.
        - Increased Aroma Pulse radius and reduce Bug Pulse cooldown.
        - Immune to Poison damage and Break.
    - Stage IV (requires Metamorphosis):
        - Becomes an Antlion Guard with greatly increased health and damage.
        - Melee tank: shoves enemies near you, knocking them back.
        - Rush: gains speed and damage the longer it runs and plows through
          enemies. Only bosses, elites and larger enemies can stop it.]]
ITEM.Whitelist = { Hatcher = true }
ITEM.AmmoPrice = -1
ITEM.SecondaryAmmoPrice = -1
ITEM.Dmgtype = { HORDE.DMG_SLASH, HORDE.DMG_POISON }
ITEM.StarterClasses = { "Hatcher" }
ITEM.Hidden = true
