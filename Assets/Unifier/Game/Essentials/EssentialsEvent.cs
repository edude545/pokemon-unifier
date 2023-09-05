using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Editor;
using UnityEditor.Events;
using UnityEngine;
using UnityEngine.Events;

namespace Assets.Unifier.Game.Essentials {

    internal class EssentialsEvent : MonoBehaviour {

        public Event EventData;

        public static bool JustTransported = false;
        public static EssentialsEvent LastEventTriggered = null;

        public void LoadData(Transform parent, Event _ev) {
            EventData = _ev;
            ((RectTransform)transform).sizeDelta = new Vector2(1,1);
            transform.position = new Vector3(EventData.x+0.5f, -EventData.y+0.5f, 0f);
            transform.SetParent(parent, false);
            gameObject.name = EventData.id + " " + EventData.name;

            if (_ev.pages.Length == 0) { return; }
            Page page = _ev.pages[0];

            if (!string.IsNullOrEmpty(page.graphic.character_name)) {
                GameObject spriteObj = new GameObject("Sprite");
                spriteObj.transform.SetParent(transform);
                spriteObj.transform.localPosition = new Vector3(0f, 0.75f, 0f);
                SpriteRenderer sr = spriteObj.AddComponent<SpriteRenderer>();
                Sprite[] sprites = UnifierResources.LoadOverworldWalkCycle("Insurgence", page.graphic.character_name);
                if (sprites.Length != 0) {
                    sr.sprite = sprites[0];
                }
            }

            if (page.trigger == 0) { // Interact
                BoxCollider2D collider = gameObject.AddComponent<BoxCollider2D>();
                Interactable interactable = gameObject.AddComponent<Interactable>();
                interactable.InteractEvent = new UnityEvent();
                UnityEventTools.AddPersistentListener(interactable.InteractEvent, RunEvent);
            }
            if (page.trigger == 1) { // Collide
                BoxCollider2D collider = gameObject.AddComponent<BoxCollider2D>();
                collider.isTrigger = true;
            }
            if (page.trigger == 2) {

            }
            if (page.trigger == 3) {

            }

        }

        public void RunEvent() {
            Debug.Log("Running event");
            foreach (EventCommand cmd in EventData.pages[0].list) {
                executeEventCommand(cmd);
            }
            LastEventTriggered = this;
        }

        protected void OnTriggerEnter2D(Collider2D collision) {
            PlayerControl player = collision.GetComponent<PlayerControl>();
            if (player != null) {
                if (!JustTransported) {
                    RunEvent();
                }
            }
        }

        protected void OnTriggerExit2D(Collider2D collision) {
            PlayerControl player = collision.GetComponent<PlayerControl>();
            if (player != null) {
                if (JustTransported) {
                    if (LastEventTriggered != this) {
                        JustTransported = false;
                    }
                }
            }
        }

        private static int safeguard = 0;

        private void executeEventCommand(EventCommand cmd) {
            switch (cmd.c) {
                case 101: // Show Text
                    Debug.Log(cmd.p[0]);
                    //UISystem.ShowDialog((string)cmd.p[0]);
                    break;
                case 102: // Show Choices
                    break;
                case 106: // Wait
                    break;
                case 111: // Conditional Branch
                    break;
                case 121: // Control Switches
                    break;
                case 123: // Control Self Switch
                    break;
                case 201: // Transfer Player
                    //int appointment_method = int.Parse(cmd.p[0]);
                    safeguard++;
                    if (safeguard > 4) {
                        Debug.LogWarning("Too many map transitions!");
                        return;
                    }
                    int new_map_number = int.Parse(cmd.p[1]);
                    int new_x = int.Parse(cmd.p[2]);
                    int new_y = int.Parse(cmd.p[3]);
                    int new_direction = int.Parse(cmd.p[4]);
                    //int fade = int.Parse(cmd.p[5]);
                    JustTransported = true;
                    BasicMap.Instance.LoadMapByID("Insurgence", new_map_number);
                    Vector3 relative = (transform.position - PlayerControl.Instance.transform.position) * 1.5f;
                    PlayerControl.Instance.transform.position = new Vector3(new_x + 0.5f + relative.x, -new_y + 0.5f + relative.y, 1f);
                    /*switch (new_direction) {
                        case 0: player.transform.position += Vector3.down; break;
                        case 1: break;
                        case 2: break;
                        case 3: break;
                        default: throw new System.Exception($"Unexpected value {new_direction} for argument new_direction");
                    }*/
                    break;
                case 223: // Change Screen Color Tone
                    break;
                case 250: // Play SE (sound effect?)
                    break;
                case 355: // Global command
                    break;
                case 402: // Choice flow control
                    break;
                default:
                    break;
            }
        }

    }

}
