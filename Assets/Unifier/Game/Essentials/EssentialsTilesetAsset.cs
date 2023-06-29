using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection.Emit;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Essentials {

    public class EssentialsTilesetAsset : ScriptableObject {

        // Serialized
        public EssentialsModule Module;
        public Tileset TilesetData;

        // Not serialized
        private Dictionary<int, Tile> dict;

        // Each autotile has 48 unique numbers. The main tilemap is treated as the 8th autotile, so it starts at offset 384 (48 * 8).
        private static readonly int TILEMAP_OFFSET_SIZE = 48;
        private static readonly int SPRITESHEET_COLUMN_HEIGHT_IN_TILES = 512;
        private static readonly int SPRITESHEET_COLUMN_WIDTH_IN_TILES = 8;
        private static readonly int TILE_WIDTH = 32;

        // Finds a tileset in the given module with the given name, loads all spritesheets and tiles used by it, then returns a reference to the tileset
        public static EssentialsTilesetAsset FindAndLoad(string moduleName, int id) {
            EssentialsTilesetAsset asset = Resources.Load<EssentialsTilesetAsset>("Modules/"+moduleName+"/Tilesets/"+id);
            asset.Load();
			return asset;
        }

        // Loads all spritesheets and tiles used by this asset into memory.
        public void Load() {
            dict = new Dictionary<int, Tile>();
            loadTiles();
            loadAutotiles();    
        }

        private void loadTiles() {
            string path = Module.ModulePath + "/Tilesets/" + TilesetData.id + "/Tiles";
            foreach (Tile tile in Resources.LoadAll<Tile>(path)) {
                dict[spriteToTilemapIndex(tile.sprite)] = tile;
            }
        }

        private void loadAutotiles() {
            /*for (int i = 0; i < AutotileAssetBundles.Length; i++) {
                if (AutotileAssetBundles[i] == null) continue;
                foreach (Tile tile in AutotileAssetBundles[i].LoadAllAssets<Tile>()) {
                    dict[i * 48 + int.Parse(tile.name)] = tile;
                }
            }*/
        }

        // Should never be called with i=0, as this represents an empty tile.
        public TileBase GetTile(int i) {
            if (i >= TILEMAP_OFFSET_SIZE * 8) { // Main tilemap offset (384)
                i -= TILEMAP_OFFSET_SIZE * 8;
                if (dict.ContainsKey(i)) {
                    return dict[i];
                } else {
                    Debug.Log("Missing tile " + i + " on tilemap " + TilesetData.id + " (" + TilesetData.name + ")");
                    return null;
                }
            } else {
                return null;
            }
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

    }

    public struct Tileset {
        public string[] autotile_names;
        public string battleback_name;
		public int fog_blend_type;
		public int fog_hue;
		public string fog_name;
		public int fog_opacity;
		public int fog_sx;
		public int fog_sy;
		public int fog_zoom;
		public int id;
		public string name;
		public int panorama_hue;
		public string panorama_name;
		public Table passages;
		public Table priorities;
		public Table terrain_tags;
		public string tileset_name;
    }

}
