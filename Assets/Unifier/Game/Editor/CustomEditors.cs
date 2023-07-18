using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Essentials;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using Unity.Plastic.Newtonsoft.Json;
using Unity.Plastic.Newtonsoft.Json.Linq;
using UnityEditor;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

namespace Assets.Unifier.Game.Editor {

    [CustomEditor(typeof(BasicMap))]
    public class BasicMapEditor : UnityEditor.Editor {

        BasicMap map;

        public override void OnInspectorGUI() {
            using (var check = new EditorGUI.ChangeCheckScope()) {
                base.OnInspectorGUI();
                if (check.changed) {

                }
            }
            if (GUILayout.Button("Load map")) {
                map.Map.Load(map);
            }
        }

        private void OnEnable() {
            map = (BasicMap)target;
        }

    }

    [CustomEditor(typeof(UnifierModule))]
    public class UnifierModuleEditor : UnityEditor.Editor {

        UnifierModule module;

        public override void OnInspectorGUI() {
            using (var check = new EditorGUI.ChangeCheckScope()) {
                base.OnInspectorGUI();
                if (check.changed) {

                }
            }
            if (GUILayout.Button("Load")) {
                module.GenerateAssets();
                /*Pokemon absol = new Pokemon(module.GetSpecies("Absol"), 50);
                string s = "";
                foreach (Move move in absol.Moves) {
                    s += move.Name + " ";
                }
                Debug.Log(s);*/
                module.GetSpecies("Absol").BuildMoveset();
            }
        }

        private void OnEnable() {
            module = (UnifierModule)target;
        }

    }

    [CustomEditor(typeof(CharacterAnimator))]
    public class CharacterAnimatorEditor : UnityEditor.Editor {

        CharacterAnimator animator;

        public override void OnInspectorGUI() {
            using (var check = new EditorGUI.ChangeCheckScope()) {
                base.OnInspectorGUI();
            }
            if (GUILayout.Button("Load sprites")) {
                animator.LoadSpritesFromInspectorFields();
            }
        }

        private void OnEnable() {
            animator = (CharacterAnimator) target;
        }

    }


}
