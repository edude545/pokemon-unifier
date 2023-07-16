using Assets.Unifier.Game.UI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game.Essentials {

    internal class EssentialsEvent : MonoBehaviour {

        private Event ev;

        public void Interact() {

        }

        private void executeEvent() {
            foreach (Page page in ev.pages) {
                foreach (EventCommand cmd in page.list) {
                    executeEventCommand(cmd);
                }
            }
        }

        private void executeEventCommand(EventCommand cmd) {
            switch (cmd.c) {
                case 101: // Show Text
                    UISystem.ShowDialog((string)cmd.p[0]);
                    break;
                case 102: // Show Choices
                    break;
                case 106: // Wait
                    break;
                case 111: // Conditional Branch
                    break;
                case 121: // Control Switches
                    break;
                case 123: // Control Self Switch
                    break;
                case 201: // Transfer Player
                    break;
                case 223: // Change Screen Color Tone
                    break;
                case 250: // Play SE (sound effect?)
                    break;
                case 355: // Global command
                    break;
                case 402: // Choice flow control
                    break;
                default:
                    break;
            }
        }

    }

}
