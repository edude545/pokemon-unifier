using Assets.Unifier.Engine;
using Newtonsoft.Json.Converters;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Burst.Intrinsics;
using UnityEngine;
using UnityEngine.Playables;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Engine {

    internal struct BattlePosition {
        public int Side;
        public int Position;
        public BattlePosition(int side, int position) {
            Side = side;
            Position = position;
        }
    }

    // Class that represents the state of a Pokemon battle.
    // This class is purely logical, and needs to be "operated" by another object (such as a BattleUIController).
    internal class BattleSystem {

        public BattleSide[] Sides;
        public BattleSide PlayerSide {
            get {
                return Sides[0];
            }
        }

        private string battleLog;
        private string logUpdate;

        public int CurrentTurn; // Starts at 1

        internal enum BattleTypes { Single, Double, Triple }
        public BattleTypes BattleType;

        private List<Action> queuedActions;

        public BattleSystem(BattleTypes battleType, TrainerData player, TrainerData computer) {
            BattleType = battleType;
            int size;
            if (BattleType == BattleTypes.Single) size = 1;
            else if (BattleType == BattleTypes.Double) size = 2;
            else if (BattleType == BattleTypes.Triple) size = 3;
            else size = 1;
            Sides = new BattleSide[2];
            Sides[0] = new BattleSide(this, player, size);
            Sides[1] = new BattleSide(this, computer, size);
            Sides[0].OpposingSide = Sides[1];
            Sides[1].OpposingSide = Sides[0];
            battleLog = "";
            CurrentTurn = 1;
            queuedActions = new List<Action>();
        }

        public void BeginTurn() {
            calculateTurnOrder();
        }

        // Process the next action. Returns battle log info.
        public ActionResult ProcessNextAction() {
            ActionResult ret = new ActionResult();
            logUpdate = "";
            queuedActions[0].Perform();
            queuedActions.RemoveAt(0);
            if (queuedActions.Count == 0) {
                ret.LastActionThisTurn = true;
                CurrentTurn++;
            } else {
                ret.LastActionThisTurn = false;
            }
            ret.Log = logUpdate;
            battleLog += logUpdate;
            return ret;
        }
        public struct ActionResult {
            public bool LastActionThisTurn;
            public string Log;
        }

        public Battler GetBattler(int side, int position) {
            return Sides[side].Battlers[position];
        }
        
        public Battler GetBattler(BattlePosition bp) {
            return GetBattler(bp.Side, bp.Position);
        }

        private void log(string message) {
            logUpdate += $"{message}\n";
        }

        public void QueueAction(Action action) {
            queuedActions.Add(action);
        }

        public void ClearActions() {
            queuedActions.Clear();
        }

        public void QueueActions(IEnumerable<Action> actions) {
            queuedActions = queuedActions.Union(actions).ToList();
        }

        private void calculateTurnOrder() {
            queuedActions.Sort((Action a1, Action a2) => a1.PriorityBracket.CompareTo(a2.PriorityBracket));
            queuedActions.Sort((Action a1, Action a2) => a1.Performer.Spe.CompareTo(a2.Performer.Spe));
        }

        public void SwapPokemon(Battler swappedOut, Pokemon swappedIn) {
            // TODO
        }

        // A BattleSide represents a side in a battle that controls one or more Battlers.
        internal class BattleSide {

            public int Index;
            public readonly BattleSystem BattleSystem;
            public TrainerData Trainer;
            public Battler[] Battlers;
            public BattleMask Mask;

            public BattleSide OpposingSide;

            public BattleSide(BattleSystem battleSystem, TrainerData trainer, int size) {
                BattleSystem = battleSystem;
                Trainer = trainer;
                Battlers = new Battler[size];
                for (int pos = 0; pos < size; pos++) {
                    Battlers[pos] = new Battler(this, trainer.GetPartyMember(pos), pos);
                }
                Mask = new BattleMask(this);
            }

            public Pokemon GetPokemon(int index) {
                return Trainer.GetPartyMember(index);
            }

            public Battler[] GetAdjacent(Battler battler) {
                return GetAdjacentAllies(battler).Concat(GetAdjacentEnemies(battler)).ToArray();
            }

            public Battler[] GetAdjacentAllies(Battler battler) {
                List<Battler> ret = new List<Battler>();
                if (battler.Position > 0) { ret.Add(Battlers[battler.Position - 1]); }
                if (battler.Position < Battlers.Length - 1) { ret.Add(Battlers[battler.Position + 1]); }
                return ret.ToArray();
            }

            public Battler[] GetAdjacentEnemies(Battler battler) {
                List<Battler> ret = new List<Battler>();
                if (battler.Position > 0) { ret.Add(OpposingSide.Battlers[battler.Position - 1]); }
                if (battler.Position < OpposingSide.Battlers.Length - 1) { ret.Add(OpposingSide.Battlers[battler.Position + 1]); }
                ret.Add(OpposingSide.Battlers[battler.Position]);
                return ret.ToArray();
            }

        }

        // An instance of Battler represents one Pokemon.
        // e.g. this class stores information on volatile status conditions, but not non-volatile status conditions.
        internal class Battler {

            public readonly BattleSide BattleSide;
            public Pokemon Pokemon;
            public int Position; // Index in the BattleSide's Battlers array. Used for adjacency calculation.
            //public StatComplex Effects;

            private BattleSystem battleSystem {
                get {
                    return BattleSide.BattleSystem;
                }
            }

            // TODO: Pokemon should be able to change their stats during battle
            public int HP { get { return Pokemon.HP; } }
            public int Atk { get { return Pokemon.Atk; } }
            public int Def { get { return Pokemon.Def; } }
            public int SpA { get { return Pokemon.SpA; } }
            public int SpD { get { return Pokemon.SpD; } }
            public int Spe { get { return Pokemon.Spe; } }

            public Ability Ability { get { return Pokemon.Ability; } } // TODO: Pokemon should be able to change abilities during battle
            public Typing Typing { get { return Pokemon.Typing; } } // TODO: Pokemon should be able to change type during battle
            public Move[] Moves {
                get {
                    List<Move> ret = new List<Move>();
                    foreach (Move move in Pokemon.Moves) {
                        if (move != null) { ret.Add(move); }
                    }
                    return ret.ToArray();
                }
            }

            public override string ToString() {
                return $"{Pokemon.Name} ({Pokemon.Species.Name})\n{Typing}\n{Pokemon.Nature} nature\n{HP} HP, {Atk} Atk, {Def} Def, {SpA} SpA, {SpD} SpD, {Spe} Spe\n{string.Join<Move>(", ", Moves)}";
            }

            public Action CurrentAction; // Action to be performed by the Battler this turn. Player input/AI choice code writes to this field.

            public Battler(BattleSide battleSide, Pokemon pokemon, int position) {
                BattleSide = battleSide;
                Pokemon = pokemon;
                Position = position;
                //Stats = new PokeStatDict(Pokemon.Stats);
            }

            public void ReceiveDamage(int damage) {
                Pokemon.CurrentHP -= damage;
                battleSystem.log(Pokemon.Name + " lost " + damage + " HP!");
            }

            public float GetSTAB(Move move) {
                return Typing.Has(move.Type) ? 1.5f : 1f;
            }

            public bool RollCrit(int ratioOffset) {
                float roll = UnityEngine.Random.value;
                int ratio = ratioOffset;
                //ratio += (int) Effects.Get("Crit Ratio");
                switch (ratio) {
                    case 0: return roll < 0.04167f;
                    case 1: return roll < 0.125;
                    case 2: return roll < 0.5;
                    default: return true;
                }
            }

            public bool IsCritImmune() {
                return false;
            }

        }

        // This class describes an action the Trainer may make, once per turn, for each Pokemon.
        // This include moves, switching Pokemon, using items, Mega Evolving, using Z-Moves, Dynamaxing, and Terastallizing.
        internal abstract class Action {
            protected bool performed = true;
            public Battler Performer;
            public int PriorityBracket;
            protected BattleSystem battleSystem {
                get {
                    return Performer.BattleSide.BattleSystem;
                }
            }
            public Action(Battler battler) {
                Performer = battler;
            }
            public abstract void Perform();
        }

        internal class MoveAction : Action {
            protected int moveIndex;
            protected BattlePosition[] targets;
            protected Move move {
                get {
                    return Performer.Pokemon.Moves[moveIndex];
                }
            }
            public MoveAction(Battler battler, int moveIndex, BattlePosition[] targets) : base(battler) {
                this.moveIndex = moveIndex;
                this.targets = targets;
            }
            public override void Perform() {
                battleSystem.log(Performer.Pokemon.Name + " used " + move.Name + "!");
                //bool multiTargetDamageReduction = targets.Length > 1;
                bool multiTargetDamageReduction = false;
                if (move.IsAttack) {
                    foreach (BattlePosition bp in targets) {
                        performAttack(battleSystem, Performer, move, battleSystem.GetBattler(bp), multiTargetDamageReduction, Performer.RollCrit(0));
                    }
                } else {
                    battleSystem.log("Performing non-attack move");
                }
            }
            private static void performAttack(BattleSystem battleSystem, Battler performer, Move move, Battler target, bool multiTargetDamageReduction, bool isCrit) {
                int atkStat; int defStat;
                if (move.Category == MoveCategories.Physical) {
                    atkStat = performer.Atk; defStat = target.Def;
                } else {
                    atkStat = performer.SpA; defStat = target.SpD;
                }
                float effectiveness = move.Type.GetMatchupAttacking(target.Typing);
                if (effectiveness > 1) {
                    battleSystem.log("It's super effective against " + target.Pokemon.Name + "!");
                } else if (effectiveness == 0) {
                    battleSystem.log("It had no effect against " + target.Pokemon.Name + "...");
                } else if (effectiveness < 1) {
                    battleSystem.log("It's not very effective against " + target.Pokemon.Name + "...");
                }
                if (isCrit) battleSystem.log("A critical hit!");
                int damage = (int)(
                    ((((2 * performer.Pokemon.Level) / 5 + 2) * move.Power * (atkStat / defStat)) / 50 + 2)
                    * (multiTargetDamageReduction ? 0.75f : 1f)
                    * ((isCrit && !target.IsCritImmune()) ? 1.5f : 1f)
                    * (UnityEngine.Random.Range(85, 101) / 100f)
                    * performer.GetSTAB(move)
                    * effectiveness
                );
                target.ReceiveDamage(damage);
            }

        }

        internal class MoveAndSwitchAction : MoveAction {
            public readonly int TargetPosition;
            public readonly int PartyMemberIndex;
            public MoveAndSwitchAction(Battler battler, int moveIndex, BattlePosition[] targets, int partyMemberIndex) : base(battler, moveIndex, targets) {
                PartyMemberIndex = partyMemberIndex;
            }
            public override void Perform() {
                base.Perform();
            }
        }

        internal class SwitchAction : Action {
            public readonly int PartyMemberIndex;
            public SwitchAction(Battler battler, int partyMemberIndex) : base(battler) {
                PartyMemberIndex = partyMemberIndex;
            }
            public override void Perform() {
                battleSystem.SwapPokemon(Performer, Performer.BattleSide.GetPokemon(PartyMemberIndex));
            }
        }

    }
}
