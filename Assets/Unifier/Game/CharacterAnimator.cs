using Assets.Unifier.Game;
using Assets.Unifier.Game.Data;
using UnityEngine;

public class CharacterAnimator : SpriteAnimator {

    public int AnimationPeriod = 4;

    public enum Directions {
        Down, // 0, 1, 2, 3
        Left, // 4, 5, 6, 7
        Right, // 8, 9, 10, 11
        Up, // 12, 13, 14, 15
    }

    public enum MoveSpeeds {
        Standing,
        Walking,
        Running,
        Biking
    }

    private static int[][] walkAnimations = {
        new int[4] { 0, 1, 2, 3 },
        new int[4] { 4, 5, 6, 7 },
        new int[4] { 8, 9, 10, 11 },
        new int[4] { 12, 13, 14, 15 }
    };

    private Sprite[] walkSprites;
    private Sprite[] runSprites;
    private Sprite[] bikeSprites;

    public override void LoadSprites() {
        //AssetBundle bundle = BundleLoader.Instance.AssetBundles[BundleName];
        walkSprites = BundleLoader.LoadAssetWithSubAssets<Sprite>("overworld_characters", SpritesheetName);
        runSprites = BundleLoader.LoadAssetWithSubAssets<Sprite>("overworld_characters", SpritesheetName + "_run");
        bikeSprites = BundleLoader.LoadAssetWithSubAssets<Sprite>("overworld_characters", SpritesheetName + "_bike");
        if (walkSprites.Length != AnimationPeriod * AnimationPeriod) throw new NoDataException("Couldn't find a spritesheet with "+AnimationPeriod*AnimationPeriod+" sprites with filename "+SpritesheetName+"!");
        if (runSprites.Length == 0) runSprites = null;
        if (bikeSprites.Length == 0) bikeSprites = null;
        LoadAnimation(walkAnimations[0]);
        setSpritesheetWithoutUpdating(walkSprites);
        if (Application.isEditor && !Application.isPlaying) {
            UpdateSprite();
        }
    }

    public void SetFace(Directions dir) {
        LoadAnimation(walkAnimations[(int)dir]);
    }

    public void SetMoveSpeed(MoveSpeeds moveSpeed) {
        if (moveSpeed == MoveSpeeds.Running && runSprites != null) {
            SwitchSpritesheet(runSprites);
        } else if (moveSpeed == MoveSpeeds.Biking && bikeSprites != null) {
            SwitchSpritesheet(bikeSprites);
        } else {
            SwitchSpritesheet(walkSprites);
        }
    }

}