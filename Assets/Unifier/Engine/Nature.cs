using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class Nature {

        public static Nature Hardy      = new Nature("Hardy", PokeStat.Atk, PokeStat.Atk);
        public static Nature Lonely     = new Nature("Lonely", PokeStat.Atk, PokeStat.Def);
        public static Nature Adamant    = new Nature("Adamant", PokeStat.Atk, PokeStat.SpA);
        public static Nature Naughty    = new Nature("Naughty", PokeStat.Atk, PokeStat.SpD);
        public static Nature Brave      = new Nature("Brave", PokeStat.Atk, PokeStat.Atk);

        public static Nature Bold       = new Nature("Bold", PokeStat.Def, PokeStat.Atk);
        public static Nature Docile     = new Nature("Docile", PokeStat.Def, PokeStat.Def);
        public static Nature Impish     = new Nature("Impish", PokeStat.Def, PokeStat.SpA);
        public static Nature Lax        = new Nature("Lax", PokeStat.Def, PokeStat.SpD);
        public static Nature Relaxed    = new Nature("Relaxed", PokeStat.Def, PokeStat.Atk);

        public static Nature Modest     = new Nature("Modest", PokeStat.SpA, PokeStat.Atk);
        public static Nature Mild       = new Nature("Mild", PokeStat.SpA, PokeStat.Def);
        public static Nature Bashful    = new Nature("Bashful", PokeStat.SpA, PokeStat.SpA);
        public static Nature Rash       = new Nature("Rash", PokeStat.SpA, PokeStat.SpD);
        public static Nature Quiet      = new Nature("Quiet", PokeStat.SpA, PokeStat.Atk);

        public static Nature Calm       = new Nature("Calm", PokeStat.SpD, PokeStat.Atk);
        public static Nature Gentle     = new Nature("Gentle", PokeStat.SpD, PokeStat.Def);
        public static Nature Careful    = new Nature("Careful", PokeStat.SpD, PokeStat.SpA);
        public static Nature Quirky     = new Nature("Quirky", PokeStat.SpD, PokeStat.SpD);
        public static Nature Sassy      = new Nature("Sassy", PokeStat.SpD, PokeStat.Atk);

        public static Nature Timid      = new Nature("Timid", PokeStat.Spe, PokeStat.Atk);
        public static Nature Hasty      = new Nature("Hasty", PokeStat.Spe, PokeStat.Def);
        public static Nature Jolly      = new Nature("Jolly", PokeStat.Spe, PokeStat.SpA);
        public static Nature Naive      = new Nature("Naive", PokeStat.Spe, PokeStat.SpD);
        public static Nature Serious    = new Nature("Serious", PokeStat.Spe, PokeStat.Spe);

        public static Nature[] Natures = new Nature[25] {
            Hardy, Lonely, Adamant, Naughty, Brave,
            Bold, Docile, Impish, Lax, Relaxed,
            Modest, Mild, Bashful, Rash, Quiet,
            Calm, Gentle, Careful, Quirky, Sassy,
            Timid, Hasty, Jolly, Naive, Serious
        };

        public string Name { get; private set; }
        public PokeStat Up { get; private set; }
        public PokeStat Down { get; private set; }
        public int ID { get; private set; }

        public Nature(string name, PokeStat up, PokeStat down) {
            Name = name;
            Up = up;
            Down = down;
        }

        public static Nature GetRandom() {
            return Natures[Random.Range(0, 25)];
        }

        public float GetMult(PokeStat stat) {
            if (Up == Down) {
                return 1f;
            } else if (Up == stat) {
                return 1.1f;
            } else if (Down == stat) {
                return 0.9f;
            } else {
                return 1f;
            }
        }

        public override string ToString() {
            return Name;
        }

    }
}
