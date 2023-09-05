using Assets.Unifier.Game.Essentials;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Unity.Plastic.Newtonsoft.Json.Linq;
using Unity.Plastic.Newtonsoft.Json;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEngine.Rendering;

namespace Assets.Unifier.Game.Editor {

    [CustomEditor(typeof(EssentialsModule))]
    public class EssentialsModuleEditor : UnifierModuleEditor {

        EssentialsModule essentialsModule;
        
        // :)
        private static string[] autotileParts = {
            "",
            "itl",
            "itr",
            "itl itr",
            "ibr",
            "itl ibr",
            "itr ibr",
            "itl itr ibr",

            "ibl",
            "itl ibl",
            "itr ibl",
            "itl itr ibl",
            "ibl ibr",
            "itl ibl ibr",
            "itr ibl ibr",
            "itl itr ibr ibl",

            "l",
            "l itr",
            "l ibr",
            "l itr ibr",
            "t",
            "t ibr",
            "t ibl",
            "t ibr ibl",

            "r",
            "r ibl",                    // swapped these two lines
            "r itl",                    //
            "r itl ibl",
            "b",
            "b itl",
            "b itr",
            "b itl itr",

            "l r",
            "t b",
            "otl",
            "otl ibr",
            "otr",
            "otr ibl",
            "obr",
            "obr itl",

            "obl",
            "obl itr",
            "l r ut",                 // might be wrong
            "t b ur",
            "l r ub",                 // might be wrong
            "t b ul",
            "ul ur",                  // might be wrong
            "",                       // might be wrong
        };

        // ex. StreamingAssets/Modules/Insurgence
        // No slash at end.
        public string BuildPath {
            get {
                return Path.Combine(Application.streamingAssetsPath, "Modules", essentialsModule.ModuleName);
            }
        }

        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            try {
                if (GUILayout.Button("Deserialize map assets from JSON files")) {
                    DeserializeMaps();
                }
                if (GUILayout.Button("Deserialize mapinfos into map assets")) {
                    DeserializeMapInfos();
                }
                if (GUILayout.Button("Expand autotile spritesheets")) {
                    ExpandAutotiles();
                }
                if (GUILayout.Button("Slice expanded autotile spritesheets")) {
                    SliceExpandedAutotiles();
                }
                if (GUILayout.Button("Deserialize tileset assets from JSON files")) {
                    DeserializeTilesets();
                }
            }
            catch (Exception ex) {
                AssetDatabase.StopAssetEditing();
                Debug.LogException(ex);
            }
        }

        protected override void OnEnable() {
            base.OnEnable();
            essentialsModule = (EssentialsModule)target;
        }

        private void saveAsset(UnityEngine.Object asset, string subdirectory) {
            string path = "Assets/Resources/" + essentialsModule.ModulePath + "/" + subdirectory + "/" + asset.name;
            if (AssetDatabase.FindAssets(path) != null) AssetDatabase.DeleteAsset(path);
            AssetDatabase.CreateAsset(asset, path + ".asset");
        }

        private void makeFolder(string path, string dirName) {
            path = "Assets/Resources/" + essentialsModule.ModulePath + "/" + path;
            //Debug.Log("Making folder " + dirName + " at " + path);
            if (!AssetDatabase.IsValidFolder(path+"/"+dirName)) {
                AssetDatabase.CreateFolder(path, dirName);
            }
        }

        private void makeFolder(string dirName) {
            string path = "Assets/Resources/" + essentialsModule.ModulePath;
            //Debug.Log("Making folder " + dirName + " at " + path);
            if (!AssetDatabase.IsValidFolder(path+"/"+dirName)) {
                AssetDatabase.CreateFolder(path, dirName);
            }
        }

        private class ParametersConverter : JsonConverter<Parameters> {
            public override Parameters ReadJson(JsonReader reader, Type objectType, Parameters existingValue, bool hasExistingValue, JsonSerializer serializer) {
                Parameters parameters = new Parameters();
                List<string> values = new();

                reader.Read(); // get rid of StartArray

                while (reader.TokenType != JsonToken.EndArray) {
                    if (reader.TokenType == JsonToken.Integer || reader.TokenType == JsonToken.String) {
                        values.Add(reader.Value.ToString());
                    } else if (reader.TokenType == JsonToken.StartObject) {
                        values.Add(JsonConvert.SerializeObject(JObject.Load(reader))); // :|
                    } else if (reader.TokenType == JsonToken.StartArray) {
                        List<object> list = new();
                        reader.Read();
                        while (reader.TokenType != JsonToken.EndArray) {
                            list.Add(reader.Value);
                            reader.Read();
                        }
                        values.Add(JsonConvert.SerializeObject(list));
                    } else {
                        throw new NotImplementedException("Unhandled token type: " + reader.TokenType);
                    }
                    reader.Read();
                }

                parameters.values = values.ToArray();
                return parameters;
            }

            public override void WriteJson(JsonWriter writer, Parameters value, JsonSerializer serializer) {
                throw new NotImplementedException();
            }
        }

        // =============================================

        public void DeserializeMaps() {
            AssetDatabase.StartAssetEditing();
            string[] jsonPaths = Directory.GetFiles("Assets/Resources/" + essentialsModule.ModulePath + "/JSON/Maps", "*.json");
            makeFolder("Maps");
            foreach (string jsonPath in jsonPaths) {
                Debug.Log(jsonPath);
                TextAsset json = AssetDatabase.LoadAssetAtPath<TextAsset>(jsonPath);
                MapData map = JsonConvert.DeserializeObject<MapData>(json.text);
                map.event_list =
                    JsonConvert.DeserializeObject<Dictionary<string, Essentials.Event>>(
                        JObject.Parse(json.text)["events"].ToString(),
                        new ParametersConverter()
                    ).Values.ToArray();
                EssentialsMapAsset asset = CreateInstance<EssentialsMapAsset>();
                asset.Data = map;
                asset.name = json.name.Replace("Map00", "").Replace("Map0","").Replace("Map",""); // :/
                asset.Module = essentialsModule;
                saveAsset(asset, "Maps");
                //break;
            }
            AssetDatabase.StopAssetEditing();
        }

        public void DeserializeMapInfos() {
            AssetDatabase.StartAssetEditing();
            JObject json = JObject.Parse(Resources.Load<TextAsset>(essentialsModule.ModulePath + "/JSON/MapInfos").text);
            string mapsPath = essentialsModule.ModulePath + "/Maps/";
            foreach (JProperty jprop in json.Properties()) {
                EssentialsMapAsset map = Resources.Load<EssentialsMapAsset>(mapsPath + jprop.Name);
                if (map == null) Debug.LogError("No map found at " + mapsPath+jprop.Name + "!");
                map.Info = JsonConvert.DeserializeObject<MapInfo>(jprop.Value.ToString());
            }
            AssetDatabase.StopAssetEditing();
        }

        // Generate "expanded" autotile spritesheet PNGs with 48 sprites arranged along the x axis.
        // The equivalent sprites for different frames are split across the y axis for a rectangular texture.
        public void ExpandAutotiles() {
            AssetDatabase.StartAssetEditing();
            string[] paths = Directory.GetFiles("Assets/Resources/" + essentialsModule.ModulePath + "/Graphics/Autotiles", "*.png");
            makeFolder("Graphics", "ExpandedAutotiles");
            foreach (string path in paths) {
                Texture2D source = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                if (source.width < 96 || source.height < 128) continue;
                int frames = source.width / 96;
                Texture2D output = new Texture2D(48*32, frames*32, TextureFormat.RGBA32, false);
                for (int f = 0; f < frames; f++) {
                    for (int i = 0; i < autotileParts.Length; i++) {
                        autotile(source, output, i * 32, f * 32, autotileParts[i], f*96);
                    }
                }

                //output.SetPixel(0, 0, Color.green); // writes a green pixel to the BOTTOM LEFT of the output image

                output.Apply();

                File.WriteAllBytes("Assets/Resources/" + essentialsModule.ModulePath + "/Graphics/ExpandedAutotiles/" + Path.GetFileName(path), output.EncodeToPNG());
            }
            AssetDatabase.StopAssetEditing();
            AssetDatabase.Refresh();
        }

        public void SliceExpandedAutotiles() {
            string[] paths = Directory.GetFiles("Assets/Resources/" + essentialsModule.ModulePath + "/Graphics/ExpandedAutotiles", "*.png");
            AssetDatabase.StartAssetEditing();
            foreach (string path in paths) {
                Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                Debug.Log("Loaded texture " + tex);
                int permutations = tex.width / 32;
                int frames = tex.height / 32;
                SpriteMetaData[] smds = new SpriteMetaData[permutations*frames];
                for (int y = 0; y < frames; y++) {
                    for (int x = 0; x < permutations; x++) {
                        SpriteMetaData smd = new SpriteMetaData();
                        smd.name = y == 0 ? x.ToString() : (x + " " + y);
                        Debug.Log(smd.name);
                        smd.pivot = Vector2.one * 0.5f;
                        smd.rect = new Rect(x * 32, y * 32, 32, 32);
                        smd.border = Vector4.zero;
                        smds[y * permutations + x] = smd;
                    }
                }
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                importer.spritePixelsPerUnit = 32;
                importer.filterMode = FilterMode.Point;
                importer.maxTextureSize = 16384;
                importer.spriteImportMode = SpriteImportMode.Multiple;
                importer.spritesheet = smds;
                importer.SaveAndReimport();
            }
            AssetDatabase.StopAssetEditing();
        }

        // Generate tileset asset from JSON
        public void DeserializeTilesets() {
            AssetDatabase.StartAssetEditing();
            makeFolder("Tilesets");
            Tileset?[] tilesets = JsonConvert.DeserializeObject<Tileset?[]>(Resources.Load<TextAsset>(essentialsModule.ModulePath + "/JSON/Tilesets").text);
            foreach (Tileset? tileset in tilesets) {
                //Debug.Log(tilesetJson.ToString());
                if (tileset == null) continue;
                EssentialsTilesetAsset tilesetAsset = CreateInstance<EssentialsTilesetAsset>();
                tilesetAsset.TilesetData = tileset.Value;
                tilesetAsset.name = tileset.Value.id.ToString();
                tilesetAsset.Module = essentialsModule;
                //if (tilesetAsset.name != module.sname) continue;
                saveAsset(tilesetAsset, "Tilesets");

                Debug.Log("Building tiles for tileset " + tilesetAsset.TilesetData.name);

                //makeFolder("Tiles", tileset.TilesetData.id.ToString());

                // Main tiles
                if (tilesetAsset.TilesetData.tileset_name != "") {
                    Sprite[] sprites = Resources.LoadAll<Sprite>(essentialsModule.ModulePath + "/Graphics/Tilesets/" + tilesetAsset.TilesetData.tileset_name);
                    Debug.Log("Loaded " + sprites.Length + " sprites from path" + essentialsModule.ModulePath + "/Graphics/Tilesets/" + tilesetAsset.TilesetData.tileset_name);

                    for (int i = 0; i < sprites.Length; i++) {
                        Tile tile = CreateInstance<Tile>();
                        tile.name = (EssentialsTilesetAsset.SpriteToTilemapIndex(sprites[i]) + 384).ToString();
                        tile.sprite = sprites[i];
                        tile.colliderType = Tile.ColliderType.Grid; /// TODO
                        AssetDatabase.AddObjectToAsset(tile, tilesetAsset);
                    }
                }

                // Autotile tiles
                // makeFolder("Tiles/" + tileset.TilesetData.id, "Autotiles");
                for (int at = 0; at < tilesetAsset.TilesetData.autotile_names.Length; at++) {
                    string autotileName = tilesetAsset.TilesetData.autotile_names[at];
                    if (autotileName == "") { continue; }
                    //makeFolder("Tiles/" + tileset.TilesetData.id + "/Autotiles", autotileName);
                    Sprite[] autotileSprites = Resources.LoadAll<Sprite>(essentialsModule.ModulePath + "/Graphics/ExpandedAutotiles/" + autotileName);
                    foreach (Sprite sprite in autotileSprites) {
                        if (sprite.name.Contains(" ")) { continue; } // skip animation sprites for now
                        Tile tile = CreateInstance<Tile>();
                        tile.name = (int.Parse(sprite.name) + (at + 1) * 48).ToString();
                        tile.sprite = sprite;
                        tile.colliderType = Tile.ColliderType.Grid; /// TODO
                        AssetDatabase.AddObjectToAsset(tile, tilesetAsset);
                        //saveAsset(tile, "Tiles/" + tileset.TilesetData.id + "/Autotiles/" + autotileName);
                    }
                }
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.StopAssetEditing();
        }

        // =============================================

        // desc examples:
        // "l tr br" <---> Edge at left, top-right corner, and bottom-right corner.
        // "tr br" <---> Edge at top-right corner and bottom-right corner.
        // "" <---> No edges.
        // "b r" <---> Land at bottom and right.
        // The English descriptions here use magma autotiles as reference, so "land" refers to the borders.
        // Combinations like "l bl" (Land at left and bottom-left corner) should not be used.
        // Valid parts: l t r b itl itr ibl ibr otl otr obl obr ul ut ur ub
        // sox = sourceOffsetX
        private void autotile(Texture2D source, Texture2D output, int x, int y, string desc, int sourceOffsetX) {
            output.SetPixels(x, y, 32, 32, source.GetPixels(sourceOffsetX+32, 32, 32, 32)); // Copy middle texture. This will be the default appearance of the tile if desc is "".
            foreach (string part in desc.Split(" ")) {
                switch (part) {
                    case "": break;
                    case "l":   output.SetPixels(x   , y   , 16, 32, source.GetPixels(sourceOffsetX + 0  , 32 , 16, 32)); break;
                    case "t":   output.SetPixels(x   , y+16, 32, 16, source.GetPixels(sourceOffsetX + 32 , 80 , 32, 16)); break;
                    case "r":   output.SetPixels(x+16, y   , 16, 32, source.GetPixels(sourceOffsetX + 80 , 32 , 16, 32)); break;
                    case "b":   output.SetPixels(x   , y   , 32, 16, source.GetPixels(sourceOffsetX + 32 , 0  , 32, 16)); break;
                    case "itl": output.SetPixels(x   , y+16, 16, 16, source.GetPixels(sourceOffsetX + 64 , 112, 16, 16)); break;
                    case "itr": output.SetPixels(x+16, y+16, 16, 16, source.GetPixels(sourceOffsetX + 80 , 112, 16, 16)); break;
                    case "ibr": output.SetPixels(x+16, y   , 16, 16, source.GetPixels(sourceOffsetX + 80 , 96 , 16, 16)); break;
                    case "ibl": output.SetPixels(x   , y   , 16, 16, source.GetPixels(sourceOffsetX + 64 , 96 , 16, 16)); break;
                    case "otl":
                        output.SetPixels(x   , y+16, 32, 16, source.GetPixels(sourceOffsetX + 0  , 80 , 32, 16));
                        output.SetPixels(x   , y   , 16, 16, source.GetPixels(sourceOffsetX + 0  , 64 , 16, 16));
                        break;
                    case "otr":
                        output.SetPixels(x   , y+16, 32, 16, source.GetPixels(sourceOffsetX + 64 , 80 , 32, 16));
                        output.SetPixels(x+16, y   , 16, 16, source.GetPixels(sourceOffsetX + 80 , 64 , 16, 16));
                        break;
                    case "obr":
                        output.SetPixels(x+16, y+16, 16, 16, source.GetPixels(sourceOffsetX + 80 , 16 , 16, 16));
                        output.SetPixels(x   , y   , 32, 16, source.GetPixels(sourceOffsetX + 64 , 0  , 32, 16));
                        break;
                    case "obl":
                        output.SetPixels(x   , y+16, 16, 16, source.GetPixels(sourceOffsetX + 0  , 16 , 16, 16));
                        output.SetPixels(x   , y   , 32, 16, source.GetPixels(sourceOffsetX + 0  , 0  , 32, 16));
                        break;
                    case "ul":
                        output.SetPixels(x   , y+16, 16, 16, source.GetPixels(sourceOffsetX + 0  , 80 , 16, 16));
                        output.SetPixels(x   , y   , 16, 16, source.GetPixels(sourceOffsetX + 0  , 0  , 16, 16));
                        break;
                    case "ut":
                        output.SetPixels(x   , y+16, 16, 16, source.GetPixels(sourceOffsetX + 0  , 80 , 16, 16));
                        output.SetPixels(x+16, y+16, 16, 16, source.GetPixels(sourceOffsetX + 80 , 80 , 16, 16));
                        break;
                    case "ur":
                        output.SetPixels(x+16, y+16, 16, 16, source.GetPixels(sourceOffsetX + 80 , 80 , 16, 16));
                        output.SetPixels(x+16, y   , 16, 16, source.GetPixels(sourceOffsetX + 80 , 0  , 16, 16));
                        break;
                    case "ub":
                        output.SetPixels(x+16, y   , 16, 16, source.GetPixels(sourceOffsetX + 80 , 0  , 16, 16));
                        output.SetPixels(x   , y   , 16, 16, source.GetPixels(sourceOffsetX + 0  , 0  , 16, 16));
                        break;
                    default: throw new Exception("Invalid autotile part \"" + part + "\"");
                }
            }
        }

        /*private Sprite[] processAutotiles(Sprite[] rawSprites, int res) {

        }*/

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
