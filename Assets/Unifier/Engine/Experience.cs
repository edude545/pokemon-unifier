using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class Experience {

        public static int ExpNeededForLevel(int lvl, LevelCurves curve) {
            if (curve == LevelCurves.Erratic) {
                if (lvl < 50) return lvl * lvl * lvl * (100 - lvl) / 50;
                else if (lvl < 68) return lvl * lvl * lvl * (150 - lvl) / 100;
                else if (lvl < 98) return lvl * lvl * lvl * (int)Mathf.Floor((1911-10*lvl)/3f) / 500;
                else return lvl * lvl * lvl * (160 - lvl) / 100;
            } else if (curve == LevelCurves.Fast) {
                return 4 * lvl * lvl * lvl / 5;
            } else if (curve == LevelCurves.MediumFast) {
                return lvl * lvl * lvl;
            } else if (curve == LevelCurves.MediumSlow) {
                return 6 * lvl * lvl * lvl / 5 - 15 * lvl * lvl + 100 * lvl - 140;
            } else if (curve == LevelCurves.Slow) {
                return 5 * lvl * lvl * lvl / 4;
            } else if (curve == LevelCurves.Fluctuating) {
                if (lvl < 15) return lvl * lvl * lvl * ((int)Mathf.Floor((lvl + 1) / 3f) + 24) / 50;
                else if (lvl < 36) return lvl * lvl * lvl * (lvl + 14) / 50;
                else return lvl * lvl * lvl * ((int)Mathf.Floor(lvl / 2f) + 32) / 50;
            } else {
                return 0;
            }
        }

        public static int GetExpGain(Pokemon loser, Pokemon victor) {
            float b = loser.Species.ExpYield; // base exp yield
            float e = 1f; // egg mult (TODO)
            float f = victor.Friendship >= 220 ? 1.2f : 1f; // affection mult
            float lvLoser = loser.Level;
            float lvVictor = victor.Level;
            float p = 1f; // boost for Exp. Point Power, Pass Power, O-Power, Rotom Power, or Exp. Charm (TODO)
            float s = 1f; // exp. share divisor (TODO)
            float t = victor.IsOutsider ? 1.5f : 1f; // outsider boost (TODO: foreign language boost)
            float v = victor.CanEvolveAtThisLevel() ? 1.2f : 1f; // unevolved boost
            return (int) (( b*lvLoser/5f * 1f/s * Mathf.Pow( (2*lvLoser + 10) / (lvLoser + lvVictor + 10) , 2.5f) + 1f ) * t * e * v * f * p);
        }

    }

    public enum LevelCurves {

        Erratic,
        Fast,
        MediumFast,
        MediumSlow,
        Slow,
        Fluctuating

    }
}
