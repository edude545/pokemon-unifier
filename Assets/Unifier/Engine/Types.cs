using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class PokeType {

        public static PokeType Normal = new PokeType("Normal", 0,
            new PokeType[] { },
            new PokeType[] { Rock, Steel },
            new PokeType[] { Ghost }
            );
        public static PokeType Fighting = new PokeType("Fighting", 1,
            new PokeType[] { Normal, Rock, Steel, Ice, Dark },
            new PokeType[] { Flying, Poison, Bug, Psychic, Fairy },
            new PokeType[] { Ghost }
            );
        public static PokeType Flying = new PokeType("Flying", 2,
            new PokeType[] { Fighting, Bug, Grass },
            new PokeType[] { Rock, Steel, Electric },
            new PokeType[] { }
            );
        public static PokeType Poison = new PokeType("Poison", 3,
            new PokeType[] { Grass, Fairy },
            new PokeType[] { Poison, Ground, Rock, Ghost },
            new PokeType[] { Steel }
            );
        public static PokeType Ground = new PokeType("Ground", 4,
            new PokeType[] { Poison, Rock, Steel, Fire, Electric },
            new PokeType[] { Bug, Grass },
            new PokeType[] { Flying }
            );
        public static PokeType Rock = new PokeType("Rock", 5,
            new PokeType[] { Flying, Bug, Fire, Ice },
            new PokeType[] { Fighting, Ground, Steel },
            new PokeType[] { }
            );
        public static PokeType Bug = new PokeType("Bug", 6,
            new PokeType[] { Grass, Psychic, Dark },
            new PokeType[] { Fighting, Flying, Poison, Ghost, Steel, Fire, Fairy },
            new PokeType[] { }
            );
        public static PokeType Ghost = new PokeType("Ghost", 7,
            new PokeType[] { Ghost, Psychic },
            new PokeType[] { Dark },
            new PokeType[] { Normal }
            );
        public static PokeType Steel = new PokeType("Steel", 8,
            new PokeType[] { Rock, Ice, Fairy },
            new PokeType[] { Steel, Fire, Water, Electric },
            new PokeType[] { }
            );
        public static PokeType Unknown = new PokeType("???", 9,
            new PokeType[] { },
            new PokeType[] { },
            new PokeType[] { }
            );
        public static PokeType Fire = new PokeType("Fire", 10,
            new PokeType[] { Bug, Steel, Grass, Ice },
            new PokeType[] { Rock, Fire, Water, Dragon },
            new PokeType[] { }
            );
        public static PokeType Water = new PokeType("Water", 11,
            new PokeType[] { Ground, Rock, Fire },
            new PokeType[] { Water, Grass, Dragon },
            new PokeType[] { }
            );
        public static PokeType Grass = new PokeType("Grass", 12,
            new PokeType[] { Ground, Rock, Water },
            new PokeType[] { Flying, Poison, Bug, Steel, Fire, Grass, Dragon },
            new PokeType[] { }
            );
        public static PokeType Electric = new PokeType("Electric", 13,
            new PokeType[] { Flying, Water },
            new PokeType[] { Grass, Electric, Dragon },
            new PokeType[] { Ground }
            );
        public static PokeType Psychic = new PokeType("Psychic", 14,
            new PokeType[] { Fighting, Poison },
            new PokeType[] { Steel, Psychic },
            new PokeType[] { Dark }
            );
        public static PokeType Ice = new PokeType("Ice", 15,
            new PokeType[] { Flying, Ground, Grass, Dragon },
            new PokeType[] { Steel, Fire, Water, Ice },
            new PokeType[] { }
            );
        public static PokeType Dragon = new PokeType("Dragon", 16,
            new PokeType[] { Dragon },
            new PokeType[] { Steel },
            new PokeType[] { Fairy }
            );
        public static PokeType Dark = new PokeType("Dark", 17,
            new PokeType[] { Ghost, Psychic },
            new PokeType[] { Fighting, Dark, Fairy },
            new PokeType[] { }
            );
        public static PokeType Fairy = new PokeType("Fairy", 18,
            new PokeType[] { Fighting, Dragon, Dark },
            new PokeType[] { Poison, Steel, Fire },
            new PokeType[] { }
            );

        public static PokeType[] Types = new PokeType[] { Normal, Fighting, Flying, Poison, Ground, Rock, Bug, Ghost, Steel, Unknown,
            Fire, Water, Grass, Electric, Psychic, Ice, Dragon, Dark, Fairy };

        public string Name;
        public int ID;
        public PokeType[] EffectiveAgainst;
        public PokeType[] IneffectiveAgainst;
        public PokeType[] NoEffectAgainst;

        public PokeType(string name, int id, PokeType[] effectiveAgainst, PokeType[] ineffectiveAgainst, PokeType[] noEffectAgainst) {
            Name = name;
            ID = id;
            EffectiveAgainst = effectiveAgainst;
            IneffectiveAgainst = ineffectiveAgainst;
            NoEffectAgainst = noEffectAgainst;
        }

        public float GetMatchupAttacking(PokeType type) {
            if (EffectiveAgainst.Contains(type)) return 2f;
            if (IneffectiveAgainst.Contains(type)) return 0.5f;
            if (NoEffectAgainst.Contains(type)) return 0f;
            return 1f;
        }

        public float GetMatchupAttacking(Typing typing) {
            return GetMatchupAttacking(typing.Type1) * GetMatchupAttacking(typing.Type2);
        }

        public static PokeType GetType(string name) {
            foreach (PokeType type in Types) {
                if (type.Name == name) return type;
            }
            return null;
        }

    }

    public class Typing {

        public readonly PokeType Type1;
        public readonly PokeType Type2;

        public Typing(string type1, string type2) {
            Type1 = PokeType.GetType(type1);
            Type2 = PokeType.GetType(type2);
        }

        public Typing(string type1) {
            Type1 = PokeType.GetType(type1);
            Type2 = null;
        }

        public float GetMatchup(PokeType type) {
            return type.GetMatchupAttacking(Type1) * type.GetMatchupAttacking(Type2);
        }

        public bool Has(PokeType type) {
            return Type1 == type || Type2 == type;
        }

    }
}
