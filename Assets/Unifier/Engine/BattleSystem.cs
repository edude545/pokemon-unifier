using Assets.Unifier.Engine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Assets.Unifier.Engine {

    // Class that represents the state of a Pokemon battle.
    // This class is purely logical, and needs to be "operated" by another object (such as a BattleUIController).
    internal class BattleSystem {

        public BattleSide PlayerSide;
        public BattleSide EnemySide;

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

        private Action[] queuedActions;
        private int currentAction;

        public bool WaitingForInputs; // Controls whether this BattleSystem is waiting for inputs from players and AI.
        public bool InputsReady { get { return PlayerSide.InputsComplete && EnemySide.InputsComplete; } }

        public BattleSystem(BattleTypes battleType, TrainerData player, TrainerData computer) {
            BattleType = battleType;
            int battlers;
            if (BattleType == BattleTypes.Single) battlers = 1;
            else if (BattleType == BattleTypes.Double) battlers = 2;
            else if (BattleType == BattleTypes.Triple) battlers = 3;
            else battlers = 1;
            PlayerSide = new BattleSide(this, player, battlers);
            EnemySide = new BattleSide(this, computer, battlers);
            PlayerSide.OpposingSide = EnemySide;
            EnemySide.OpposingSide = PlayerSide;
            OpenInputs();
        }

        public void OpenInputs() {
            WaitingForInputs = true;
        }

        public void CloseInputs() {
            WaitingForInputs = false;
            calculateTurnOrder();
            currentAction = 0;
        }

        // Process the next action
        public void Next() {
            queuedActions[currentAction].Perform();
            currentAction += 1;
            if (currentAction == queuedActions.Length) {
                currentAction = 0;
                OpenInputs();
            }
        }

        public void calculateTurnOrder() {
            Array.Sort(queuedActions, (Action a1, Action a2) => a1.PriorityBracket.CompareTo(a2.PriorityBracket));
            Array.Sort(queuedActions, (Action a1, Action a2) => a1.Battler.Stats[PokeStat.Spe].CompareTo(a2.Battler.Stats[PokeStat.Spe]));
        }

        public void SwapPokemon(Battler swappedOut, Pokemon swappedIn) {

        }

        public void HasFieldEffect() {

        }

        // A BattleSide represents a side in a battle that controls one or more Battlers.
        internal class BattleSide {

            public readonly BattleSystem BattleSystem;
            public BattleSide OpposingSide;
            public Battler[] Battlers;
            public TrainerData Trainer;
            public List<string> Effects;
            public StatComplex Stats;

            public bool InputsComplete = false;

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
            
            public PokeStatDict Stats;

            public Ability Ability { get { return Pokemon.Ability; } }
            public Typing Typing { get { return Pokemon.Typing; } }

            public Action CurrentAction; // Action to be performed by the Battler this turn. Player input/AI choice code writes to this field.

            public abstract Action ProvideAction();

            public Battler(BattleSide battleSide, Pokemon pokemon, int position) {
                BattleSide = battleSide;
                Pokemon = pokemon;
                Position = position;
                Stats = new PokeStatDict(Pokemon.Stats);
            }

            public void SetActionMove(int index) {
                CurrentAction = new MoveAction(this, index);
            }

            public void ReceiveDamage(int damage) {

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
            public Battler Battler;
            public readonly int PriorityBracket;
            public Action(Battler battler) {
                Battler = battler;
            }
            public virtual void Perform() {

            }
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
                    return Battler.Pokemon.Moves[MoveIndex];
                }
            }
            public MoveAction(Battler battler, int moveIndex) : base(battler) {
                MoveIndex = moveIndex;
            }
            public override void Perform() {
                base.Perform();
                bool multiTarget = Targets.Length > 1;
                if (Move.IsAttack) {
                    /*foreach (Battler target in Targets) {
                        performAttack(target, multiTarget, Battler.RollCrit(Move.CritRatio));
                    }*/
                }
            }
            private void performAttack(Battler target, bool multiTarget, bool isCrit) {
                int atkStat; int defStat;
                if (Move.Category == MoveCategories.Physical) {
                    atkStat = Battler.Stats[PokeStat.Atk]; defStat = target.Stats[PokeStat.Def];
                } else {
                    atkStat = Battler.Stats[PokeStat.SpA]; defStat = target.Stats[PokeStat.SpD];
                }
                target.ReceiveDamage((int)(
                    ((((2*Battler.Pokemon.Level)/5+2) * Move.Power * (atkStat / defStat)) / 50 + 2)
                    * (multiTarget ? 0.75f : 1f)
                    * ((isCrit && !target.IsCritImmune()) ? 1.5f : 1f)
                    * (UnityEngine.Random.Range(85,101) / 100f)
                    * Battler.GetSTAB(Move)
                    * Move.Type.GetMatchupAttacking(target.Typing)
                ));;
            }
        }

        internal class SwitchPokemonAction : Action {
            public readonly int TargetPosition;
            public SwitchPokemonAction(Battler battler, int targetPosition) : base(battler) {
                TargetPosition = targetPosition;
            }
            public override void Perform() {
                base.Perform();
                Battler.BattleSide.BattleSystem.SwapPokemon(Battler, Battler.BattleSide.GetPokemon(TargetPosition));
            }
        }

    }
}
