using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine.TextCore.Text;
using UnityEngine;

namespace Assets.Unifier.Game {
    
    // Should be operated by another component, such as PlayerControl
    internal class TrainerCharacter : OverworldCharacter {

        public TrainerData Trainer;

        private enum BallStatus { Empty, Ball, Midair, Overworld }
        private BallStatus[] ballStatuses;
        private PokemonCharacter[] deployedPokemon;

        public GameObject ThrownBallPrefab;

        protected override void Start() {
            base.Start();
            Trainer = new TrainerData();
            ballStatuses = new BallStatus[Trainer.PartyMax];
            deployedPokemon = new PokemonCharacter[Trainer.PartyMax];
        }

        public void TryThrowOrWithdraw(int index) {
            updateBallStatuses();
            if (ballStatuses[index] == BallStatus.Ball && Trainer.GetPartyMember(index) != null) {
                Deploy(index);
            } else if (ballStatuses[index] == BallStatus.Overworld) {
                Withdraw(index);
            }
        }

        // Should only be called if there is a Pokemon available in this slot
        public void Deploy(int index) {
            ballStatuses[index] = BallStatus.Midair;
            GameObject ball = Instantiate(ThrownBallPrefab);
            ball.transform.position = transform.position;
            ball.GetComponent<ThrownPokeball>().LoadFromPokemon(Camera.main.ScreenToWorldPoint(Input.mousePosition), this, index, onBallLandSuccess, onBallLandFail);
        }

        public void Withdraw(int index) {
            ballStatuses[index] = BallStatus.Ball;
            deployedPokemon[index].DespawnWithdraw();
        }

        private void updateBallStatuses() {
            for (int i = 0; i < Trainer.PartyMax; i++) {
                if (ballStatuses[i] == BallStatus.Empty && Trainer.GetPartyMember(i) != null) {
                    ballStatuses[i] = BallStatus.Ball;
                }
            }
        }

        private void onBallLandSuccess(int index, PokemonCharacter pokemonCharacter) {
            ballStatuses[index] = BallStatus.Overworld;
            deployedPokemon[index] = pokemonCharacter;
        }

        private void onBallLandFail(int index) {
            ballStatuses[index] = BallStatus.Ball;
        }

    }

}
