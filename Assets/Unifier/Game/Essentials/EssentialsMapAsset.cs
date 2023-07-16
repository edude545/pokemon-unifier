using Assets.Unifier.Game.Editor;
using System.Collections.Generic;
using System.Dynamic;
using Unity.VisualScripting;
using UnityEditor.PackageManager;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Essentials {

    public class EssentialsMapAsset : ScriptableObject {

        public EssentialsModule Module;
        public MapData Data;
        public MapInfo Info;

        private int[,,] generateTileData() {
            Table table = Data.data;
            int[,,] tileData = new int[table.z,table.y,table.x];
            int x, y = 0, z = 0;
            foreach (string line in table.data) {
                x = 0;
                foreach (string hex in line.Split(" ")) {
                    tileData[z,y,x] = int.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                    x++;
                }
                y++;
                if (y > table.y - 1) {
                    y = 0;
                    z++;
                }
            }
            return tileData;
        }

        public void Load(BasicMap map) {
            int[,,] tiledata = generateTileData();
            EssentialsTilesetAsset eta = EssentialsTilesetAsset.FindAndLoad(Module.ModuleName, Data.tileset_id);
            //EssentialsTilemap_DEPRECATED etm = BundleLoader.LoadAsset<EssentialsTilemap_DEPRECATED>("essentials_tilemaps_insurgence", TilesetID.ToString());
            int tileID;
            map.Clear();
            for (int z = 0; z < tiledata.GetLength(0); z++) {
                Tilemap tm = map.Layers[z];
                for (int y = 0; y < tiledata.GetLength(1); y++) {
                    for (int x = 0; x < tiledata.GetLength(2); x++) {
                        tileID = tiledata[z, y, x];
                        if (tileID != 0) {
                            tm.SetTile(new Vector3Int(x, -y), eta.GetTile(tileID));
                        }
                    }
                }
            }
        }
    }

    [System.Serializable]
    public struct MapInfo {
        public bool expanded;
        public string name;
        public int order;
        public int parent_id;
        public int scroll_x;
        public int scroll_y;
    }

    [System.Serializable]
    public struct MapData {
        // Automatically deserialized fields
        public bool autoplay_bgm;
        public bool autoplay_bgs;
        public AudioFile bgm;
        public AudioFile bgs;
        public Table data;
        public object[] encounter_list; // not sure what type this should be, haven't found a map whose encounter_list is not empty
        public int encounter_step;
        public int height;
        public int tileset_id;
        public int width;

        // These fields require extra code to deserialize
        public Event[] event_list;
    }

    [System.Serializable]
    public struct AudioFile {
        public string name;
        public int pitch;
        public int volume;
    }

    [System.Serializable]
    public struct Table {
        public int dim;
        public int x;
        public int y;
        public int z;
        public string[] data;
    }

    [System.Serializable]
    public struct Event {
        public int id;
        public string name;
        public Page[] pages;
        public int x;
        public int y;
    }

    [System.Serializable]
    public struct Page {
        public bool always_on_top;
        public Condition condition;
        public bool direction_fix;
        public Graphic graphic;
        public EventCommand[] list;
        public int move_frequency;
        public MoveRoute move_route;
        public int move_speed;
        public int move_type;
        public bool step_anime;
        public bool through;
        public int trigger;
        public bool walk_anime;
    }

    [System.Serializable]
    public struct Condition {
        public char self_switch_ch;
        public bool self_switch_valid;
        public int switch1_id;
        public bool switch1_valid;
        public int switch2_id;
        public bool switch2_valid;
        public int variable_id;
        public bool variable_valid;
        public int variable_value;
    }

    [System.Serializable]
    public struct Graphic {
        public int blend_type;
        public int character_hue;
        public string character_name;
        public int direction;
        public int opacity;
        public int pattern;
        public int tile_id;
    }

    [System.Serializable]
    public struct EventCommand {
        public int i;
        public int c;
        public object[] p;
    }

    [System.Serializable]
    public struct Tone {
        public float a;
        public float b;
        public float g;
        public float r;
    }

    [System.Serializable]
    public struct MoveRoute {
        public MoveCommand[] list;
        public bool repeat;
        public bool skippable;
    }

    [System.Serializable]
    public struct MoveCommand {
        public int code;
        public object[] parameters;
    }

}
