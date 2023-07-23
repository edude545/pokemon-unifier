using Assets.Unifier.Engine;
using Assets.Unifier.Game.Data;
using Assets.Unifier.Game.Essentials;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Net.Configuration;
using System.Reflection;
using Unity.Plastic.Newtonsoft.Json;
using Unity.Plastic.Newtonsoft.Json.Linq;
using UnityEditor;
using UnityEngine;
using static Assets.Unifier.Engine.LearnsetData;
using static UnityEngine.GraphicsBuffer;

namespace Assets.Unifier.Game.Editor {

    [CustomEditor(typeof(BasicMap))]
    public class BasicMapEditor : UnityEditor.Editor {

        BasicMap map;

        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
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

        UnifierModule unifierModule;

        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            if (GUILayout.Button("Load game data to memory [DEBUG]")) {
                unifierModule.GenerateAssets();
                Debug.Log("Module " + unifierModule.ModuleName + "'s data was loaded successfully");
            }
        }

        protected virtual void OnEnable() {
            unifierModule = (UnifierModule)target;
        }

    }

    [CustomEditor(typeof(CharacterAnimator))]
    public class CharacterAnimatorEditor : UnityEditor.Editor {

        CharacterAnimator animator;

        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            if (GUILayout.Button("Load sprites")) {
                animator.LoadSpritesFromInspectorFields();
            }
        }

        private void OnEnable() {
            animator = (CharacterAnimator) target;
        }

    }


}
