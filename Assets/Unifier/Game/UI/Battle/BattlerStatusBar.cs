using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI.Battle {

    internal class BattlerStatusBar : MonoBehaviour {

        public TMP_Text Name;
        public Image HealthBar;
        public Image HealthBarBack; // TODO: health bar scaling
        // TODO: statuses, type display

        public void Refresh(BattleSystem.Battler battler) {
            Name.SetText(battler.Pokemon.Name);
            int maxHP = battler.HP;
            HealthBar.fillAmount = battler.Pokemon.HPPercentage;
        }

    }

}
