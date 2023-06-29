﻿using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Editor;
using Assets.Unifier.Engine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Game {

    public class GameController : MonoBehaviour {

        public GameDataImporter[] GameDataImporters;

        public static GameController Instance;

        private void Awake() {
            Instance = this;
            foreach (var gdi in GameDataImporters) {
                gdi.GenerateAssets();
            }
        }

        public static Species GetSpecies(string name) {
            foreach (var gdi in Instance.GameDataImporters) {
                if (gdi.Species.ContainsKey(name)) {
                    return gdi.Species[name];
                }
            }
            throw new KeyNotFoundException("No such species " + name + "!");
        }

        public static Move GetMove(string name) {
            foreach (var gdi in Instance.GameDataImporters) {
                if (gdi.Moves.ContainsKey(name)) {
                    return gdi.Moves[name];
                }
            }
            throw new KeyNotFoundException("No such move " + name + "!");
        }

    }

}