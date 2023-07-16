using System;
using System.Collections.Generic;
using System.IO;
using Unity.VisualScripting;
using UnityEngine;

namespace Assets.Unifier.Game {

    // * * *
    //
    // DEPRECATED
    //
    // * * *

    // Singleton component
    internal class BundleLoader_DEPRECATED {

        public static BundleLoader_DEPRECATED Instance;

        public static Dictionary<string, AssetBundle> AssetBundles;

        public static T LoadAsset<T>(string bundleName, string assetName) where T : UnityEngine.Object {
            validateBundle(bundleName);
            return AssetBundles[bundleName].LoadAsset<T>(assetName);
        }
        public static T[] LoadAssetWithSubAssets<T>(string bundleName, string assetName) where T : UnityEngine.Object {
            validateBundle(bundleName);
            return AssetBundles[bundleName].LoadAssetWithSubAssets<T>(assetName);
        }

        /*public static GameObject GetPrefab(string assetName) {
            return LoadAsset<GameObject>("prefabs", assetName);
        }*/

        private static void validateBundle(string bundleName) {
            if (AssetBundles == null) {
                AssetBundles = new Dictionary<string, AssetBundle>();
                foreach (var bundle in Resources.FindObjectsOfTypeAll<AssetBundle>()) {
                    AssetBundles[bundle.name] = bundle;
                }
            }
            if (!AssetBundles.ContainsKey(bundleName) || AssetBundles[bundleName].IsDestroyed()) {
                string path = Path.Combine(Application.streamingAssetsPath, bundleName);
                AssetBundles[bundleName] = AssetBundle.LoadFromFile(path);
                if (AssetBundles[bundleName] == null) {
                    throw new Exception("Couldn't find AssetBundle at " + path + "!");
                }
            }
        }

    }

}
