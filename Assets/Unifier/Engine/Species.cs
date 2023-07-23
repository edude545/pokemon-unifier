using Assets.Unifier.Game.Editor;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class Species : UnifierRegistryObject {

        public string SourceModule;

        public int NatDex;

        // Name is the species name, e.g. "Venusaur", "Wo-Chien".
        // Forms is a string array of "form qualifiers". For example, Mega Delta Venusaur in Smogon's format is Venusaur-Delta-Mega, so forms would be ["Delta", "Mega"].
        // The reason this has to be a string array is that some Pokemon have hyphens in their names e.g. Ho-Oh, Kommo-o, Wo-Chien.
        // None of these mons have other forms officially, but this means there needs to be support for distinguishing names from form qualifiers.
        public string Name;
        public string[] Forms;
        public string Identifier => ((Forms.Length == 0) ? Name : (Name + "-" + string.Join("-",Forms))).ToLower();
        public bool IsDefaultForm;

        public PokeStatDict BaseStats;
        public Typing Typing;
        public Ability Ability1;
        public Ability Ability2;
        public Ability HiddenAbility;

        public LearnsetData Learnset;

        public LevelCurves LevelCurve;
        public int ExpYield;
        public PokeStatDict EVYield;

        public Dictionary<int,string[]> LevelupLearnset; // Key of 0 indicates a move learnt when evolving into this Pokemon
        public HashSet<string> Movepool; // All moves that may be moved by levelup, TM/HM/TR, tutor and egg moves.

        public string Category;

        public bool IsGenderless = false;
        public float GenderRatio = 0.5f; // percentage male
        public string[] EggGroups;
        public int EggCycles;

        public int CatchRate;

        public int BaseFriendship;

        public BodyShapes BodyShape;
        //public Footprints Footprint;
        public float Height; // meters
        public float Weight; // kilograms

        public bool HasGenderDifferences { get { return false; } }

        public static Species GetByInternalName(string name) {
            foreach (UnifierModule module in UnifierModule.Modules.Values) {
                if (module.HasSpecies(name)) {
                    return module.GetSpecies(name);
                }
            }
            throw new ArgumentOutOfRangeException("No registered module provides a Pokemon with internal name " + name);
        }

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
            if (LevelupLearnset == null) return new Move[0];
            if (LevelupLearnset.ContainsKey(level)) {
                List<Move> ret = new List<Move>();
                foreach (string id in LevelupLearnset[level]) {
                    ret.Add(Move.GetByInternalName(id));
                }
                return ret.ToArray();
            } else {
                return new Move[0];
            }
        }

        public void BuildMoveset() {
            if (Learnset.learnset == null) {
                //Debug.LogWarning("Species " + Identifier + " has no learnset");
                return;
            }
            var sourcesToMoves = new Dictionary<MoveSource, List<string>>();
            foreach (var moveToSources in Learnset.learnset) {
                foreach (string str in moveToSources.Value) {
                    MoveSource source = new MoveSource(str);
                    List<string> list = sourcesToMoves.GetValueOrDefault(source, new List<string>());
                    list.Add(moveToSources.Key);
                    sourcesToMoves[source] = list;
                }
            }

            var levelupLearnsetBuild = new Dictionary<int, List<string>>();
            Movepool = new HashSet<string>();

            int latestGeneration = 0;
            foreach (MoveSource key in sourcesToMoves.Keys) {
                latestGeneration = Mathf.Max(latestGeneration, key.Generation);
            }

            foreach (var kvp in sourcesToMoves) {
                if (kvp.Key.Generation != latestGeneration) continue;
                Movepool.UnionWith(kvp.Value);
                if (kvp.Key.SourceType == 'L') {
                    List<string> l = levelupLearnsetBuild.GetValueOrDefault(kvp.Key.Num, new List<string>());
                    foreach (string id in kvp.Value) {
                        if (!l.Contains(id)) {
                            l.Add(id);
                        }
                    }
                    levelupLearnsetBuild[kvp.Key.Num] = l;
                }
            }

            LevelupLearnset = new Dictionary<int, string[]>();
            foreach (var kvp in levelupLearnsetBuild) {
                LevelupLearnset[kvp.Key] = kvp.Value.ToArray();
            }

            /*string output = "";
            foreach (var kvp in LevelupLearnset) {
                output += kvp.Key + ": " + string.Join(", ", kvp.Value) + "\n";
            }
            Debug.Log(output);*/
            //LevelupLearnset = new Dictionary<int, Move[]>();
        }

    }

    struct MoveSource {
        public int Generation;
        public char SourceType;
        public int Num;
        public MoveSource(string str) {
            string gens = "";
            SourceType = ' ';
            string nums = "";
            bool secondHalf = false;
            foreach (char c in str) {
                if (char.IsDigit(c)) {
                    if (secondHalf) {
                        nums += c;
                    } else {
                        gens += c;
                    }
                } else {
                    SourceType = c;
                    secondHalf = true;
                }
            }
            Generation = int.Parse(gens);
            Num = nums.Length == 0 ? 0 : int.Parse(nums);
        }
    }

    public struct LearnsetData {

        public Species species;

        // Maps move names to sources.
        // gL0 - Move learned when evolving into this Pokemon in generation g
        // gLn - Move learned at level n in generation g
        // gM - Move learned by TM/HM/TR in generation g
        // gT - Move learned through move tutor in generation g
        // gE - Possible egg move in generation g
        // gSn - Move available in nth distribution event in generation g
        public Dictionary<string, string[]> learnset;

        public EncounterData[] eventData;
        public EncounterData[] encounters;
        public bool eventOnly;
        public string parent;

        public void InheritFrom(LearnsetData parentData) {
            var newLearnset = new Dictionary<string, string[]>();

            IEnumerable<string> keys;
            if (learnset == null) { keys = parentData.learnset.Keys; }
            else if (parentData.learnset.Keys == null) { keys = learnset.Keys; }
            else { keys = learnset.Keys.Union(parentData.learnset.Keys); }

            foreach (string key in keys) {
                if (learnset == null) {
                    newLearnset[key] = parentData.learnset[key];
                } else if (parentData.learnset == null) {
                    newLearnset[key] = learnset[key];
                } else {
                    newLearnset[key] = learnset.GetValueOrDefault(key, new string[0])
                    .Union(parentData.learnset.GetValueOrDefault(key, new string[0]))
                    .ToArray();
                }
            }
            learnset = newLearnset;

            if (eventData == null) { eventData = parentData.eventData; }
            else if (parentData.eventData != null) { eventData.Union(parentData.eventData).ToArray(); }

            if (encounters == null) { encounters = parentData.encounters; }
            else if (parentData.encounters != null) { eventData.Union(parentData.encounters).ToArray(); }
        }
    }

    public struct EncounterData {

        public int generation;
        public int level;
        public bool shiny;
        public string gender;
        public string nature;
        public Dictionary<string, int> ivs;
        public string[] abilities;
        public bool hidden; // not sure what this does
        public string[] moves;
        public string pokeball;
        public int maxEggMoves;

    }

}