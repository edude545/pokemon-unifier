using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.UI.Battle;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Unifier.Game.UI {

    internal class BattlerDisplay : MonoBehaviour {

        private Pokemon loadedPokemon;

        public Image BaseSprite;
        public Image PokemonSprite;
        public bool UseBacksprite;
        public BattlerStatusBar StatusBar;

        public void Refresh(BattleSystem.Battler battler) {
            //StatusBar.Refresh(battler);
            if (loadedPokemon == battler.Pokemon) return;
            loadedPokemon = battler.Pokemon;
            PokemonSprite.sprite = UseBacksprite ? UnifierResources.LoadBattlerBacksprite(battler.Pokemon) : UnifierResources.LoadBattlerSprite(battler.Pokemon);
            RectTransform pokemonSpriteTransform = PokemonSprite.GetComponent<RectTransform>();
            PokemonSprite.SetNativeSize();
            pokemonSpriteTransform.sizeDelta *= UseBacksprite ? 64f : 48f;
        }

    }

}
