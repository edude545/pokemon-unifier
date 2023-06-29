using Assets.Unifier.Game.Editor;
using System;
using UnityEngine;
using static CharacterAnimator;

public class OverworldCharacterGrid : MonoBehaviour {

    public Vector3 GridPosition;
    public CharacterAnimator Animator;

    private Directions faceDirection = Directions.Down;
    public Directions FaceDirection { get { return faceDirection; }
        set {
            faceDirection = value;
            Animator.SetFace(faceDirection);
            switch (faceDirection) {
                case Directions.Up: moveDirVec = Vector3.up; break;
                case Directions.Down: moveDirVec = Vector3.down; break;
                case Directions.Left: moveDirVec = Vector3.left; break;
                case Directions.Right: moveDirVec = Vector3.right; break;
            }
        }
    }
    protected Vector3 moveDirVec;
    protected Directions? storedDirection;

    private MoveSpeeds moveSpeed = MoveSpeeds.Standing;
    public MoveSpeeds MoveSpeed { get { return moveSpeed; } set { moveSpeed = value; Animator.SetMoveSpeed(MoveSpeed); } }
    public bool Moving {
        set {
            if (value) { throw new ArgumentOutOfRangeException(nameof(value), "Moving can only be set to false; try setting MoveSpeed instead"); }
            else MoveSpeed = MoveSpeeds.Standing;
        }
        get { return MoveSpeed != MoveSpeeds.Standing; } }
    public float[] MoveSpeedMults = new float[3] { 4f, 6.5f, 9f };
    protected MoveSpeeds? storedSpeed;

    [HideInInspector] public float MoveProgress = 0f;
    protected bool stopMovingNextFrame = false;

    private void Awake() {
        GridPosition = transform.position;
    }

    private void Update() {
        if (Moving) {
            if (stopMovingNextFrame) {
                Moving = false;
                Animator.FreezeFrame(0);
            } else {
                if (storedSpeed != null) { MoveSpeed = (MoveSpeeds)storedSpeed; storedSpeed = null; }
                float delta = Time.deltaTime * MoveSpeedMults[(int)MoveSpeed - 1];
                transform.localPosition += moveDirVec * delta;
                MoveProgress += delta;
                if (MoveProgress >= 1f) {
                    stopMovingNextFrame = true;
                    GridPosition += moveDirVec;
                    transform.position = GridPosition;
                    MoveProgress = 0f;
                    if (storedDirection != null) { FaceDirection = (Directions)storedDirection; storedDirection = null; }
                }
            }
        }
    }

    public void Move(Directions dir, MoveSpeeds speed) {
        stopMovingNextFrame = false;
        if (Moving) { // continue movement
            storedSpeed = speed;
            storedDirection = dir;
        } else { // start moving
            FaceDirection = dir;
            if (!BasicMap.Instance.GetPointCollision(GridPosition + moveDirVec)) {
                MoveSpeed = speed;
                Animator.Play();
            }
        }
    }

}