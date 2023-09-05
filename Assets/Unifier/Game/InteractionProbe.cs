using Assets.Unifier.Game.Essentials;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game {

    internal class InteractionProbe : MonoBehaviour {

        private Interactable target;

        private void OnTriggerEnter2D(Collider2D collision) {
            Interactable i = collision.GetComponent<Interactable>();
            if (i != null) {
                target = i;
                Debug.Log($"Found interactable \"{i.name}\"");
            }
        }

        private void OnTriggerExit2D(Collider2D collision) {
            target = null;
            Interactable i = collision.GetComponent<Interactable>();
            if (i != null) {
                Debug.Log($"Lost interactable \"{i.name}\"");
            }
        }

        public void Interact() {
            Debug.Log($"Trying interact with {target?.name}");
            target?.InteractEvent.Invoke();
        }

    }

}
