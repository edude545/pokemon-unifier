using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.UI.Battle;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI {

    internal class BattlerDisplay : MonoBehaviour {

        public Image BaseSprite;
        public Image PokemonSprite;
        public bool UseBacksprite;
        public BattlerStatusBar StatusBar;

        public void Refresh(BattleSystem.Battler battler) {
            StatusBar.Refresh(battler);
            BaseSprite.sprite = UnifierResources.LoadBattlerSprite(battler.Pokemon);
            RectTransform baseSpriteTransform = BaseSprite.GetComponent<RectTransform>();
            baseSpriteTransform.sizeDelta *= UseBacksprite ? 200f : 150f;
        }

    }

}
