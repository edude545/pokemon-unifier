using Assets.Unifier.Game.Essentials;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Editor {

    public class BasicMap : MonoBehaviour {

        public static BasicMap Instance;

        public Tilemap[] Layers;

        public EssentialsMapAsset Map;

        private void Awake() {
            Instance = this;
        }

        public bool GetPointCollision(Vector2 point) {
            foreach (Tilemap tm in Layers) {
                if (tm.gameObject.TryGetComponent(out Collider2D c) && c.isActiveAndEnabled) {
                    Debug.Log(c.ClosestPoint(point));
                    if (c.ClosestPoint(point) == point) {
                        Debug.Log(tm.name);
                        return true;
                    }
                }
            }
            return false;
        }

        public void Clear() {
            foreach (Tilemap tm in Layers) {
                tm.ClearAllTiles();
            }
        }

    }

}