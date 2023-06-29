using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class Nature {

        public static Nature[] Natures = new Nature[25];

        public static Nature Hardy      = new Nature(PokeStat.Atk, PokeStat.Atk);
        public static Nature Lonely     = new Nature(PokeStat.Atk, PokeStat.Def);
        public static Nature Adamant    = new Nature(PokeStat.Atk, PokeStat.SpA);
        public static Nature Naughty    = new Nature(PokeStat.Atk, PokeStat.SpD);
        public static Nature Brave      = new Nature(PokeStat.Atk, PokeStat.Atk);

        public static Nature Bold       = new Nature(PokeStat.Def, PokeStat.Atk);
        public static Nature Docile     = new Nature(PokeStat.Def, PokeStat.Def);
        public static Nature Impish     = new Nature(PokeStat.Def, PokeStat.SpA);
        public static Nature Lax        = new Nature(PokeStat.Def, PokeStat.SpD);
        public static Nature Relaxed    = new Nature(PokeStat.Def, PokeStat.Atk);

        public static Nature Modest     = new Nature(PokeStat.SpA, PokeStat.Atk);
        public static Nature Mild       = new Nature(PokeStat.SpA, PokeStat.Def);
        public static Nature Bashful    = new Nature(PokeStat.SpA, PokeStat.SpA);
        public static Nature Rash       = new Nature(PokeStat.SpA, PokeStat.SpD);
        public static Nature Quiet      = new Nature(PokeStat.SpA, PokeStat.Atk);

        public static Nature Calm       = new Nature(PokeStat.SpD, PokeStat.Atk);
        public static Nature Gentle     = new Nature(PokeStat.SpD, PokeStat.Def);
        public static Nature Careful    = new Nature(PokeStat.SpD, PokeStat.SpA);
        public static Nature Quirky     = new Nature(PokeStat.SpD, PokeStat.SpD);
        public static Nature Sassy      = new Nature(PokeStat.SpD, PokeStat.Atk);

        public static Nature Timid      = new Nature(PokeStat.Spe, PokeStat.Atk);
        public static Nature Hasty      = new Nature(PokeStat.Spe, PokeStat.Def);
        public static Nature Jolly      = new Nature(PokeStat.Spe, PokeStat.SpA);
        public static Nature Naive      = new Nature(PokeStat.Spe, PokeStat.SpD);
        public static Nature Serious    = new Nature(PokeStat.Spe, PokeStat.Spe);

        public PokeStat Up { get; private set; }
        public PokeStat Down { get; private set; }
        public int ID { get; private set; }

        public Nature(PokeStat up, PokeStat down) {
            Up = up;
            Down = down;
            for (int i = 0; i < 25; i++) {
                if (Natures[i] == null) {
                    ID = i;
                    Natures[i] = this;
                    break;
                }
            }
        }

        public static Nature GetRandom() {
            return Natures[Random.Range(0, 25)];
        }

        public float GetMult(PokeStat stat) {
            if (Up == stat) {
                return 1.1f;
            } else if (Down == stat) {
                return 0.9f;
            } else {
                return 1f;
            }
        }

    }
}
