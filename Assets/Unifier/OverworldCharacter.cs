using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class OverworldCharacter : MonoBehaviour
{

    public Vector3 GridPosition;
    public SpriteRenderer Sprite;

    public string SpritesheetPath;
    private Sprite[] sprites;
    private int animationTick = 0;
    public float AnimationSpeed = 20f;
    private float timeSinceLastAnimationTick = 0f;
    private int animationPeriod = 4;

    public enum Directions {
        Down, // 0, 1, 2, 3
        Left, // 4, 5, 6, 7
        Right, // 8, 9, 10, 11
        Up, // 12, 13, 14, 15
        None // 0, 4, 8, 12
    }
    [HideInInspector] public bool Moving = false;
    [HideInInspector] public Directions FaceDirection = Directions.Down;
    Vector3 moveDirVec3;
    [HideInInspector] public bool Running;
    [HideInInspector] public float MoveProgress = 0f;
    public float WalkSpeed;
    public float RunSpeed;

    private void Start() {
        sprites = AssetDatabase.LoadAllAssetsAtPath(SpritesheetPath).OfType<Sprite>().ToArray();
    }

    private void Update() {
        if (Moving) {
            float delta = Time.deltaTime * (Running ? RunSpeed : WalkSpeed);
            transform.localPosition += moveDirVec3 * delta;
            MoveProgress += delta;
            if (MoveProgress >= 1f) {
                setSprite((int)FaceDirection * animationPeriod);
                animationTick = 0;
                Moving = false;
                GridPosition += moveDirVec3;
                transform.localPosition = GridPosition;
                MoveProgress = 0f;
            } else {
                timeSinceLastAnimationTick += Time.deltaTime;
                if (timeSinceLastAnimationTick >= AnimationSpeed) {
                    timeSinceLastAnimationTick = 0f;
                    animationTick++;
                    if (animationTick == animationPeriod) {
                        animationTick = 0;
                    }
                    setSprite((int)FaceDirection * animationPeriod + animationTick);
                }
            }
        }
    }

    public void Face(Directions dir) {
        FaceDirection = dir;
        setSprite((int)FaceDirection * animationPeriod);
    }

    public void Move() {
        if (!Moving) {
            animationTick = 0;
            timeSinceLastAnimationTick = 0f;
            Moving = true;
            switch (FaceDirection) {
                case Directions.Up: moveDirVec3 = Vector3.up; break;
                case Directions.Down: moveDirVec3 = Vector3.down; break;
                case Directions.Left: moveDirVec3 = Vector3.left; break;
                case Directions.Right: moveDirVec3 = Vector3.right; break;
            }
        }
    }

    public void Move(Directions dir) {
        Face(dir);
    }

    private void setSprite(int index) {
        Sprite.sprite = sprites[index];
    }

}
