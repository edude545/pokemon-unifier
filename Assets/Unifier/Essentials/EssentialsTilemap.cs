using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

[CreateAssetMenu]
public class EssentialsTilemap : ScriptableObject
{

    public string DisplayName;
    public string TilesetsDirectoryPath = "Assets/Insurgence/Graphics/Tilesets";
    public string TilesetName; // e.g. "Game Corner interior"
    [NonSerialized] private string path;
    public int ID;

    public string AutotileNames;
    public string BattlebackName;

    public int FogBlendType;
    public int FogHue;
    public string FogName;
    public int FogOpacity;
    public int FogSX;
    public int FogSY;
    public int FogZoom;

    public int PanoramaHue;
    public string PanoramaName;

    public int[] PassageData;
    public int[] PriorityData;
    public int[] TerrainTags;

    private void OnValidate() {
        path = TilesetsDirectoryPath + "/" + TilesetName + "/" + TilesetName;
    }

    // Example lookup path: "Assets/Insurgence/Graphics/Tilesets/Game Corner interior/Game Corner interior_0.asset"
    public TileBase GetTile(int i) {
        return AssetDatabase.LoadAssetAtPath<Tile>(path + "_" + i.ToString() + ".asset");
    }

}
