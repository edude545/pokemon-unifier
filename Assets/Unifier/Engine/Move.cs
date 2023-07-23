using Assets.Unifier.Game.Editor;
using System;

namespace Assets.Unifier.Engine {

    public class Move : UnifierRegistryObject {

        public string ModuleName;

        public string Name;
        public string Identifier => Name.Replace(" ","").Replace("-","").Replace("'","");

        public MoveCategories Category;
        public int Power;
        public int Accuracy;
        public int BasePP;
        public PokeType Type;
        public TargetingType TargetingType;

        public ContestConditions ContestCondition;
        public int ContestAppeal;
        public int ContestJam;

        public bool MakesContact;

        public EffectStatement[] EffectStatements;

        public bool IsAttack {
            get {
                return Category == MoveCategories.Physical || Category == MoveCategories.Special;
            }
        }

        public bool IsAutoTarget { // Returns true if this is a multi-targeting or self-targeting move
            get {
                return TargetingType == TargetingType.AllAdjacentEnemies
                    || TargetingType == TargetingType.AllAdjacent
                    || TargetingType == TargetingType.AllAllies
                    || TargetingType == TargetingType.AllEnemies
                    || TargetingType == TargetingType.All
                    || TargetingType == TargetingType.User
                    || TargetingType == TargetingType.UserAndAllAllies;
            }
        }

        public static Move GetByInternalName(string name) {
            foreach (UnifierModule module in UnifierModule.Modules.Values) {
                if (module.HasMove(name)) {
                    return module.GetMove(name);
                }
            }
            throw new ArgumentOutOfRangeException("No registered module provides a move with internal name " + name);
        }

        // TODO
        public bool MayHaveEffect(params string[] effectNames) {
            return false;
        }

        public override string ToString() {
            return Name;
        }

        // TODO
        // ====================================
        public struct EffectStatement {
            public Predicate[] predicates;
            public Trigger[] triggers;
            public Effect[] effects;
        }

        public struct Effect {
            public string name;
            public float[] parameters;
        }

        public struct Predicate {

        }

        public struct Trigger {

        }
        // ====================================

    }

    public enum MoveCategories {
        Physical,
        Special,
        Status,
        MaxMove
    }

    public enum TargetingType {

        // Non auto-target (0-4)
        AdjacentEnemy,          // Doodle, Max & G-Max moves
        Adjacent,               // Most attacks
        Any,                    // Dark Pulse, Flying Press, Brave Bird
        UserOrAdjacentAlly,     // Acupressure
        AdjacentAlly,           // Helping Hand, Aromatic Mist

        // Auto target (
        AllAdjacentEnemies,     // Heat Wave, Air Cutter, Dark Void
        AllAdjacent,            // Earthquake, Surf, Explosion
        AllAllies,              // Coaching
        AllEnemies,             // Stealth Rock, Toxic Spikes, Sticky Web
        All,                    // Trick Room, Rain Dance, Rototiller
        User,                   // Swords Dance, Recover, Baton Pass, Protect, Outrage
        UserAndAllAllies        // Quick Guard, Light Screen, Tailwind, Lucky Chant

    }

    public enum ContestConditions {
        Cool, Beautiful, Cute, Clever, Tough
    }

}
