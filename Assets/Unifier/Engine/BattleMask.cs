using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assets.Unifier.Engine {

    // A BattleMask object represents the information that has been revealed to the player during a battle.
    // e.g. Most trainers' party members & held items are hidden by default, but when a Pokemon comes out for the first time it will be added to the BattleMask, revealing it to the player.
    internal class BattleMask {

        // Array of BattleSideMasks for each opposing side.
        // The element at the index corresponding to this side is always null.
        public BattleSideMask?[] SideMasks;

        public BattleMask(BattleSystem.BattleSide battleSide) {
            SideMasks = new BattleSideMask?[battleSide.BattleSystem.Sides.Length];
            SideMasks[0] = null;
            for (int i = 0; i < SideMasks.Length; i++) {
                SideMasks[i] = new BattleSideMask();
            }
        }

    }

    internal struct BattleSideMask {

        public bool[] RevealedPartyMembers;
        public bool[] RevealedHeldItems;

        public BattleSideMask(BattleSystem.BattleSide battleSide) {
            RevealedPartyMembers = new bool[battleSide.Battlers.Length];
            RevealedHeldItems = new bool[battleSide.Battlers.Length];
        }

    }

}
