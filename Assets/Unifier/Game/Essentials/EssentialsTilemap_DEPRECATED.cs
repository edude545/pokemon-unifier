using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Essentials {

    [CreateAssetMenu]
    public class EssentialsTilemap_DEPRECATED : ScriptableObject {

        public string DisplayName;

        //public string TilesetsPath = "Graphics/Tilesets";
        public string TilesetName; // e.g. "Game Corner interior"
        [NonSerialized] private string path;
        public int ID;

        public string[] AutotileNames;
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

        private Dictionary<int, Tile> dict;

        // Each autotile has 48 unique numbers. The main tilemap is treated as the 8th autotile, so it starts at offset 384 (48 * 8).
        private static readonly int TILEMAP_OFFSET_SIZE = 48;
        private static readonly int SPRITESHEET_COLUMN_HEIGHT_IN_TILES = 512;
        private static readonly int SPRITESHEET_COLUMN_WIDTH_IN_TILES = 8;
        private static readonly int TILE_WIDTH = 32;

        // Example lookup path: "Assets/Insurgence/Graphics/Tilesets/Game Corner interior/Game Corner interior_0.asset"
        // Should never be called with i=0, as this represents an empty tile.
        public TileBase GetTile(int i) {
            if (i >= TILEMAP_OFFSET_SIZE * 8) { // Main tilemap offset (384)
                i -= TILEMAP_OFFSET_SIZE * 8;
                if (dict.ContainsKey(i)) {
                    return dict[i];
                } else {
                    Debug.Log("Missing tile " + i + " on tilemap " + TilesetName);
                    return null;
                }
            } else {
                return null;
            }
        }

        public void GenerateTilesFromSpritesheet() {
            Sprite[] spritesheet = BundleLoader_DEPRECATED.LoadAssetWithSubAssets<Sprite>("overworld_tilesets", TilesetName);
            int index;
            int i;
            dict = new Dictionary<int, Tile>();
            for (i = 0; i < spritesheet.Length; i++) {
                index = spriteToTilemapIndex(spritesheet[i]);
                Tile tile = (Tile)CreateInstance("Tile");
                tile.name = index.ToString();
                tile.colliderType = Tile.ColliderType.Grid;
                tile.sprite = spritesheet[i];
                dict[index] = tile;
            }
            Debug.Log("Generated " + spritesheet.Length + " tiles from " + TilesetName + ".png");
        }

        // Using a sprite from a texture atlas, returns the ID that refers to that sprite in the map data. Does not add the offset (384).
        // Unity can't handle images with a dimension over 16384px, so the big tilesets (e.g. 256x31104) are collapsed into smaller ones (512x16384).
        // Unity's sprite editor coordinates start at the bottom left, RPGMaker starts indexing tiles from the top left.
        // The height of the texture is read to make this compatible with images that are less than 16384 pixels tall.
        private static int spriteToTilemapIndex(Sprite sprite) {
            int xtile = ((int)sprite.rect.xMin) / TILE_WIDTH;
            int ytile = (sprite.texture.height - (int)sprite.rect.yMax) / TILE_WIDTH;
            int colIndex = xtile / SPRITESHEET_COLUMN_WIDTH_IN_TILES;
            xtile %= SPRITESHEET_COLUMN_WIDTH_IN_TILES;
            int index = ytile * SPRITESHEET_COLUMN_WIDTH_IN_TILES + xtile + SPRITESHEET_COLUMN_HEIGHT_IN_TILES * colIndex;
            //Debug.Log(xtile+"("+sprite.rect.xMin+") from left, "+ytile+"("+ (sprite.texture.height - (int)sprite.rect.yMax) + ") from top => index "+index+" (column "+colIndex+")");
            return index;
        }

        /*public void GenerateDictionary() {
            Tile[] tiles = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(this).Replace(".asset", "/")).OfType<Tile>().ToArray();
            Debug.Log(AssetDatabase.GetAssetPath(this).Replace(".asset", "/"));
            dict = new Dictionary<int, Tile>();
            string a = " ";
            foreach (Tile tile in tiles) {
                dict[int.Parse(tile.name)] = tile;
                a += " " + tile.name;
            }
            Debug.Log(a);
        }*/

    }

}