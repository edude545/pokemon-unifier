using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game {

    [RequireComponent(typeof(Rigidbody2D))]
    internal class ThrownPokeball : MonoBehaviour {

        public GameObject OverworldPokemonPrefab;

        float throwRadius;
        float travelledDistance;

        private TrainerCharacter character;
        private int index;

        public float speed = 1f;

        private Action<int,PokemonCharacter> onLandSuccess;
        private Action<int> onLandFail;

        public void LoadFromPokemon(Vector3 destination, TrainerCharacter character, int index, Action<int, PokemonCharacter> onLandSuccess, Action<int> onLandFail) {
            this.character = character;
            this.index = index;
            this.onLandSuccess = onLandSuccess;
            this.onLandFail = onLandFail;
            travelledDistance = 0f;
            destination = new Vector3(destination.x, destination.y, transform.position.z);
            Vector3 travel = destination - transform.position;
            throwRadius = travel.magnitude;
            Vector3 vel = travel.normalized * speed;
            GetComponent<Rigidbody2D>().velocity = vel;
        }

        private void Update() {
            travelledDistance += speed * Time.deltaTime;
            if (travelledDistance > throwRadius) {
                onLand();
            }
        }

        private void onLand() {
            Pokemon pokemon = character.Trainer.GetPartyMember(index);
            if (pokemon != null) {
                PokemonCharacter owPokemon = Instantiate(OverworldPokemonPrefab).GetComponent<PokemonCharacter>();
                owPokemon.transform.position = transform.position;
                owPokemon.LoadFromPokemon(pokemon);
                onLandSuccess.Invoke(index, owPokemon);
            }
            Destroy(gameObject);
        }

    }

}
