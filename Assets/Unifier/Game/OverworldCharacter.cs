using UnityEngine;
using static CharacterAnimator;

namespace Assets.Unifier.Game {

    internal class OverworldCharacter : MonoBehaviour {

        public CharacterAnimator Animator;

        public bool Moving;

        private MoveSpeeds moveSpeed = MoveSpeeds.Standing;
        public MoveSpeeds MoveSpeed { get { return moveSpeed; } set { moveSpeed = value; Animator.SetMoveSpeed(MoveSpeed); } }
        public float[] MoveSpeedMults = new float[3] { 4f, 6.5f, 9f };

        private Rigidbody2D rb;

        protected virtual void Start() {
            rb = GetComponent<Rigidbody2D>();
        }

        public void StopMoving() {
            rb.velocity = Vector3.zero;
            Moving = false;
            Animator.Stop();
            moveSpeed = MoveSpeeds.Standing;
            Animator.FreezeFrame(0);
        }

        public void SetVelocity(Vector3 vec, MoveSpeeds ms) {
            MoveSpeed = ms;
            rb.velocity = vec * MoveSpeedMults[(int)moveSpeed-1];
            if (!Moving) Animator.Play(); // begin animation if it wasn't playing last frame
            Moving = true;
            if (vec.x > 0) {
                Animator.SetFace(Directions.Right);
            } else if (vec.x < 0) {
                Animator.SetFace(Directions.Left);
            } else if (vec.y > 0) {
                Animator.SetFace(Directions.Up);
            } else if (vec.y < 0) {
                Animator.SetFace(Directions.Down);
            }
        }

    }

}
