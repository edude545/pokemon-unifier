using Unity.VisualScripting;
using UnityEngine;
using static CharacterAnimator;

namespace Assets.Unifier.Game {

    internal class OverworldCharacter : MonoBehaviour {

        public CharacterAnimator Animator;
        public InteractionProbe InteractionProbe;

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
            MoveSpeed = MoveSpeeds.Standing;
        }

        // For grid movement
        /*float moveProgress;
        public float GridMoveMult = 1f;
        Vector3 destination;
        private bool movementQueued;
        protected void FixedUpdate() {
            if (Moving) {
                moveProgress += rb.velocity.magnitude * Time.deltaTime;
                if (moveProgress > 1f) {
                    transform.position = destination;
                    StopMoving();
                }
            }
        }
        public virtual void DoGridMove(Directions dir, MoveSpeeds ms) {
            if (Moving) { return; }
            //MoveSpeed = ms;
            //Moving = true;
            Animator.Play();
            //Animator.SetFace(dir);
            moveProgress = 0f;
            Vector3 vel = GetDirectionVector(dir);
            //InteractionProbe.transform.localPosition = vel;
            destination = transform.position + vel;
            //rb.velocity = vel * MoveSpeedMults[(int)moveSpeed - 1] * GridMoveMult;
            SetVelocity(vel, ms);
        }*/

        // For free movement
        public virtual void SetVelocity(Vector3 vec, MoveSpeeds ms) {
            MoveSpeed = ms;
            rb.velocity = vec * MoveSpeedMults[(int)moveSpeed-1];
            if (!Moving) Animator.Play(); // begin animation if it wasn't playing last frame
            Moving = true;
            InteractionProbe.transform.localPosition = vec.normalized;
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
