using System;
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

    public string SpritesPath; // e.g. "Assets/Insurgence/Graphics/Characters/64px/trchar001"
    private Sprite[] activeSprites;
    private Sprite[] walkSprites;
    private Sprite[] runSprites;
    private Sprite[] bikeSprites;

    private int animationTick = 0;
    public float AnimationSpeed = 20f;
    private float timeSinceLastAnimationTick = 0f;
    private int animationPeriod = 4;

    public enum Directions {
        Down, // 0, 1, 2, 3
        Left, // 4, 5, 6, 7
        Right, // 8, 9, 10, 11
        Up, // 12, 13, 14, 15
    }
    public enum MoveSpeeds {
        Walking,
        Running,
        Biking
    }
    public float[] MoveSpeedMults = new float[3] { 4f, 6.5f, 9f };

    [HideInInspector] public bool Moving = false;
    public Directions FaceDirection = Directions.Down;
    Vector3 moveDirVec3;
    [HideInInspector] public MoveSpeeds MoveSpeed = MoveSpeeds.Walking;
    [HideInInspector] public float MoveProgress = 0f;

    private Sprite[] loadSprites(string path) {
        Sprite[] loaded = AssetDatabase.LoadAllAssetsAtPath(path + ".png").OfType<Sprite>().ToArray();
        if (loaded.Length == 0) { return null; }
        Sprite[] ret = new Sprite[animationPeriod * 4];
        foreach (var l in loaded) {
            ret[int.Parse(l.name)] = l;
        }
        return ret;
    }

    private void Update() {
        if (MoveSpeed == MoveSpeeds.Running && runSprites != null) {
            activeSprites = runSprites;
        } else if (MoveSpeed == MoveSpeeds.Biking && bikeSprites != null) {
            activeSprites = bikeSprites;
        } else {
            activeSprites = walkSprites;
        }
        if (Moving) {
            float delta = Time.deltaTime * MoveSpeedMults[(int)MoveSpeed];
            transform.localPosition += moveDirVec3 * delta;
            MoveProgress += delta;
            UpdateSprite();
            if (MoveProgress >= 1f) {
                Moving = false;
                GridPosition += moveDirVec3;
                transform.localPosition = GridPosition;
                MoveProgress = 0f;
            }
        }
    }

    public void Face(Directions dir) {
        FaceDirection = dir;
        setSprite((int)FaceDirection * animationPeriod);
    }

    public void Move() {
        if (!Moving) {
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
        Move();
    }

    private void setSprite(int index) {
        Sprite.sprite = activeSprites[index];
    }

    public void LoadSprites() {
        walkSprites = loadSprites(SpritesPath);
        runSprites = loadSprites(SpritesPath + "_run");
        bikeSprites = loadSprites(SpritesPath + "_bike");
        activeSprites = walkSprites;
        UpdateSprite();
    }

    public void UpdateSprite() {
        if (Moving) {
            timeSinceLastAnimationTick += Time.deltaTime;
            if (timeSinceLastAnimationTick >= AnimationSpeed) {
                timeSinceLastAnimationTick = 0f;
                animationTick++;
                if (animationTick == animationPeriod) {
                    animationTick = 0;
                }
                setSprite((int) FaceDirection * animationPeriod + animationTick);
            }
        } else {
            setSprite((int) FaceDirection * animationPeriod);
        }
    }

}

[CustomEditor(typeof(OverworldCharacter))]
public class OverworldCharacterEditor : Editor {

    OverworldCharacter character;

    public override void OnInspectorGUI() {
        using (var check = new EditorGUI.ChangeCheckScope()) {
            base.OnInspectorGUI();
            if (check.changed) {
                character.UpdateSprite();
            }
        }
        if (GUILayout.Button("Load sprites")) {
            character.LoadSprites();
        }
    }

    private void OnEnable() {
        character = (OverworldCharacter) target;
    }

}
