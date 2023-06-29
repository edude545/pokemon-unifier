using UnityEditor;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

namespace Assets.Unifier.Game.UI {

    internal class AssetBundleBuilder {

        [MenuItem("Assets/Build All Asset Bundles")]
        public static void BuildAllAssetBundles() {
            BuildPipeline.BuildAssetBundles(
                "Assets/StreamingAssets",
                BuildAssetBundleOptions.ChunkBasedCompression,
                EditorUserBuildSettings.activeBuildTarget
                );
        }

        [MenuItem("Assets/Build Asset Bundle: prefabs")]
        public static void BuildAssetBundle_prefabs() {
            BuildAssetBundlesByName("prefabs");
        }

        [MenuItem("Assets/Build Asset Bundle: overworld_characters")]
        public static void BuildAssetBundle_characters() {
            BuildAssetBundlesByName("overworld_characters");
        }

        [MenuItem("Assets/Build Asset Bundle: overworld_tilesets")]
        public static void BuildAssetBundle_tilesets() {
            BuildAssetBundlesByName("overworld_tilesets");
        }

        [MenuItem("Assets/Build Asset Bundle: essentials_maps_insurgence")]
        public static void BuildAssetBundle_essentials_maps_insurgence() {
            BuildAssetBundlesByName("essentials_maps_insurgence");
        }

        // https://discussions.unity.com/t/how-to-build-a-single-asset-bundle/221960/3
        public static void BuildAssetBundlesByName(string bundleName) {
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
        }

    }

}
