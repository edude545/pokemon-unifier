using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

[CreateAssetMenu]
[System.Serializable]
public class EssentialsMapData : ScriptableObject
{

    public string Name; // name
    public int ID;

    [SerializeField] public EssentialsTable TileIDs; // data

    public string BackgroundMusicName; // bgm
    public bool AutoplayBackgroundMusic; // autoplay_bgm

    public string BackgroundSoundName; // bgs
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

    public int offset = 0;

    private void OnValidate() {
        Load();
    }

    public void Load(BasicMap map) {
        EssentialsTilemap etm = AssetDatabase.LoadAssetAtPath<EssentialsTilemap>("Assets/Insurgence/ImportedData/Tilesets/"+TilesetID.ToString()+".asset");
        map.MakeTilemaps(TileIDs.SizeX, TileIDs.SizeY, TileIDs.SizeZ);
        for (int z = 0; z < TileIDs.SizeZ; z++) {
            Tilemap tm = map.Layers[z];
            for (int y = 0; y < TileIDs.SizeY; y++) {
                for (int x = 0; x < TileIDs.SizeX; x++) {
                    tm.SetTile(new Vector3Int(x,y), etm.GetTile(TileIDs.Get(z,y,x)+offset));
                }
            }
        }
    }

    public void Load() {
        if (BasicMap.Instance != null) {
            Load(BasicMap.Instance);
        }
    }

}

[CustomEditor(typeof(EssentialsMapData))]
public class EssentialsMapDataEditor : Editor {

    EssentialsMapData md;

    public override void OnInspectorGUI() {
        using (var check = new EditorGUI.ChangeCheckScope()) {
            base.OnInspectorGUI();
            if (check.changed) {
                
            }
        }
        if (GUILayout.Button("Load map")) {
            md.Load();
        }
        if (GUILayout.Button("Serialize data to svalues")) {
            md.TileIDs.OnBeforeSerialize();
        }
        if (GUILayout.Button("Deserialize svalues to data")) {
            md.TileIDs.OnAfterDeserialize();
        }
    }

    private void OnEnable() {
        md = (EssentialsMapData)target;
    }

}
