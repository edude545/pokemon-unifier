using System.Collections.Generic;
using UnityEngine;
using System.IO;
using Assets.Unifier.Engine;
using System;
using Newtonsoft.Json;
using System.Linq;
using Unity.Mathematics;

namespace Assets.Unifier.Game.Editor {

    [CreateAssetMenu(fileName = "Game Data Importer", menuName = "Unifier/Generic Module")]
    public class UnifierModule : ScriptableObject {

        public static Dictionary<string, UnifierModule> Modules;

        public string ModuleName = "New Module";
        public string ModulePath => "Modules/" + ModuleName;

        //public string BundleName;
        //private static HashSet<char> forbiddenCharacters = new HashSet<char>() { '\\', '/', ':', '*', '?', '\"', '<', '>', '|' };

        public TextAsset SpeciesTSV;
        public TextAsset MovesTSV;
        public TextAsset LearnsetsDataJSON;

        private Dictionary<string, Species> species;
        private Dictionary<string, Move> moves;

        public void OnEnable() {
            if (Modules == null) {
                Modules = new Dictionary<string, UnifierModule>();
            }
            List<string> keysToRemove = new List<string>();
            foreach (var kvp in Modules) {
                if (kvp.Value.ModuleName != kvp.Key) {
                    keysToRemove.Add(kvp.Key);
                }
            }
            foreach (string key in keysToRemove) {
                Modules.Remove(key);
            }
            Modules[ModuleName] = this;
        }

        public Species GetSpecies(string name) {
            return species[name.ToLower()];
        }

        public Move GetMove(string name) {
            return moves[name.ToLower().Replace(" ", "")];
        }

        public bool HasSpecies(string name) {
            return species.ContainsKey(name.ToLower());
        }

        public bool HasMove(string name) {
            return moves.ContainsKey(name.ToLower().Replace(" ", "").Replace("-", ""));
        }

        public Species GetRandomSpecies() {
            Species[] s = species.Values.ToArray();
            //s = s.Where(s => s.Forms.Contains("Mega")).ToArray();
            return s[UnityEngine.Random.Range(0, s.Length)];
        }

        public void GenerateAssets() {
            if (SpeciesTSV != null) { GenerateSpecies(); } else { species = new Dictionary<string, Species>(); }
            if (MovesTSV != null) { GenerateMoves(); } else { moves = new Dictionary<string, Move>(); }
            if (LearnsetsDataJSON != null) { GenerateLearnsets(); }
        }

        public void GenerateSpecies() {
            species = new Dictionary<string, Species>();
            //string speciesPath = tryMakeFolder("Species");
            readCSV(SpeciesTSV, generateSpecies, species);
        }

        public void GenerateMoves() {
            moves = new Dictionary<string, Move>();
            //string movesPath = tryMakeFolder("Moves");
            readCSV(MovesTSV, generateMove, moves);
        }

        public void GenerateLearnsets() {
            var learnsets = JsonConvert.DeserializeObject<Dictionary<string,LearnsetData>>(LearnsetsDataJSON.text);
            foreach (var kvp in learnsets) {
                if (HasSpecies(kvp.Key)) {
                    Species s = GetSpecies(kvp.Key);
                    s.Learnset = kvp.Value;
                    s.Learnset.species = s;
                    if (s.Learnset.parent != null) {
                        s.Learnset.InheritFrom(GetSpecies(s.Learnset.parent).Learnset);
                    }
                    s.BuildMoveset();
                } else {
                    Debug.LogWarning("Couldn't find key " + kvp.Key);
                }
            }
        }

        private string[] getLines(TextAsset tsv) {
            //return File.ReadAllLines(AssetDatabase.GetAssetPath(csv));
            return tsv.text.Replace("\r","").Split("\n");
            //throw new NotImplementedException();
        }

        private void readCSV<T>(TextAsset csv, Func<string, Dictionary<string, string>, T> importFunction, Dictionary<string, T> dict) where T : UnifierRegistryObject {
            string[] lines = getLines(csv);
            string[] fields = lines[0].Split("\t");
            for (int i = 1; i < lines.Length; i++) {
                Dictionary<string, string> record = buildRecordDict(fields, lines[i].Split("\t"));
                T asset = importFunction.Invoke(ModuleName, record);
                dict[asset.Identifier.ToLower()] = asset;
                //AssetDatabase.CreateAsset(asset, path+"/"+ string.Join("_", asset.name.Split(Path.GetInvalidFileNameChars())) + ".asset");
            }
        }

        private Dictionary<string, string> buildRecordDict(string[] fields, string[] line) {
            Dictionary<string, string> record = new Dictionary<string, string>();
            for (int fi = 0; fi < line.Length; fi++) {
                record[fields[fi]] = line[fi];
            }
            foreach (string key in fields) {
                if (!record.ContainsKey(key)) {
                    record[key] = "";
                }
            }
            return record;
        }

        /*private string fromShowdownSpeciesName(string name) {
            string[] formNames = { "alola", "galar", "paldea", "totem", "cosplay", "rockstar", "belle", "popstar", "phd", "libre", "original", "hoenn", "sinnoh", "unova", "kalos", "partner", "starter", "world",  };
            foreach (string regionName in regionNames) {
                int index = name.IndexOf(regionName);
                if (index != -1) {
                    name = name.Substring(0, index) + "-" + name.Substring(index);
                }
            }
            string ret = "";
            foreach (string part in name.Split("-")) {
                ret += char.ToUpper(part[0]) + part.Substring(1) + "-";
            }
            ret = ret.Substring(0,ret.Length-1);
            return name;
        }*/

        /*private string tryMakeFolder(string folderName) {
            string ret = path + "/" + folderName;
            if (!AssetDatabase.IsValidFolder(ret)) {
                AssetDatabase.CreateFolder(path, folderName);
            }
            return path + "/" + folderName;
        }*/

        private static Species generateSpecies(string moduleName, Dictionary<string, string> record) {
            Species s = new Species();
            s.SourceModule = moduleName;
            s.IsDefaultForm = record["default_form"] == "y";
            s.Name = record["name"];
            s.Forms = record["form"].Split("`");
            if (s.Forms[0] == "") { s.Forms = new string[0]; }
            s.Typing = new Typing(record["type1"], record["type2"]);
            //s.Ability1 = Ability.Get(record["ability1"]);
            //s.Ability2 = Ability.Get(record["ability2"]);
            //s.HiddenAbility = Ability.Get(record["abilityh"]);
            s.BaseStats = PokeStatDict.FromStrings(new string[6] { record["hp"], record["attack"], record["defense"], record["special attack"], record["special defense"], record["speed"] });
            if (int.TryParse(record["base stat total"], out int bst) && s.BaseStats.Total != bst) {
                throw new Exception("Incorrect BST for " + s.Identifier + "!");
            }

            string eg1 = record.GetValueOrDefault("group1", ""); bool eg1valid = string.IsNullOrWhiteSpace(eg1);
            string eg2 = record.GetValueOrDefault("group2", ""); bool eg2valid = string.IsNullOrWhiteSpace(eg1);
            if (!eg1valid && !eg2valid) { s.EggGroups = new string[0]; }
            else if (eg1valid && !eg2valid) { s.EggGroups = new string[1] { eg1 }; }
            else if (!eg1valid && eg2valid) { s.EggGroups = new string[1] { eg2 }; }
            else if (eg1valid && eg2valid) { s.EggGroups = new string[2] { eg1, eg2 }; }

            int.TryParse(record["catch_rate"], out s.CatchRate);
            int.TryParse(record.GetValueOrDefault("egg_cycles","20"), out s.EggCycles);
            int.TryParse(record.GetValueOrDefault("base_happiness","70"), out s.BaseFriendship);
            s.Category = record.GetValueOrDefault("category","");
            float.TryParse(record["percentage_male"], out s.GenderRatio);
            Enum.TryParse(record["exp_group"], out s.LevelCurve);
            float.TryParse(record["height_m"], out s.Height);
            float.TryParse(record["weight_kg"], out s.Weight);
            int.TryParse(record.GetValueOrDefault("natdex","0"), out s.NatDex);
            //int.TryParse(record["generation"], out s.Generation);
            //Subgeneration = record["subgeneration"];
            return s;
        }

        private static Move generateMove(string moduleName, Dictionary<string, string> record) {
            Move m = new Move();
            m.ModuleName = moduleName;
            m.Name = record["name"];
            Enum.TryParse(record["category"], out m.Category);
            int.TryParse(record["power"], out m.Power);
            int.TryParse(record["accuracy"], out m.Accuracy);
            int.TryParse(record["pp"], out m.BasePP);
            m.Type = PokeType.GetType(record["type"]);
            Enum.TryParse(record["targeting_type"], out m.TargetingType);
            if (m.Category == MoveCategories.Status || m.Category == MoveCategories.MaxMove) {
                m.MakesContact = false;
            } else {
                if (record["makes_contact"] == "y") {
                    m.MakesContact = true;
                } else if (record["makes_contact"] == "n") {
                    m.MakesContact = false;
                } else {
                    throw new InvalidDataException("Unrecognized data \"" + record["makes_contact"] + "\" for move " + record["name"]);
                }
            }
            return m;
        }

    }

}
