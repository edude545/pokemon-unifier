using Assets.Unifier.Engine;
using Assets.Unifier.Game;
using Assets.Unifier.Game.Editor;
using Assets.Unifier.Game.UI;
using Assets.Unifier.Game.UI.Battle;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using TMPro;
using UnityEditor.ShaderKeywordFilter;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Battle {

    internal class BattleUIController : MonoBehaviour {

        private BattleSystem battleSystem;
        private BattleSide player;

        private TrainerAI trainerAI;

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

        private bool waitingForPlayerInput;

        private Battler currentPlayerBattler {
            get {
                return battleSystem.PlayerSide.Battlers[currentlySelectedBattlerIndex];
            }
        }

        private void Start() {
            Initialize();
        }

        private Species randomSpecies() {
            return UnifierModule.Modules["Official"].GetRandomSpecies();
        }

        public void RandomizeBattlers() {
            TrainerData tPlayer = new TrainerData();
            tPlayer.AddPartyMember(new Pokemon(Species.GetByInternalName("raticate-alola"), 100));
            tPlayer.AddPartyMember(new Pokemon(randomSpecies(), 100));
            // tPlayer.AddPartyMember(new Pokemon(randomSpecies(), 100));
            TrainerData tComputer = new TrainerData();
            tComputer.AddPartyMember(new Pokemon(randomSpecies(), 100));
            tComputer.AddPartyMember(new Pokemon(randomSpecies(), 100));
            Debug.Log($"{tPlayer.GetPartyMember(0).Species.Identifier} and {tPlayer.GetPartyMember(1).Species.Identifier} vs {tComputer.GetPartyMember(0).Species.Identifier} and {tComputer.GetPartyMember(1).Species.Identifier}");
            battleSystem.Sides[0] = new BattleSide(battleSystem, tPlayer, 2);
            battleSystem.Sides[1] = new BattleSide(battleSystem, tComputer, 2);
            battleSystem.ClearActions();
            trainerAI.ChooseActions(battleSystem.Sides[1]);
            refresh();
        }

        public void Initialize() {
            TrainerData tPlayer = new TrainerData();
            TrainerData tComputer = new TrainerData();

            trainerAI = new TrainerAI();
            trainerAI.AIType = TrainerAIType.RandomMoves;

            battleSystem = new BattleSystem(BattleTypes.Double, tPlayer, tComputer);
            RandomizeBattlers();

            submittedPlayerActions = new List<Action>();

            refresh();

            BattleLogDisplay.text = "";

            OnTurnStart();
        }

        private void Update() {
            if (!waitingForPlayerInput) {
                if (Input.GetKeyDown(KeyCode.Z)) {
                    Next();
                }
            }
        }

        public void Next() {
            var actionResult = battleSystem.ProcessNextAction();
            logBattleInfo(actionResult.Log);
            if (actionResult.LastActionThisTurn) {
                OnTurnStart();
            }
        }

        public void OnTurnStart() {
            trainerAI.ChooseActions(battleSystem.Sides[1]);
            currentlySelectedBattlerIndex = 0;
            submittedActionsForBattlers = new bool[battleSystem.PlayerSide.Battlers.Length];
            for (int i = 0; i < submittedActionsForBattlers.Length; i++) { submittedActionsForBattlers[i] = false; }
            submittedPlayerActions.Clear();
            waitingForPlayerInput = true;
            refresh();
            logBattleInfo("=== TURN " + battleSystem.CurrentTurn + " ===");
        }

        public void OnAction(Action action) {
            refresh();
        }

        // =================================================================================
        // Player input logic
        // =================================================================================

        private void submitPlayerAction(Action action) {
            submittedPlayerActions.Add(action);
            submittedActionsForBattlers[currentlySelectedBattlerIndex] = true;
            if (!submittedActionsForBattlers.Contains(false)) {
                onInputsFinished();
            } else { // Select player's next battler after choosing an action...
                do {
                    currentlySelectedBattlerIndex = (currentlySelectedBattlerIndex + 1) % battleSystem.PlayerSide.Battlers.Length;
                } while (submittedActionsForBattlers[currentlySelectedBattlerIndex]); // ...player can select actions out of order, so this may have to be done repeatedly.
            }
            refresh();
        }

        private void onInputsFinished() {
            logBattleInfo("Inputs finished");
            battleSystem.QueueActions(submittedPlayerActions);
            battleSystem.BeginTurn();
            waitingForPlayerInput = false;
        }

        public void OnMoveButtonClicked(int moveIndex) {
            if (!waitingForPlayerInput) return;
            submitPlayerAction(new MoveAction(currentPlayerBattler, moveIndex, new BattlePosition[] { new BattlePosition(1,0), new BattlePosition(1,1) }));
        }

        public void OnSwitchButtonClicked(int partyMemberIndex) {
            if (!waitingForPlayerInput) return;
            submitPlayerAction(new SwitchAction(currentPlayerBattler, partyMemberIndex));
        }

        public void OnPlayerBattlerClicked(int position) {
            currentlySelectedBattlerIndex = position;
            submittedActionsForBattlers[currentlySelectedBattlerIndex] = false;
        }

        // =================================================================================
        // UI update logic
        // =================================================================================

        private void refresh() {
            for (int i = 0; i < PlayerBattlers.Length; i++) {
                PlayerBattlers[i].Refresh(battleSystem.PlayerSide.Battlers[i]);
            }
            for (int i = 0; i < OpponentBattlers.Length; i++) {
                OpponentBattlers[i].Refresh(battleSystem.Sides[1].Battlers[i]);
            }
            for (int i = 0; i < 4; i++) {
                MoveButtons[i].Refresh(battleSystem.PlayerSide.Battlers[currentlySelectedBattlerIndex]);
            }
            for (int i = 0; i < SwitchButtons.Length; i++) {
                SwitchButtons[i].Refresh(battleSystem.PlayerSide.Trainer.GetPartyMember(i));
            }
        }

        // After the user clicks a switchout move (U-Turn, Parting Shot, Baton Pass...), grey out move buttons and that Pokemon's icon, show a "cancel" button, and only allow party members to be clicked.
        private void onSwitchoutMoveSelected() {
            // TODO: ui stuff
        }

        private void logBattleInfo(string message) {
            //Debug.Log(message);
            BattleLogDisplay.text += message + "\n";
        }

        // =================================================================================
        
        public void ShowBattlerDebugInfo() {
            foreach (BattleSide bs in battleSystem.Sides) {
                foreach (Battler b in bs.Battlers) {
                    logBattleInfo(b.ToString());
                }
            }
            
        }

    }
}
