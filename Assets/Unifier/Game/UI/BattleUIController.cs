using Assets.Unifier.Engine;
using Assets.Unifier.Game;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Battle {

    internal class BattleUIController : MonoBehaviour {

        private BattleSystem battleSystem;
        private BattleSide player;
        private int currentBattler;

        private void Start() {
            TrainerData tPlayer = new TrainerData();
            tPlayer.AddPartyMember(new Pokemon(GameController.GetSpecies("Magnezone"), 48));
            tPlayer.AddPartyMember(new Pokemon(GameController.GetSpecies("Delphox"), 58));
            TrainerData tComputer = new TrainerData();
            tComputer.AddPartyMember(new Pokemon(GameController.GetSpecies("Dragonite"), 55));
            tComputer.AddPartyMember(new Pokemon(GameController.GetSpecies("Flygon"), 52));
            currentBattler = 0;
            battleSystem = new BattleSystem(BattleTypes.Single, tPlayer, tComputer);
        }

        private void Update() {
            if (battleSystem.WaitingForInputs) {
                if (battleSystem.InputsReady) {
                    battleSystem.CloseInputs();
                }
            } else {
                if (Input.GetKeyDown(KeyCode.Z)) {
                    battleSystem.Next();
                }
            }
        }

        public void OnPlayerTurnBegin() {
            
        }

        public void OnPlayerTurnEnd() { 

        }

        public void OnAction(Action action) {

        }

        public void PressMoveButton(int index) {
            battleSystem.PlayerSide.Battlers[currentBattler].SetActionMove(index);
        }

    }
}
