using Assets.Unifier.Game.Essentials;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Unity.Plastic.Newtonsoft.Json.Linq;
using Unity.Plastic.Newtonsoft.Json;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;
using NUnit.Framework;

namespace Assets.Unifier.Game.Editor {

    [CustomEditor(typeof(EssentialsModule))]
    public class EssentialsModuleEditor : UnityEditor.Editor {

        EssentialsModule module;

        // ex. StreamingAssets/Modules/Insurgence
        // No slash at end.
        public string BuildPath {
            get {
                return Path.Combine(Application.streamingAssetsPath, "Modules", module.ModuleName);
            }
        }

        public override void OnInspectorGUI() {
            using (var check = new EditorGUI.ChangeCheckScope()) {
                base.OnInspectorGUI();
            }
            try {
                if (GUILayout.Button("Deserialize map assets from JSON files")) {
                    DeserializeMaps();
                }
                if (GUILayout.Button("Expand autotile spritesheets")) {
                    ExpandAutotiles();
                }
                if (GUILayout.Button("Deserialize tileset assets from JSON files")) {
                    DeserializeTilesets();
                }
                if (GUILayout.Button("Generate tiles for tileset assets")) {
                    GenerateTiles();
                }
            }
            catch (Exception ex) {
                AssetDatabase.StopAssetEditing();
                Debug.LogError(ex);
            }
        }

        private void OnEnable() {
            module = (EssentialsModule)target;
        }

        private void saveAsset(UnityEngine.Object asset, string subdirectory) {
            string path = Path.Combine(module.ModulePath, subdirectory, asset.name);
            if (AssetDatabase.FindAssets(path) != null) AssetDatabase.DeleteAsset(path);
            AssetDatabase.CreateAsset(asset, path + ".asset");
        }

        private void makeFolder(string subdir, string dir) {
            subdir = module.ModulePath + "/" + subdir;
            if (!AssetDatabase.IsValidFolder(subdir+"/"+dir)) {
                AssetDatabase.CreateFolder(subdir, dir);
            }
        }

        // =============================================

        public void DeserializeMaps() {
            AssetDatabase.StartAssetEditing();
            string[] jsonPaths = Directory.GetFiles(Path.Combine(module.ModulePath, "JSON", "Maps"), "*.json");
            foreach (string jsonPath in jsonPaths) {
                TextAsset json = AssetDatabase.LoadAssetAtPath<TextAsset>(jsonPath);
                EssentialsJSONMapData map = JsonConvert.DeserializeObject<EssentialsJSONMapData>(json.text);
                map.event_list =
                    JsonConvert.DeserializeObject<Dictionary<string, Essentials.Event>>(
                        JObject.Parse(json.text)["events"].ToString()
                    ).Values.ToArray();
                EssentialsMapAsset asset = CreateInstance<EssentialsMapAsset>();
                asset.MapData = map;
                asset.name = json.name.Replace("Map", "");
                saveAsset(asset, "Maps");
            }
            AssetDatabase.StopAssetEditing();
        }

        // Generate "expanded" autotile spritesheets with 48 sprites
        public void ExpandAutotiles() {
            /// TODO
        }

        // Generate tileset asset from JSON
        public void DeserializeTilesets() {
            AssetDatabase.StartAssetEditing();
            makeFolder("", "Tilesets");
            Tileset?[] tilesets = JsonConvert.DeserializeObject<Tileset?[]>(Resources.Load<TextAsset>(module.ModulePath + "/JSON/Tilesets").text);
            foreach (Tileset? tileset in tilesets) {
                //Debug.Log(tilesetJson.ToString());
                if (tileset is null) continue;
                EssentialsTilesetAsset asset = CreateInstance<EssentialsTilesetAsset>();
                asset.TilesetData = tileset.Value;
                asset.name = tileset.Value.id.ToString();
                saveAsset(asset, "Tilesets");
            }
            AssetDatabase.StopAssetEditing();
        }

        // Build tiles for each tileset
        public void GenerateTiles() {
            AssetDatabase.StartAssetEditing();
            makeFolder("", "Tiles");
            foreach (EssentialsTilesetAsset tileset in Resources.LoadAll<EssentialsTilesetAsset>(module.ModulePath + "/Graphics/Tilesets")) {
                Debug.Log("Building tile for tileset " + tileset.TilesetData.name);
                makeFolder("Tiles", tileset.TilesetData.id.ToString());

                // Main tiles
                Sprite[] sprites = Resources.LoadAll<Sprite>(module.ModulePath + "/Graphics/Tilesets/" + tileset.TilesetData.tileset_name);
                makeFolder("Tiles/"+tileset.TilesetData.id, "Main");
                for (int i = 0; i < sprites.Length; i++) {
                    Tile tile = CreateInstance<Tile>();
                    tile.name = spriteToTilemapIndex(sprites[i]).ToString();
                    tile.sprite = sprites[i];
                    tile.colliderType = Tile.ColliderType.Grid; /// TODO
                    saveAsset(tile, "Tiles/"+tileset.TilesetData.id+"/Main");
                }
                break;
                // Autotiles
                /*AssetDatabase.CreateFolder(tilesPath, "Autotiles");
                foreach (string autotileName in tileset.TilesetData.autotile_names) {
                    Sprite[] autotileSprites = Resources.LoadAll<Sprite>(module.ModulePath + "/Graphics/ExpandedAutotiles/" + autotileName);
                    AssetDatabase.CreateFolder(tilesPath + "/Autotiles", tileset.TilesetData.id.ToString());
                    string autotilesPath = tilesPath + "/Autotiles/" + tileset.TilesetData.id.ToString();
                    if (autotileSprites.Length != 48) { Debug.LogWarning("WARNING: Autotile spritesheet length is not 48!"); }
                    for (int i = 0; i < autotileSprites.Length; i++) {
                        Tile tile = CreateInstance<Tile>();
                        tile.name = spriteToTilemapIndex(autotileSprites[i]).ToString();
                        tile.sprite = autotileSprites[i];
                        tile.colliderType = Tile.ColliderType.Grid; /// TODO
                        saveAsset(tile, autotilesPath);
                    }
                }*/
            }
            AssetDatabase.StopAssetEditing();
        }

        // Build tiles for each autotile spritesheet
        public void BuildAutotiles() {
            // Build autotile tiles. These tiles are numbered 1 to 48 inclusive (0000 in map data represents an empty tile).
            /*AssetDatabase.CreateFolder(SourcesFolderPath + "/Tiles", "Autotiles"));
            foreach (string autotilePath in Directory.GetFiles(Path.Combine(SourcesFolderPath, "Graphics", "Autotiles"))) {
                Sprite[] rawSprites = AssetDatabase.LoadAllAssetsAtPath(autotilePath).OfType<Sprite>().ToArray();
                Sprite[] processedSprites = processAutotiles(rawSprites, (int)rawSprites[0].rect.width);
                foreach (Sprite sprite in processedSprites) {
                    saveSourceAsset(processedSprites, Path.Combine("Tiles", "Autotiles", ));
                }
            }*/
        }

        // =============================================

        // Each autotile has 48 unique numbers. The main tilemap is treated as the 8th autotile, so it starts at offset 384 (48 * 8).
        //private static readonly int TILEMAP_OFFSET_SIZE = 48;
        private static readonly int SPRITESHEET_COLUMN_HEIGHT_IN_TILES = 512;
        private static readonly int SPRITESHEET_COLUMN_WIDTH_IN_TILES = 8;
        private static readonly int TILE_WIDTH = 32;

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

        /*private Sprite[] processAutotiles(Sprite[] rawSprites, int res) {

        }*/

        // =============================================

        // Tileset build, step 2. Packs sprites & tile assets into AssetBundles.
        /* public void BuildTilesetAssetBundlesFromSources() {

             AssetBundleBuild build;

             // Build main tiles asset bundles
             List<AssetBundleBuild> mainTilesetBuilds = new List<AssetBundleBuild>();
             foreach (string spritesheetName in Directory.GetDirectories(Path.Combine(ModulePath, "Tiles", "Main"))) {
                 string dirName = Path.GetDirectoryName(spritesheetName);
                 build = new AssetBundleBuild();
                 build.assetBundleName = dirName;
                 string[] assetPaths = Directory.GetFiles(Path.Combine(ModulePath, "Tiles", "Main", spritesheetName)) // add tile assets
                     .Append(Path.Combine(ModulePath, "Graphics", "Tilesets", spritesheetName)).ToArray(); // add sprites
                 mainTilesetBuilds.Add(build);
             }
             BuildPipeline.BuildAssetBundles(
                 Path.Combine(BuildPath, "Tiles", "Main"),
                 mainTilesetBuilds.ToArray(),
                 BuildAssetBundleOptions.None,
                 EditorUserBuildSettings.activeBuildTarget
             );

             List<AssetBundleBuild> autotileTilesetBuilds = new List<AssetBundleBuild>();
             foreach (string spritesheetName in Directory.GetDirectories(Path.Combine(ModulePath, "Tiles", "Autotiles"))) {
                 string dirName = Path.GetDirectoryName(spritesheetName);
                 build = new AssetBundleBuild();
                 build.assetBundleName = dirName;
                 string[] assetPaths = Directory.GetFiles(Path.Combine(ModulePath, "Tiles", "Autotiles", spritesheetName)) // add tile assets
                     .Append(Path.Combine(ModulePath, "Graphics", "Autotiles", spritesheetName)).ToArray(); // add sprites
                 autotileTilesetBuilds.Add(build);
             }
             BuildPipeline.BuildAssetBundles(
                 Path.Combine(BuildPath, "Tiles", "Autotiles"),
                 autotileTilesetBuilds.ToArray(),
                 BuildAssetBundleOptions.None,
                 EditorUserBuildSettings.activeBuildTarget
             );

         }*/

        // =============================================

        // https://discussions.unity.com/t/how-to-build-a-single-asset-bundle/221960/3
        /*public static void BuildAssetBundlesByName_DEPRECATED(string bundleName) {
            AssetBundleBuild built = new AssetBundleBuild();
            built.assetBundleName = bundleName;
            built.assetNames = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
            Debug.Log("assetBundle to build: " + built.assetBundleName);
            Debug.Log(AssetDatabase.GetAssetPathsFromAssetBundle(bundleName));
            BuildPipeline.BuildAssetBundles(
                "Assets/StreamingAssets",
                new AssetBundleBuild[] { built },
                BuildAssetBundleOptions.None,
                EditorUserBuildSettings.activeBuildTarget
            );
        }*/

    }

}
