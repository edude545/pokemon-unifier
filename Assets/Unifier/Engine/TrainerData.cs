using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assets.Unifier.Engine {

    internal class TrainerData {

        public string Name;

        Pokemon[] party = new Pokemon[6];

        public int PartyMax { get { return party.Length; } }

        public Pokemon GetPartyMember(int index) {
            return party[index];
        }

        // Adds Pokemon to first empty slot; returns true if successful
        public bool AddPartyMember(Pokemon pokemon) {
            for (int i = 0; i < party.Length; i++) {
                if (party[i] == null) {
                    party[i] = pokemon;
                    return true;
                }
            }
            return false;
        }

    }

}
