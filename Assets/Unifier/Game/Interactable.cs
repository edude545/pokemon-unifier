using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Events;

namespace Assets.Unifier.Game {

    [RequireComponent(typeof(Collider2D))]
    internal class Interactable : MonoBehaviour {

        public UnityEvent InteractEvent;

    }

}
