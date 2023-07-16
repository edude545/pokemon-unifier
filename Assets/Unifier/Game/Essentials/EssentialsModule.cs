using Assets.Unifier.Game.Editor;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game.Essentials {

    // --- Module hierarchy structure ---
    // Assets
    // | Resources
    // | | Modules
    // | | | Insurgence
    // | | | | EssentialsModule asset
    // | | | | JSON
    // | | | | | Tilesets.json
    // | | | | | MapInfos.json
    // | | | | | Maps
    // | | | | | | Map JSONs...
    // | | | | Maps
    // | | | | | Built EssentialsMapAssets...
    // | | | | Graphics
    // | | | | | Autotiles
    // | | | | | | hgss_grass_01 (spritesheet)
    // | | | | | Tilesets
    // | | | | | | ins_outside (spritesheet)
    // | | | | | ExpandedAutotiles
    // | | | | | | hgss_grass_01 (expanded spritesheet with 48 tiles)
    // | | | | Tilesets
    // | | | | | 1.asset (EssentialsTilesetAsset for tileset with id 1)
    // | | | | Tiles
    // | | | | | 1
    // | | | | | | Autotiles
    // | | | | | | | hgss_grass_1
    // | | | | | | | | Built tiles from hgss_grass_1, using its expanded spritesheet
    // | | | | | | Main
    // | | | | | | | Built tiles from 1's spritesheet, with 1's terrain/priority data...
    [CreateAssetMenu(fileName = "Module", menuName = "Unifier/Essentials Module")]
    public class EssentialsModule : UnifierModule {

    }

}
