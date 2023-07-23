using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Unity.VisualScripting;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class PokeType {

        public static PokeType Normal;
        public static PokeType Fighting;
        public static PokeType Flying;
        public static PokeType Poison;
        public static PokeType Ground;
        public static PokeType Rock;
        public static PokeType Bug;
        public static PokeType Ghost;
        public static PokeType Steel;
        public static PokeType Unknown;
        public static PokeType Fire;
        public static PokeType Water;
        public static PokeType Grass;
        public static PokeType Electric;
        public static PokeType Psychic;
        public static PokeType Ice;
        public static PokeType Dragon;
        public static PokeType Dark;
        public static PokeType Fairy;

        public static PokeType[] Types;

        static PokeType() {
            Normal = new PokeType("Normal", 0);
            Fighting = new PokeType("Fighting", 1);
            Flying = new PokeType("Flying", 2);
            Poison = new PokeType("Poison", 3);
            Ground = new PokeType("Ground", 4);
            Rock = new PokeType("Rock", 5);
            Bug = new PokeType("Bug", 6);
            Ghost = new PokeType("Ghost", 7);
            Steel = new PokeType("Steel", 8);
            Unknown = new PokeType("???", 9);
            Fire = new PokeType("Fire", 10);
            Water = new PokeType("Water", 11);
            Grass = new PokeType("Grass", 12);
            Electric = new PokeType("Electric", 13);
            Psychic = new PokeType("Psychic", 14);
            Ice = new PokeType("Ice", 15);
            Dragon = new PokeType("Dragon", 16);
            Dark = new PokeType("Dark", 17);
            Fairy = new PokeType("Fairy", 18);

            Normal.SetMatchups(
                new PokeType[] { },
                new PokeType[] { Rock, Steel },
                new PokeType[] { Ghost }
                );
            
            Fighting.SetMatchups(
                new PokeType[] { Normal, Rock, Steel, Ice, Dark },
                new PokeType[] { Flying, Poison, Bug, Psychic, Fairy },
                new PokeType[] { Ghost }
                );
            
            Flying.SetMatchups(
                new PokeType[] { Fighting, Bug, Grass },
                new PokeType[] { Rock, Steel, Electric },
                new PokeType[] { }
                );
            
            Poison.SetMatchups(
                new PokeType[] { Grass, Fairy },
                new PokeType[] { Poison, Ground, Rock, Ghost },
                new PokeType[] { Steel }
                );
            
            Ground.SetMatchups(
                new PokeType[] { Poison, Rock, Steel, Fire, Electric },
                new PokeType[] { Bug, Grass },
                new PokeType[] { Flying }
                );
           
            Rock.SetMatchups(
                new PokeType[] { Flying, Bug, Fire, Ice },
                new PokeType[] { Fighting, Ground, Steel },
                new PokeType[] { }
                );
            
            Bug.SetMatchups(
                new PokeType[] { Grass, Psychic, Dark },
                new PokeType[] { Fighting, Flying, Poison, Ghost, Steel, Fire, Fairy },
                new PokeType[] { }
                );
            
            Ghost.SetMatchups(
                new PokeType[] { Ghost, Psychic },
                new PokeType[] { Dark },
                new PokeType[] { Normal }
                );

            Steel.SetMatchups(
                new PokeType[] { Rock, Ice, Fairy },
                new PokeType[] { Steel, Fire, Water, Electric },
                new PokeType[] { }
                );
            
            Unknown.SetMatchups(
                new PokeType[] { },
                new PokeType[] { },
                new PokeType[] { }
                );
            
            Fire.SetMatchups(
                new PokeType[] { Bug, Steel, Grass, Ice },
                new PokeType[] { Rock, Fire, Water, Dragon },
                new PokeType[] { }
                );

            Water.SetMatchups(
                new PokeType[] { Ground, Rock, Fire },
                new PokeType[] { Water, Grass, Dragon },
                new PokeType[] { }
                );
            
            Grass.SetMatchups(
                new PokeType[] { Ground, Rock, Water },
                new PokeType[] { Flying, Poison, Bug, Steel, Fire, Grass, Dragon },
                new PokeType[] { }
                );
            
            Electric.SetMatchups(
                new PokeType[] { Flying, Water },
                new PokeType[] { Grass, Electric, Dragon },
                new PokeType[] { Ground }
                );
            
            Psychic.SetMatchups(
                new PokeType[] { Fighting, Poison },
                new PokeType[] { Steel, Psychic },
                new PokeType[] { Dark }
                );
            
            Ice.SetMatchups(
                new PokeType[] { Flying, Ground, Grass, Dragon },
                new PokeType[] { Steel, Fire, Water, Ice },
                new PokeType[] { }
                );

            Dragon.SetMatchups(
                new PokeType[] { Dragon },
                new PokeType[] { Steel },
                new PokeType[] { Fairy }
                );
            
            Dark.SetMatchups(
                new PokeType[] { Ghost, Psychic },
                new PokeType[] { Fighting, Dark, Fairy },
                new PokeType[] { }
                );
            
            Fairy.SetMatchups(
                new PokeType[] { Fighting, Dragon, Dark },
                new PokeType[] { Poison, Steel, Fire },
                new PokeType[] { }
                );

            Types = new PokeType[] { Normal, Fighting, Flying, Poison, Ground, Rock, Bug, Ghost, Steel, Unknown, Fire, Water, Grass, Electric, Psychic, Ice, Dragon, Dark, Fairy };
        }

        public string Name;
        public int ID;
        public PokeType[] EffectiveAgainst;
        public PokeType[] IneffectiveAgainst;
        public PokeType[] NoEffectAgainst;

        public PokeType(string name, int id) {
            Name = name;
            ID = id;
        }

        public PokeType(string name, int id, PokeType[] effectiveAgainst, PokeType[] ineffectiveAgainst, PokeType[] noEffectAgainst) {
            Name = name;
            ID = id;
            EffectiveAgainst = effectiveAgainst;
            IneffectiveAgainst = ineffectiveAgainst;
            NoEffectAgainst = noEffectAgainst;
        }

        public void SetMatchups(PokeType[] effectiveAgainst, PokeType[] ineffectiveAgainst, PokeType[] noEffectAgainst) {
            EffectiveAgainst = effectiveAgainst;
            IneffectiveAgainst = ineffectiveAgainst;
            NoEffectAgainst = noEffectAgainst;
        }

        public override bool Equals(object obj) {
            if (obj is PokeType type) {
                return Name == type.Name && ID == type.ID;
            }
            return false;
        }

        public override int GetHashCode() {
            Debug.Log("Hash code");
            return base.GetHashCode();
        }

        public float GetMatchupAttacking(PokeType type) {
            if (type == null) { return 1f; }
            else if (EffectiveAgainst.Contains(type)) { return 2f; }
            else if (IneffectiveAgainst.Contains(type)) { return 0.5f; }
            else if (NoEffectAgainst.Contains(type)) { return 0f; }
            else { return 1f; }
        }

        public float GetMatchupAttacking(Typing typing) {
            Debug.Log($"{ToString()} attacking {typing}");
            float m1 = GetMatchupAttacking(typing.Type1); Debug.Log($"{ToString()} attacking {typing.Type1}: {m1}");
            float m2 = GetMatchupAttacking(typing.Type2); Debug.Log($"{ToString()} attacking {typing.Type2}: {m2}");
            float ret = m1 * m2;
            Debug.Log($"{ToString()} attacking {typing}: {ret}");
            return ret;
        }

        public static PokeType GetType(string name) {
            foreach (PokeType type in Types) {
                if (type.Name == name) return type;
            }
            return null;
        }

        public override string ToString() {
            return Name;
        }

    }

    public class Typing {

        public readonly PokeType Type1;
        public readonly PokeType Type2;

        public bool NoType {
            get {
                return Type1 == null && Type2 == null;
            }
        }

        public bool SingleType {
            get {
                return Type1 != null && Type2 == null;
            }
        }

        public Typing(string type1, string type2) {
            Type1 = PokeType.GetType(type1);
            Type2 = PokeType.GetType(type2);
        }

        public Typing(string type1) {
            Type1 = PokeType.GetType(type1);
            Type2 = null;
        }

        public bool Has(PokeType type) {
            return Type1 == type || Type2 == type;
        }

        public override string ToString() {
            if (Type1 == null && Type2 == null) {
                return "No typing";
            }
            if (Type1 == null && Type2 != null) {
                return Type2.ToString();
            }
            if (Type1 != null && Type2 == null) {
                return Type1.ToString();
            }
            return $"{Type1.ToString()}/{Type2.ToString()}";
        }

    }
}
