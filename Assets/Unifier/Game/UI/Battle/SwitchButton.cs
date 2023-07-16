using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI.Battle {

    internal class SwitchButton : MonoBehaviour {

        public Image Icon;

        public void Refresh(BattleSystem.Battler battler) {
            Icon.sprite = UnifierResources.LoadIcon(battler.Pokemon)[0];
        }

    }

}
