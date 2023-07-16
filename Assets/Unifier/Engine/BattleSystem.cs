using Assets.Unifier.Engine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Burst.Intrinsics;
using UnityEngine;
using UnityEngine.Playables;
using static Assets.Unifier.Engine.BattleSystem;

namespace Assets.Unifier.Engine {

    // Class that represents the state of a Pokemon battle.
    // This class is purely logical, and needs to be "operated" by another object (such as a BattleUIController).
    internal class BattleSystem {

        public BattleSide[] Sides;
        public BattleSide PlayerSide {
            get {
                return Sides[0];
            }
        }

        public BattleMask PlayerBattleMask;
        private string battleLog;
        private string logUpdate;

        public int CurrentTurn; // Starts at 1

        internal enum BattleTypes { Single, Double, Triple }
        public BattleTypes BattleType;

        internal enum FieldEffect {
            HarshSunlight,
            Rain,
            AirLock,
            Sandstorm,
            Hail,
            Snow,
            PrimordialRain,
            PrimordialSunlight,
            DeltaStream
        }
        public List<FieldEffect> ActiveFieldEffects = new List<FieldEffect>();

        private List<Action> queuedActions;
        private int currentAction;

        public BattleSystem(BattleTypes battleType, TrainerData player, TrainerData computer) {
            BattleType = battleType;
            int battlers;
            if (BattleType == BattleTypes.Single) battlers = 1;
            else if (BattleType == BattleTypes.Double) battlers = 2;
            else if (BattleType == BattleTypes.Triple) battlers = 3;
            else battlers = 1;
            Sides = new BattleSide[2];
            Sides[0] = new BattleSide(this, player, battlers);
            Sides[1] = new BattleSide(this, computer, battlers);
            Sides[0].OpposingSide = Sides[1];
            Sides[1].OpposingSide = Sides[0];
            PlayerBattleMask = new BattleMask(this);
            battleLog = "";
            CurrentTurn = 1;
        }

        public void CloseInputs() {
            calculateTurnOrder();
            currentAction = 0;
        }

        // Process the next action. Returns battle log info.
        public ActionResult Next() {
            ActionResult ret = new ActionResult();
            logUpdate = "";
            queuedActions[currentAction].Perform();
            currentAction += 1;
            if (currentAction == queuedActions.Count) {
                currentAction = 0;
            }
            if (queuedActions.Count == 1) {
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

        private void log(string message) {
            logUpdate += message;
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

        public void HasFieldEffect() {

        }

        // A BattleSide represents a side in a battle that controls one or more Battlers.
        internal class BattleSide {

            public int Index;
            public readonly BattleSystem BattleSystem;
            public BattleSide OpposingSide;
            public Battler[] Battlers;
            public TrainerData Trainer;
            public List<string> Effects;
            public StatComplex Stats;

            public BattleSide(BattleSystem battleSystem, TrainerData trainer, int battlers) {
                BattleSystem = battleSystem;
                Trainer = trainer;
                Battlers = new Battler[battlers];
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
        internal abstract class Battler {

            public readonly BattleSide BattleSide;
            public Pokemon Pokemon;
            public int Position; // Index in the BattleSide's Battlers array. Used for adjacency calculation.
            public StatComplex Effects;

            private BattleSystem battleSystem {
                get {
                    return BattleSide.BattleSystem;
                }
            }

            // TODO: Pokemon should be able to change their stats during battle
            //public PokeStatDict Stats;
            public int HP { get { return (int) Pokemon.Stats.HP.Value; } }
            public int Atk { get { return (int)Pokemon.Stats.Atk.Value; } }
            public int Def { get { return (int)Pokemon.Stats.Def.Value; } }
            public int SpA { get { return (int)Pokemon.Stats.SpA.Value; } }
            public int SpD { get { return (int)Pokemon.Stats.SpD.Value; } }
            public int Spe { get { return (int)Pokemon.Stats.Spe.Value; } }

            public Ability Ability { get { return Pokemon.Ability; } } // TODO: Pokemon should be able to change abilities during battle
            public Typing Typing { get { return Pokemon.Typing; } } // TODO: Pokemon should be able to change type during battle
            public Move[] Moves { get { return Pokemon.Moves; } } // TODO: Pokemon should be able to gain or lose moves during battle

            public Action CurrentAction; // Action to be performed by the Battler this turn. Player input/AI choice code writes to this field.

            public abstract Action ProvideAction();

            public Battler(BattleSide battleSide, Pokemon pokemon, int position) {
                BattleSide = battleSide;
                Pokemon = pokemon;
                Position = position;
                //Stats = new PokeStatDict(Pokemon.Stats);
            }

            public void SetActionMove(int index) {
                CurrentAction = new MoveAction(this, index);
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
                ratio += (int) Effects.Get("Crit Ratio");
                switch (ratio) {
                    case 0: return roll > 0.04167f;
                    case 1: return roll > 0.125;
                    case 2: return roll > 0.5;
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
            public bool Performed = true;
            public Battler Performer;
            public readonly int PriorityBracket;
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
            public readonly int MoveIndex;
            public readonly Battler[] Targets;
            public readonly bool MegaEvolve;
            public readonly bool ZMove;
            public readonly bool Dynamax;
            public readonly bool Terastallize;
            public Move Move {
                get {
                    return Performer.Pokemon.Moves[MoveIndex];
                }
            }
            public MoveAction(Battler battler, int moveIndex) : base(battler) {
                MoveIndex = moveIndex;
            }
            public override void Perform() {
                battleSystem.log(Performer.Pokemon.Name + " used " + Move.Name + "!");
                bool multiTarget = Targets.Length > 1;
                if (Move.IsAttack) {
                    /*foreach (Battler target in Targets) {
                        performAttack(target, multiTarget, Battler.RollCrit(Move.CritRatio));
                    }*/
                }
            }
            private static void performAttack(Battler performer, Move move, BattleSystem battleSystem, Battler target, bool multiTarget, bool isCrit) {
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
                } else if (effectiveness < 0) {
                    battleSystem.log("It's not very effective against " + target.Pokemon.Name + "...");
                }
                int damage = (int)(
                    ((((2 * performer.Pokemon.Level) / 5 + 2) * move.Power * (atkStat / defStat)) / 50 + 2)
                    * (multiTarget ? 0.75f : 1f)
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
            public MoveAndSwitchAction(Battler battler, int moveIndex, int partyMemberIndex) : base(battler, moveIndex) {
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
