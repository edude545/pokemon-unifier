using Assets.Unifier;
using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Editor;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Essentials {

    [CreateAssetMenu]
    [System.Serializable]
    public class EssentialsMapData_DEPRECATED : ScriptableObject {

        public string Name; // name
        public int ID;

        [SerializeField] public EssentialsTable_DEPRECATED TileIDs; // data

        public string BackgroundMusicName; // bgm.name
        public int BackgroundMusicPitch; // bgm.pitch
        public int BackgroundMusicVolume; // bgm.volume
        public bool AutoplayBackgroundMusic; // autoplay_bgm

        public string BackgroundSoundName; // bgs
        public int BackgroundSoundPitch; // bgs.pitch
        public int BackgroundSoundVolume; // bgs.volume
        public bool AutoplayBackgroundSound; // autoplay_bgs

        // encounter_list - array  (haven't figured out what this is used for yet
        public int EncounterStep; // encounter_step
                                  //public Dictionary<int, EssentialsEvent> Events; // events
        public int TilesetID; // tileset_id
        public bool Expanded; // expanded
        public int Order; // order
        public int ParentID; // parent_id
        public int ScrollX; // scroll_x
        public int ScrollY; // scroll_y

        public void Load(BasicMap map) {
            TileIDs.OnAfterDeserialize();
            EssentialsTilemap_DEPRECATED etm = BundleLoader.LoadAsset<EssentialsTilemap_DEPRECATED>("essentials_tilemaps_insurgence", TilesetID.ToString());
            etm.GenerateTilesFromSpritesheet();
            int tileID;
            map.Clear();
            for (int z = 0; z < TileIDs.SizeZ; z++) {
                Tilemap tm = map.Layers[z];
                for (int y = 0; y < TileIDs.SizeY; y++) {
                    for (int x = 0; x < TileIDs.SizeX; x++) {
                        tileID = TileIDs.Get(z, y, x);
                        if (tileID != 0) {
                            tm.SetTile(new Vector3Int(x, -y), etm.GetTile(tileID));
                        }
                    }
                }
            }
        }

    }

}