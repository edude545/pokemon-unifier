using Assets.Unifier.Game;
using Assets.Unifier.Game.Data;
using System;
using Unity.VisualScripting;
using UnityEngine;

public class CharacterAnimator : SpriteAnimator {

    public int AnimationPeriod = 4;

    public string ModuleName;
    public string SpritesheetGraphicPath; // e.g. "Assets/Insurgence/Graphics/Characters/64px/trchar001"

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

    public Sprite[] WalkSprites;
    public Sprite[] RunSprites;
    public Sprite[] BikeSprites;

    public Directions Direction;

    protected override void Start() {
        LoadSpritesFromInspectorFields();
        base.Start();
    }

    public static Vector3 GetDirectionVector(Directions dir) {
        switch (dir) {
            case Directions.Up: return Vector3.up;
            case Directions.Down: return Vector3.down;
            case Directions.Left: return Vector3.left;
            case Directions.Right: return Vector3.right;
            default: throw new System.Exception();
        }
    }

    public virtual void LoadSpritesFromInspectorFields () {
        WalkSprites = Resources.LoadAll<Sprite>("Modules/" + ModuleName + "/Graphics/" + SpritesheetGraphicPath);
        RunSprites = Resources.LoadAll<Sprite>("Modules/" + ModuleName + "/Graphics/" + SpritesheetGraphicPath + "_run");
        BikeSprites = Resources.LoadAll<Sprite>("Modules/" + ModuleName + "/Graphics/" + SpritesheetGraphicPath + "_bike");
        if (WalkSprites.Length != AnimationPeriod * AnimationPeriod) throw new Exception("Couldn't find a spritesheet with " + AnimationPeriod * AnimationPeriod + " sprites with at Modules/" + ModuleName + "/Graphics/" + SpritesheetGraphicPath + "!");
        if (RunSprites.Length == 0) RunSprites = null;
        if (BikeSprites.Length == 0) BikeSprites = null;
        LoadSprites();
    }

    public override void LoadSprites() {
        LoadAnimation(walkAnimations[0]);
        setSpritesheetWithoutUpdating(WalkSprites);
        if (Application.isEditor && !Application.isPlaying) {
            UpdateSprite();
        }
    }

    public void SetFace(Directions dir) {
        Direction = dir;
        LoadAnimation(walkAnimations[(int)dir]);
    }

    public void SetMoveSpeed(MoveSpeeds moveSpeed) {
        if (moveSpeed == MoveSpeeds.Running && RunSprites != null) {
            SwitchSpritesheet(RunSprites);
        } else if (moveSpeed == MoveSpeeds.Biking && BikeSprites != null) {
            SwitchSpritesheet(BikeSprites);
        } else {
            SwitchSpritesheet(WalkSprites);
        }
    }

}