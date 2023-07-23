using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Editor;
using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game {

    public class GameController : MonoBehaviour {

        public static GameController Instance;

        private void Awake() {
            Instance = this;
            foreach (UnifierModule module in UnifierModule.Modules.Values) {
                module.GenerateAssets();
            }
        }

    }

}
