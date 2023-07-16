using Assets.Unifier.Game.Editor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game.Data {

    public abstract class CSVAsset : ScriptableObject {

        public abstract CSVAsset LoadFromCSVRecord(UnifierModule importer, Dictionary<string, string> record);

    }

}
