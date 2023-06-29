using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assets.Unifier.Engine {

    public class Breeding {

        public enum EggGroup {

            Monster,
            Humanlike,
            Water1,
            Water3,
            Bug,
            Mineral,
            Flying,
            Amorphous,
            Field,
            Water2,
            Fairy,
            Ditto,
            Grass,
            Dragon,
            NoEggsDiscovered,
            GenderUnknown

        }

        public static EggGroup[] Get(params string[] names) {
            List<EggGroup> groups = new List<EggGroup>();
            EggGroup temp;
            foreach (string name in names) {
                if (name == "Human-Like") {
                    groups.Add(EggGroup.Humanlike);
                } else if (Enum.TryParse(name, false, out temp)) {
                    groups.Add(temp);
                } else if (!string.IsNullOrWhiteSpace(name)) {
                    throw new KeyNotFoundException("No such egg group " + name + "!");
                }
            }
            return groups.ToArray();
        }

    }

}
