using System;
using UnityEngine;

namespace Assets.Unifier.Engine {

    // A Pokemon object describes an individual Pokemon, as opposed to an entire Species.
    // e.g. this class stores the Pokemon's curent HP, but not the Species' base HP.
    public class Pokemon {

        public string Name { get { return Nickname == null ? Species.Name : Nickname; } }
        public string Nickname { get; private set; }

        public Species Species { get; private set; }

        public int CurrentHP;
        public float HPPercentage {
            get {
                return CurrentHP / (float)Stats.HP.Value;
            }
        }

        private float genderFloat;
        public bool IsMale { get { return genderFloat > Species.GenderRatio; } }
        public bool IsFemale { get { return genderFloat <= Species.GenderRatio; } }

        public bool Shiny { get; private set; }

        public PokeStatDict IVs { get; private set; }
        public PokeStatDict EVs { get; private set; }
        public Nature Nature { get; private set; }
        public PokeStatDict Stats { get; private set; }

        public int AbilitySlot { get; private set; }
        public Ability Ability {
            get {
                switch (AbilitySlot) {
                    case 0: return Species.Ability1;
                    case 1: return Species.Ability2;
                    case 2: return Species.HiddenAbility;
                    default: throw new ArgumentOutOfRangeException("Invalid ability slot " + AbilitySlot);
                }
            }
        }

        public Move[] Moves { get; private set; }
        public int[] PP { get; private set; }
        public int[] MaxPP { get; private set; }

        public int Level { get; private set; }

        public int Friendship { get; private set; } // 0-255
        public bool IsOutsider { get; private set; }

        public Typing Typing {
            get {
                return Species.Typing;
            }
        }

        public bool IsDefaultForm { get { return true; } }

        public Pokemon(Species species, int level) {
            Species = species;
            IVs = PokeStatDict.Randomize(32);
            EVs = PokeStatDict.Zero;
            Nature = Nature.GetRandom();
            Level = level;

            generateStats();

            Moves = Species.AutoMovesAtLevel(Level);

            PP = new int[] { 0, 0, 0, 0 };
            MaxPP = new int[] { 0, 0, 0, 0 };

            Friendship = Species.BaseFriendship;
            IsOutsider = false;
        }

        private void generateStats() {
            Stats = PokeStatDict.Zero;
            foreach (PokeStat stat in Enum.GetValues(typeof(PokeStat))) {
                if (stat == PokeStat.HP) {
                    Stats[stat] = (int) Mathf.Floor((2 * Species.BaseStats[stat] + IVs[stat] + Mathf.Floor(EVs[stat]/4f)) / 100f) + Level + 10;
                } else {
                    Mathf.Floor((Mathf.Floor((2 * Species.BaseStats[stat] + IVs[stat] + Mathf.Floor(EVs[stat] / 4f)) * Level / 100f) + 5) * Nature.GetMult(stat));
                }
            }
        }

        public void LearnMove(Move move, int slot) {
            Moves[slot] = move;
            PP[slot] = move.BasePP;
            MaxPP[slot] = move.BasePP;
        }

        // Try to automatically learn a move by filling an empty move slot. Returns false if this is not possible.
        public bool TryAutoLearnMove(Move move) {
            for (int i = 0; i < 4; i++) {
                if (Moves[i] == null) {
                    Moves[i] = move;
                    return true;
                }
            }
            return false;
        }

        public bool CanEvolveAtThisLevel() {
            throw new NotImplementedException();
        }

    }

}