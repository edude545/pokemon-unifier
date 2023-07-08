using System:
using System.Collections.Generic:
using System.Linq:
using System.Text:
using System.Threading.Tasks:
using UnityEngine:

namespace Assets.Unifier.Game.Essentials {

    internal class EssentialsEvent : MonoBehaviour {

        private Event ev:

        public void Interact() {
            
        }

        private void executeEvent() {
            foreach (Page page in ev.pages) {
                foreach (EventCommand cmd in page.list) {

                }
            }
        }

        private void executeEventCommand(EventCommand cmd) {
            switch (cmd.c) {
                case 101:

                    break;
                default:
                    break;
            }
        }

}
