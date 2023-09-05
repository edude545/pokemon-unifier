using Assets.Unifier.Engine;
using Assets.Unifier.Game;
using UnityEngine;
using static CharacterAnimator;

namespace Assets.Unifier.Game {

    [RequireComponent(typeof(TrainerCharacter))]
    internal class PlayerControl : MonoBehaviour {

        public static PlayerControl Instance;

        Button down = new Button(KeyCode.S, KeyCode.DownArrow);
        Button left = new Button(KeyCode.A, KeyCode.LeftArrow);
        Button right = new Button(KeyCode.D, KeyCode.RightArrow);
        Button up = new Button(KeyCode.W, KeyCode.UpArrow);
        Button run = new Button(KeyCode.LeftShift, KeyCode.X);
        Button[] buttons;

        public TrainerCharacter Character;

        public float TimeHeldBeforeMove = 0.18f;

        public bool JustCollided = false;

        private void Awake() {
            Instance = this;
            buttons = new Button[] { down, left, right, up, run };
        }

        private void Start() {
            Character = GetComponent<TrainerCharacter>();
            Character.Trainer.Name = "Player";
            Character.Animator.Stop();
            //character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Magnezone"), 48));
            //character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Delphox"), 58));
            //character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Absol"), 72));
        }

        private void Update() {
            foreach (Button b in buttons) b.Update();

            Vector3 mv = Vector3.zero;
            bool moveButtonHeld = false;
            if (down.Held) { mv += Vector3.down; moveButtonHeld = true; } else if (up.Held) { mv += Vector3.up; moveButtonHeld = true; }
            if (left.Held) { mv += Vector3.left; moveButtonHeld = true; } else if (right.Held) { mv += Vector3.right; moveButtonHeld = true; }
            if (moveButtonHeld) { Character.SetVelocity(mv.normalized, run.Held ? MoveSpeeds.Running : MoveSpeeds.Walking); } else { Character.StopMoving(); }

            /*MoveSpeeds ms = Input.GetKey(KeyCode.LeftShift) ? MoveSpeeds.Running : MoveSpeeds.Walking;
            if (down.Held) { Character.DoGridMove(Directions.Down, ms); } else if (up.Held) { Character.DoGridMove(Directions.Up, ms); }
            if (left.Held) { Character.DoGridMove(Directions.Left, ms); } else if (right.Held) { Character.DoGridMove(Directions.Right, ms); }*/

            if (Input.GetKeyDown(KeyCode.Space)) Character.InteractionProbe.Interact();

            if (Input.GetKeyDown(KeyCode.Alpha1)) Character.TryThrowOrWithdraw(0);
            if (Input.GetKeyDown(KeyCode.Alpha2)) Character.TryThrowOrWithdraw(1);
            if (Input.GetKeyDown(KeyCode.Alpha3)) Character.TryThrowOrWithdraw(2);
            if (Input.GetKeyDown(KeyCode.Alpha4)) Character.TryThrowOrWithdraw(3);
            if (Input.GetKeyDown(KeyCode.Alpha5)) Character.TryThrowOrWithdraw(4);
            if (Input.GetKeyDown(KeyCode.Alpha6)) Character.TryThrowOrWithdraw(5);
        }

        /*private void attemptGridMove(Directions direc) {
            if (direc == character.FaceDirection) {
                character.Move(direc, getMoveSpeed());
            } else {
                if (run.Held || btn.TimeHeld > TimeHeldBeforeMove) {
                    character.Move(direc, getMoveSpeed());
                } else if (!character.Moving) {
                    character.FaceDirection = direc;
                }
            }
        }*/

        private MoveSpeeds getMoveSpeed() {
            return run.Held ? MoveSpeeds.Running : MoveSpeeds.Walking;
        }

    }

    class Button {

        public bool Pressed;
        public bool Held;
        public bool Released;
        public float TimeHeld {
            get { return Held ? (Time.time - pressedTime) : 0f; }
        }

        private KeyCode[] keycodes;
        private float pressedTime;

        public Button(params KeyCode[] ks) {
            keycodes = ks;
        }

        public void Update() {
            Pressed = isPressed();
            Held = isHeld();
            Released = isReleased();
            if (Pressed) {
                pressedTime = Time.time;
            }
        }

        private bool isPressed() {
            foreach (KeyCode k in keycodes) {
                if (Input.GetKeyDown(k)) {
                    return true;
                }
            }
            return false;
        }

        private bool isHeld() {
            foreach (KeyCode k in keycodes) {
                if (Input.GetKey(k)) {
                    return true;
                }
            }
            return false;
        }

        private bool isReleased() {
            foreach (KeyCode k in keycodes) {
                if (Input.GetKeyUp(k)) {
                    return true;
                }
            }
            return false;
        }

    }

}