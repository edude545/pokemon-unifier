using Assets.Unifier.Game.UI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Engine {

    internal class TrainerAI {

        public TrainerAIType AIType;

        public void ChooseActions(BattleSide battleSide) {
            switch (AIType) {
                case TrainerAIType.RandomMoves: randomMoves(battleSide); break;
            }
        }

        private void randomMoves(BattleSide battleSide) {
            foreach (Battler battler in battleSide.Battlers) {
                battleSide.BattleSystem.QueueAction(new MoveAction(battler, UnityEngine.Random.Range(0,battler.Moves.Length), new BattlePosition[] { new BattlePosition(0,0), new BattlePosition(0,1) }));
            }
        }

    }

    internal enum TrainerAIType {
        RandomMoves
    }

}
