using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class Species {

        public int NatDex;

        // Name is the species name, e.g. "Venusaur", "Wo-Chien".
        // Forms is a string array of "form qualifiers". For example, Mega Delta Venusaur in Smogon's format is Venusaur-Delta-Mega, so forms would be ["Delta", "Mega"].
        // The reason this has to be a string array is that some Pokemon have hyphens in their names e.g. Ho-Oh, Kommo-o, Wo-Chien.
        // None of these mons have other forms officially, but this means there needs to be support for distinguishing names from form qualifiers.
        public string Name;
        public string Forms;
        public bool IsDefaultForm;

        public PokeStatDict BaseStats;
        public Typing Typing;
        public Ability Ability1;
        public Ability Ability2;
        public Ability HiddenAbility;

        public LevelCurves LevelCurve;
        public int ExpYield;
        public PokeStatDict EVYield;

        public Dictionary<int,int[]> LevelupLearnset; // Maps 

        public string Category;

        public bool IsGenderless = false;
        public float GenderRatio = 0.5f; // percentage male
        public Breeding.EggGroup[] EggGroups;
        public int EggCycles;

        public int CatchRate;

        public int BaseFriendship;

        public BodyShapes BodyShape;
        //public Footprints Footprint;
        public float Height; // meters
        public float Weight; // kilograms

        public bool HasGenderDifferences { get { return false; } }

        // Returns the 4 moves a Pokemon of this species would have if it learned all of its new moves at every level.
        // Used for generating wild Pokemon.
        public Move[] AutoMovesAtLevel(int level) {
            List<Move> moves = new List<Move>();
            int count = 0;
            while (count < 4 && level > 0) {
                foreach (Move move in movesLearnedAtLevel(level)) {
                    moves.Add(move);
                    count++;
                }
                level--;
            }
            if (moves.Count < 4) { // pad the list if it has fewer than 4 moves
                int limit = 4 - moves.Count;
                for (int i = 0; i < limit; i++) {
                    moves.Add(null);
                }
            }
            return new Move[4] { moves[0], moves[1], moves[2], moves[3] };
        }

        private Move[] movesLearnedAtLevel(int level) {
            if (LevelupLearnset.ContainsKey(level)) {
                ArrayList ret = new ArrayList();
                foreach (int moveID in LevelupLearnset[level]) {
                    ret.Add(Move.GetByID(moveID));
                }
                return (Move[])ret.ToArray();
            } else {
                return new Move[0];
            }
        }

    }
}