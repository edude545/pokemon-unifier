using Assets.Unifier.Engine;
using Assets.Unifier.Game;
using Assets.Unifier.Game.UI;
using Assets.Unifier.Game.UI.Battle;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TMPro;
using UnityEditor.ShaderKeywordFilter;
using UnityEngine;
using UnityEngine.UI;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Battle {

    internal class BattleUIController : MonoBehaviour {

        private BattleSystem battleSystem;
        private BattleSide player;

        // UI elements
        public BattlerDisplay[] PlayerBattlers;
        public BattlerDisplay[] OpponentBattlers;
        public MoveButton[] MoveButtons;
        public SwitchButton[] SwitchButtons;
        public TMP_Text BattleLogDisplay;

        //public enum ActionType { Move, Switch, Back }
        private List<Action> submittedPlayerActions;

        private int currentlySelectedBattlerIndex;
        private bool[] submittedActionsForBattlers;

        private bool selectingPartyMemberForSwitchoutMove;
        private int cachedMoveIndex;

        private bool waitingForPlayerInput;

        private Battler currentPlayerBattler {
            get {
                return battleSystem.PlayerSide.Battlers[currentlySelectedBattlerIndex];
            }
        }

        private void Start() {
            Initialize();
        }

        public void Initialize() {
            TrainerData tPlayer = new TrainerData();
            tPlayer.AddPartyMember(new Pokemon(GameController.GetSpecies("Magnezone"), 48));
            tPlayer.AddPartyMember(new Pokemon(GameController.GetSpecies("Delphox"), 58));
            TrainerData tComputer = new TrainerData();
            tComputer.AddPartyMember(new Pokemon(GameController.GetSpecies("Dragonite"), 55));
            tComputer.AddPartyMember(new Pokemon(GameController.GetSpecies("Flygon"), 52));
            
            currentlySelectedBattlerIndex = 0;
            selectingPartyMemberForSwitchoutMove = false;
            battleSystem = new BattleSystem(BattleTypes.Single, tPlayer, tComputer);

            waitingForPlayerInput = true;
        }

        private void Update() {
            if (!waitingForPlayerInput) {
                if (Input.GetKeyDown(KeyCode.Z)) {
                    var actionResult = battleSystem.Next();
                    logBattleInfo(actionResult.Log);
                    if (actionResult.LastActionThisTurn) {
                        waitingForPlayerInput = true;
                        logBattleInfo("=== \nTURN " + battleSystem.CurrentTurn + " ===");
                    }
                }
            }
        }

        public void OnPlayerTurnBegin() {
            
        }

        public void OnPlayerTurnEnd() { 

        }

        public void OnAction(Action action) {
            refreshBattlers();
        }

        // =================================================================================
        // Player input logic
        // =================================================================================

        private void submitPlayerAction(Action action) {
            submittedPlayerActions.Add(action);
            submittedActionsForBattlers[currentlySelectedBattlerIndex] = true;
            if (!submittedPlayerActions.Contains(null)) {
                battleSystem.QueueActions(submittedPlayerActions);
                submittedPlayerActions.Clear();
                battleSystem.CloseInputs();
                waitingForPlayerInput = false;
            } else { // Select player's next battler after choosing an action...
                do {
                    currentlySelectedBattlerIndex = (currentlySelectedBattlerIndex + 1) % battleSystem.PlayerSide.Battlers.Length;
                } while (!submittedActionsForBattlers[currentlySelectedBattlerIndex]); // ...player can select actions out of order, so this may have to be done repeatedly.
            }
            logBattleInfo("Now selected: " + currentlySelectedBattlerIndex);
        }

        public void onMoveButtonClicked(int moveIndex) {
            if (currentPlayerBattler.Moves[moveIndex].MayHaveEffect("switchout", "batonpass")) {
                selectingPartyMemberForSwitchoutMove = true;
                cachedMoveIndex = moveIndex;
                onSwitchoutMoveSelected();
            } else {
                submitPlayerAction(new MoveAction(currentPlayerBattler, moveIndex));
            }
        }

        public void onSwitchButtonClicked(int partyMemberIndex) {
            if (selectingPartyMemberForSwitchoutMove) {
                selectingPartyMemberForSwitchoutMove = false;
                submitPlayerAction(new MoveAndSwitchAction(currentPlayerBattler, cachedMoveIndex, partyMemberIndex));
            } else {
                submitPlayerAction(new SwitchAction(currentPlayerBattler, partyMemberIndex));
            }
        }

        // =================================================================================
        // UI update logic
        // =================================================================================

        private void refreshBattlers() {
            for (int i = 0; i < PlayerBattlers.Length; i++) {
                PlayerBattlers[i].Refresh(battleSystem.PlayerSide.Battlers[i]);
            }
            for (int i = 0; i < OpponentBattlers.Length; i++) {
                OpponentBattlers[i].Refresh(battleSystem.Sides[1].Battlers[i]);
            }
            for (int i = 0; i < 4; i++) {
                MoveButtons[i].Refresh(battleSystem.PlayerSide.Battlers[0]);
            }
            for (int i = 0; i < SwitchButtons.Length; i++) {
                SwitchButtons[i].Refresh(battleSystem.PlayerSide.Battlers[i]);
            }
        }

        // After the user clicks a switchout move (U-Turn, Parting Shot, Baton Pass...), grey out move buttons and that Pokemon's icon, show a "cancel" button, and only allow party members to be clicked.
        private void onSwitchoutMoveSelected() {
            // TODO: ui stuff
        }

        private void logBattleInfo(string message) {
            BattleLogDisplay.text += message;
        }

        // =================================================================================

    }
}
