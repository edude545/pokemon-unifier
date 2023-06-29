using Assets.Unifier.Game.Essentials;
using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Unifier.Game.Data {

    public class DataManager {

        public static EssentialsTilemap_DEPRECATED GetEssentialsTilemap(string bundle, string filename) {
            //string path = "Assets/Data/" + bundle + "/Tilesets/" + filename + ".asset";
            Debug.Log("Have a look at this");
            return BundleLoader.LoadAsset<EssentialsTilemap_DEPRECATED>(bundle, filename);
        }

    }

    internal class NoDataException : Exception {

        public NoDataException(string s) : base(s) { }

    }

}
