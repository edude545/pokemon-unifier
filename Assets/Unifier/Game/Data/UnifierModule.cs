using System.Collections.Generic;
using UnityEngine;
using System.IO;
using Assets.Unifier.Engine;
using System;
using System.Linq;

namespace Assets.Unifier.Game.Editor {

    [CreateAssetMenu(fileName = "Game Data Importer", menuName = "Unifier/Generic Module")]
    public class UnifierModule : ScriptableObject {

        public string ModuleName;
        public string ModulePath; // ex. Assets/Modules/Insurgence

        public void OnValidate() {
            ModulePath = "Modules/" + ModuleName;
        }

        //public string BundleName;
        //private static HashSet<char> forbiddenCharacters = new HashSet<char>() { '\\', '/', ':', '*', '?', '\"', '<', '>', '|' };

        public TextAsset SpeciesData;
        public TextAsset MovesData;

        public Dictionary<string, Species> Species;
        public Dictionary<string, Move> Moves;

        public void GenerateAssets() {
            if (SpeciesData != null) GenerateSpecies();
            if (MovesData != null) GenerateMoves();
        }

        public void GenerateSpecies() {
            Species = new Dictionary<string, Species>();
            //string speciesPath = tryMakeFolder("Species");
            readCSV(SpeciesData, generateSpecies, Species);
        }

        public void GenerateMoves() {
            Moves = new Dictionary<string, Move>();
            //string movesPath = tryMakeFolder("Moves");
            readCSV(MovesData, generateMove, Moves);
        }

        private string[] getLines(TextAsset csv) {
            //return File.ReadAllLines(AssetDatabase.GetAssetPath(csv));
            return csv.text.Replace("\r","").Split("\n");
            //throw new NotImplementedException();
        }

        private void readCSV<T>(TextAsset csv, Func<string, Dictionary<string, string>, T> importFunction, Dictionary<string, T> dict) {
            string[] lines = getLines(csv);
            string[] fields = lines[0].Split("\t");
            for (int i = 1; i < lines.Length; i++) {
                Dictionary<string, string> record = buildRecordDict(fields, lines[i].Split("\t"));
                T asset = importFunction.Invoke(ModuleName, record);
                dict[record["name"]] = asset;
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
            s.Typing = new Typing(record["type1"], record["type2"]);
            //s.Ability1 = Ability.Get(record["ability1"]);
            //s.Ability2 = Ability.Get(record["ability2"]);
            //s.HiddenAbility = Ability.Get(record["abilityh"]);
            s.BaseStats = PokeStatDict.FromStrings(new string[6] { record["hp"], record["attack"], record["defense"], record["special attack"], record["special defense"], record["speed"] });
            if (int.TryParse(record["base stat total"], out int bst) && s.BaseStats.Total != bst) {
                throw new Exception("Incorrect BST for " + s.Name + "!");
            }
            s.EggGroups = Breeding.Get(record["group1"], record["group2"]);
            int.TryParse(record["catch_rate"], out s.CatchRate);
            int.TryParse(record["egg_cycles"], out s.EggCycles);
            int.TryParse(record["base_happiness"], out s.BaseFriendship);
            s.Category = record["category"];
            float.TryParse(record["percentage_male"], out s.GenderRatio);
            Enum.TryParse(record["exp_group"], out s.LevelCurve);
            float.TryParse(record["height_m"], out s.Height);
            float.TryParse(record["weight_kg"], out s.Weight);
            int.TryParse(record["natdex"], out s.NatDex);
            //int.TryParse(record["generation"], out s.Generation);
            //Subgeneration = record["subgeneration"];
            s.LevelupLearnset = new Dictionary<int, int[]>();
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
