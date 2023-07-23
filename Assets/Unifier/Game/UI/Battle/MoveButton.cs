using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI {

    internal class MoveButton : MonoBehaviour {

        private Move loadedMove;

        public int Index;
        public Image Background;
        public TMP_Text MoveName;

        public TMP_Text PP;
        public TMP_Text MaxPP;

        public Image CategoryIcon;
        public Image TypeIcon;

        public void Refresh(BattleSystem.Battler battler) {
            Move move = battler.Pokemon.Moves[Index];
            if (loadedMove == move) return;
            loadedMove = move;
            try {
                MoveName.SetText(move.Name);
            } catch (NullReferenceException) {
                Debug.Log($"Null ref exception for move slot {Index} on {battler.Pokemon.Species.Identifier}");
            }
            PP.SetText(battler.Pokemon.PP[Index].ToString());
            MaxPP.SetText(battler.Pokemon.MaxPP[Index].ToString());
            TypeIcon.sprite = UnifierResources.LoadTypeBarIcon(move.Type);
            CategoryIcon.sprite = UnifierResources.LoadCategoryIcon(move.Category);
        }

    }

}
