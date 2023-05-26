using UnityEngine;

[RequireComponent(typeof(OverworldCharacter))]
public class PlayerControl : MonoBehaviour
{

    Button down = new Button(KeyCode.S, KeyCode.DownArrow);
    Button left = new Button(KeyCode.A, KeyCode.LeftArrow);
    Button right = new Button(KeyCode.D, KeyCode.RightArrow);
    Button up = new Button(KeyCode.W, KeyCode.UpArrow);
    Button run = new Button(KeyCode.LeftShift, KeyCode.X);
    Button[] buttons;
    Button directionButton;

    OverworldCharacter.Directions targetDirection;

    OverworldCharacter character;

    public float TimeHeldBeforeMove = 0.18f;

    private void Awake() {
        buttons = new Button[] { down, left, right, up, run };
        directionButton = down;
    }

    private void Start() {
        character = GetComponent<OverworldCharacter>();
    }

    private void Update() {
        foreach (Button b in buttons) b.Update();

             if (down.Pressed)  { targetDirection = OverworldCharacter.Directions.Down;     directionButton = down;     }
        else if (left.Pressed)  { targetDirection = OverworldCharacter.Directions.Left;     directionButton = left;     }
        else if (right.Pressed) { targetDirection = OverworldCharacter.Directions.Right;    directionButton = right;    }
        else if (up.Pressed)    { targetDirection = OverworldCharacter.Directions.Up;       directionButton = up;       }

        character.Running = run.Held;

        if (directionButton.Held) {
            if (run.Held) {
                character.Move(targetDirection);
            } else if (targetDirection == character.FaceDirection) {
                character.Move();
            } else if (directionButton.TimeHeld > TimeHeldBeforeMove && !character.Moving) {
                character.Move(targetDirection);
            }
        } else if (directionButton.Released) {
            character.Face(targetDirection);
        }
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
