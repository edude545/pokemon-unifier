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
        private static string getDescriptor(Pokemon pokemon) {
            string desc = zeropad(pokemon.Species.NatDex);
            if (pokemon.Species.HasGenderDifferences && pokemon.IsFemale) { desc += "f"; }
            if (pokemon.Shiny) desc += "s";

            if (!pokemon.IsDefaultForm) {
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
            string loadPath = "Modules/" + pokemon.Species.SourceModule + "/Graphics/Battlers/" + getDescriptor(pokemon);
            Debug.Log("Loaded " + pokemon.Species.Name + "'s battler sprite from " + loadPath);
            return Resources.Load<Sprite>(loadPath);
        }

        public static Sprite LoadBattlerBacksprite(Pokemon pokemon) {
            string loadPath = "Modules/" + pokemon.Species.SourceModule + "/Graphics/Battlers/" + getDescriptor(pokemon) + "b";
            Debug.Log("Loaded " + pokemon.Species.Name + "'s battler backsprite from " + loadPath);
            return Resources.Load<Sprite>(loadPath);
        }

        public static Sprite[] LoadOverworldWalkCycle(Pokemon pokemon) {
            string loadPath = "Modules/" + pokemon.Species.SourceModule + "/Graphics/Characters/" + getDescriptor(pokemon) + "b";
            Debug.Log("Loaded " + pokemon.Species.Name + "'s overworld walkcycle from " + loadPath);
            return Resources.LoadAll<Sprite>(loadPath);
        }

        public static Sprite[] LoadOverworldWalkCycle(string filename) {
            string loadPath = "Modules/Essentials/Graphics/Characters/" + filename;
            Debug.Log("Loaded overworld walkcycle from " + loadPath);
            return Resources.LoadAll<Sprite>(loadPath);
        }

        public static Sprite[] LoadIcon(Pokemon pokemon) {
            string loadPath = "Modules/" + pokemon.Species.SourceModule + "/Graphics/Icons/icon" + getDescriptor(pokemon);
            Debug.Log("Loaded " + pokemon.Species.Name + "'s icon from " + loadPath);
            return Resources.LoadAll<Sprite>(loadPath);
        }

    }

}
