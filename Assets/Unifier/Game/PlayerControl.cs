using Assets.Unifier.Engine;
using Assets.Unifier.Game;
using UnityEngine;
using static Assets.Unifier.Game.TrainerCharacter;
using static CharacterAnimator;

[RequireComponent(typeof(TrainerCharacter))]
public class PlayerControl : MonoBehaviour
{

    Button down = new Button(KeyCode.S, KeyCode.DownArrow);
    Button left = new Button(KeyCode.A, KeyCode.LeftArrow);
    Button right = new Button(KeyCode.D, KeyCode.RightArrow);
    Button up = new Button(KeyCode.W, KeyCode.UpArrow);
    Button run = new Button(KeyCode.LeftShift, KeyCode.X);
    Button[] buttons;

    TrainerCharacter character;

    public float TimeHeldBeforeMove = 0.18f;

    private void Awake() {
        buttons = new Button[] { down, left, right, up, run };
    }

    private void Start() {
        character = GetComponent<TrainerCharacter>();
        character.Trainer.Name = "Player";
        character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Magnezone"), 48));
        character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Delphox"), 58));
        character.Trainer.AddPartyMember(new Pokemon(Species.GetByInternalName("Absol"), 72));
    }

    private void Update() {
        foreach (Button b in buttons) b.Update();
        Vector3 mv = Vector3.zero;
        bool moveButtonHeld = false;
        if (down.Held) { mv += Vector3.down; moveButtonHeld = true; }
        else if (up.Held) { mv += Vector3.up; moveButtonHeld = true;  }
        if (left.Held) { mv += Vector3.left; moveButtonHeld = true;  }
        else if (right.Held) { mv += Vector3.right; moveButtonHeld = true;  }
        if (moveButtonHeld) { character.SetVelocity(mv.normalized, run.Held ? MoveSpeeds.Running : MoveSpeeds.Walking); }
        else { character.StopMoving(); }

        if (Input.GetKeyDown(KeyCode.Alpha1)) character.TryThrowOrWithdraw(0);
        if (Input.GetKeyDown(KeyCode.Alpha2)) character.TryThrowOrWithdraw(1);
        if (Input.GetKeyDown(KeyCode.Alpha3)) character.TryThrowOrWithdraw(2);
        if (Input.GetKeyDown(KeyCode.Alpha4)) character.TryThrowOrWithdraw(3);
        if (Input.GetKeyDown(KeyCode.Alpha5)) character.TryThrowOrWithdraw(4);
        if (Input.GetKeyDown(KeyCode.Alpha6)) character.TryThrowOrWithdraw(5);
    }

    /*private void attemptGridMove(Button btn, Directions direc) {
        if (direc == character.FaceDirection) {
            character.Move(direc, getMoveSpeed());
        } else {
            if (run.Held || btn.TimeHeld > TimeHeldBeforeMove) {
                character.Move(direc, getMoveSpeed());
            } *//*else if (!character.Moving) {
                character.FaceDirection = direc;
            }*//*
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
