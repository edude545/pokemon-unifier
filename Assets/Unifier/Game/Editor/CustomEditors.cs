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
                map.Load();
            }
        }

        private void OnEnable() {
            map = (BasicMap)target;
        }

    }

    [CustomEditor(typeof(TwoFrameAnimator))]
    public class TwoFrameAnimatorEditor : UnityEditor.Editor {

        TwoFrameAnimator animator;

        public override void OnInspectorGUI() {
            using (var check = new EditorGUI.ChangeCheckScope()) {
                base.OnInspectorGUI();
            }
            if (GUILayout.Button("Load sprites")) {
                animator.LoadSprites();
            }
        }

        private void OnEnable() {
            animator = (TwoFrameAnimator)target;
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
                animator.LoadSprites();
            }
        }

        private void OnEnable() {
            animator = (CharacterAnimator) target;
        }

    }


}
