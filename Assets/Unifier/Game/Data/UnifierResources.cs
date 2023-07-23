using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game.Data {

    //
    // Utility class for loading files from Resources, given a reference to a Pokemon.
    //
    internal class UnifierResources {

        // ex. female shiny Raichu: 026fs
        private static string getDescriptor(Pokemon pokemon, bool backsprite) {
            string desc = zeropad(pokemon.Species.NatDex);
            if (pokemon.Species.HasGenderDifferences && pokemon.IsFemale) { desc += "f"; }
            if (pokemon.Shiny) desc += "s";
            if (backsprite) desc += "b";

            //if (!pokemon.IsDefaultForm) {
            if (pokemon.Species.Forms.Length != 0) {
                desc += "-" + string.Join("-", pokemon.Species.Forms);
            }

            return desc;

        }
        
        private static string zeropad(int n) {
            string ret = n.ToString();
            if (n < 1000) {
                int zeroes = 3 - ret.Length;
                if (zeroes > 0) {
                    for (int i = 0; i < zeroes; i++) {
                        ret = "0" + ret;
                    }
                }
            }
            return ret;
        }

        public static Sprite LoadBattlerSprite(Pokemon pokemon) {
            Debug.Log(getDescriptor(pokemon, false));
            return Resources.Load<Sprite>("Modules/" + pokemon.Species.SourceModule + "/Graphics/Battlers/" + getDescriptor(pokemon, false));
        }

        public static Sprite LoadBattlerBacksprite(Pokemon pokemon) {
            Debug.Log(getDescriptor(pokemon, true));
            return Resources.Load<Sprite>("Modules/" + pokemon.Species.SourceModule + "/Graphics/Battlers/" + getDescriptor(pokemon, true));
        }

        public static Sprite[] LoadOverworldWalkCycle(Pokemon pokemon) {
            return Resources.LoadAll<Sprite>("Modules/" + pokemon.Species.SourceModule + "/Graphics/Characters/" + getDescriptor(pokemon, false) + "b");
        }

        public static Sprite[] LoadOverworldWalkCycle(string filename) {
            return Resources.LoadAll<Sprite>("Modules/Official/Graphics/Characters/" + filename);
        }

        public static Sprite[] LoadIcon(Pokemon pokemon) {
            Sprite[] ret = Resources.LoadAll<Sprite>("Modules/" + pokemon.Species.SourceModule + "/Graphics/Icons/icon" + getDescriptor(pokemon, false));
            if (ret.Length == 0) {
                Debug.Log(getDescriptor(pokemon, false) + " missing icon");
            }
            return ret;
        }

        private static Sprite[] typeBarIcons;
        public static Sprite LoadTypeBarIcon(PokeType pokeType) {
            if (typeBarIcons == null) {
                typeBarIcons = Resources.LoadAll<Sprite>("Modules/Official/Graphics/Pictures/types");
            }
            return typeBarIcons[pokeType.ID];
        }

        private static Sprite[] categoryIcons;
        public static Sprite LoadCategoryIcon(MoveCategories category) {
            if (categoryIcons == null) {
                categoryIcons = Resources.LoadAll<Sprite>("Modules/Official/Graphics/Pictures/category");
            }
            return categoryIcons[(int)category];
        }

    }

}
