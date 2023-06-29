using Assets.Unifier.Engine;
using System;
using UnityEditor;
using UnityEngine;

namespace Assets.Unifier.Game {

    internal class PokemonCharacter : OverworldCharacter {

        public void LoadFromPokemon(Pokemon pokemon) {
            string fn = pokemon.Species.NatDex.ToString();
            int zeroes = 3 - fn.Length;
            if (zeroes > 0) {
                for (int i = 0; i < zeroes; i++) {
                    fn = "0" + fn;
                }
            }
            if (pokemon.Species.HasGenderDifferences && pokemon.IsFemale) fn += "f";
            if (pokemon.Shiny) fn += "s";
            Debug.Log("requesting " + fn);
            if (!pokemon.IsDefaultForm) {
                fn += "-" + string.Join("-", pokemon.Species.Forms);
            }
            
            if (pokemon.Species.HasGenderDifferences && BundleLoader.LoadAsset<Sprite>("overworld_characters", fn) == null) {
                Debug.Log("Spritesheet not found! Changing " + fn + "...");
                fn = string.Join("", fn.Split("f", 1));
                Debug.Log("...to " + fn);
            }

            Animator.SpritesheetName = fn;
            Animator.LoadSprites();
        }

        public void DespawnWithdraw() {
            Destroy(gameObject);
        }

    }

}
