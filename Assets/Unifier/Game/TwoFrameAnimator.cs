using Assets.Unifier;
using Assets.Unifier.Game;
using Assets.Unifier.Game.Data;
using UnityEditor;
using UnityEngine;

public class TwoFrameAnimator : SpriteAnimator {

    private static int[] twoFrameAnimation = { 0, 1 };

    public override void LoadSprites() {
        SwitchSpritesheet(BundleLoader.LoadAssetWithSubAssets<Sprite>("overworld_characters", SpritesheetName));
        LoadAnimation(twoFrameAnimation);
        Play();
    }
}