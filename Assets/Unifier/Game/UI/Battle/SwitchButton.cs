using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI.Battle {

    internal class SwitchButton : MonoBehaviour {

        private Pokemon loadedPokemon;

        public Image Icon;

        protected void Start() {
            gameObject.SetActive(false);
        }

        public void Refresh(Pokemon pokemon) {
            if (loadedPokemon == pokemon) return;
            if (pokemon == null) {
                gameObject.SetActive(false);
            } else {
                gameObject.SetActive(true);
                loadedPokemon = pokemon;
                Sprite[] icon = UnifierResources.LoadIcon(pokemon);
                if (icon.Length == 0) {
                    Icon.sprite = null;
                } else {
                    Icon.sprite = icon[0];
                }
            }
        }

    }

}
