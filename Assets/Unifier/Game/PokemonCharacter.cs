using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using System;
using UnityEditor;
using UnityEngine;

namespace Assets.Unifier.Game {

    internal class PokemonCharacter : OverworldCharacter {

        public void LoadFromPokemon(Pokemon pokemon) {
            Animator.WalkSprites = UnifierResources.LoadOverworldWalkCycle(pokemon);
            Animator.LoadSprites();
        }

        public void DespawnWithdraw() {
            Destroy(gameObject);
        }

    }

}
