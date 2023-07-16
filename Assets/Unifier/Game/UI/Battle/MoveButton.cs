using Assets.Unifier.Engine;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI {

    internal class MoveButton : MonoBehaviour {

        public int Index;
        public Image Background;
        public TMP_Text MoveName;

        public TMP_Text PP;
        public TMP_Text MaxPP;

        public Image CategoryIcon;
        public Image TypeIcon;



        public void Refresh(BattleSystem.Battler battler) {
            Move move = battler.Pokemon.Moves[Index];
            MoveName.SetText(move.Name);
            PP.SetText(battler.Pokemon.PP[Index].ToString());
            MaxPP.SetText(battler.Pokemon.MaxPP[Index].ToString());
            CategoryIcon.sprite = BundleLoader_DEPRECATED.LoadAssetWithSubAssets<Sprite>("essentials", "category")[(int)move.Category];
            TypeIcon.sprite = BundleLoader_DEPRECATED.LoadAssetWithSubAssets<Sprite>("essentials", "types")[move.Type.ID];
        }

    }

}
