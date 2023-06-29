using Assets.Unifier.Engine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.Unifier.Engine {

    public class PokeStatDict {

        public DynamicStat HP;
        public DynamicStat Atk;
        public DynamicStat Def;
        public DynamicStat SpA;
        public DynamicStat SpD;
        public DynamicStat Spe;

        public int Total {
            get {
                return (int) (HP.Value + Atk.Value + Def.Value + SpA.Value + SpD.Value + Spe.Value);
            }
        }

        public int this[PokeStat stat] {
            get {
                return (int) getByStatIndex(stat).Value;
            }
            set {
                getByStatIndex(stat).BaseValue = value;
            }
        }

        public static PokeStatDict Zero {
            get {
                PokeStatDict ret = new PokeStatDict();
                ret.HP.BaseValue = 0;
                ret.Atk.BaseValue = 0;
                ret.Def.BaseValue = 0;
                ret.SpA.BaseValue = 0;
                ret.SpD.BaseValue = 0;
                ret.Spe.BaseValue = 0;
                return ret;
            }
        }

        private DynamicStat getByStatIndex(PokeStat stat) {
            switch (stat) {
                case PokeStat.HP: return HP;
                case PokeStat.Atk: return Atk;
                case PokeStat.Def: return Def;
                case PokeStat.SpA: return SpA;
                case PokeStat.SpD: return SpD;
                case PokeStat.Spe: return Spe;
                default: throw new System.ArgumentOutOfRangeException("Invalid stat index " + stat);
            }
        }

        public PokeStatDict() : this(0f, 0f, 0f, 0f, 0f, 0f) { }

        public PokeStatDict(float hp, float atk, float def, float spa, float spd, float spe) {
            HP = new DynamicStat("HP", hp);
            Atk = new DynamicStat("Attack", atk);
            Def = new DynamicStat("Defense", def);
            SpA = new DynamicStat("Special Attack", spa);
            SpD = new DynamicStat("Special Defense", spd);
            Spe = new DynamicStat("Speed", spe);
        }

        public PokeStatDict(int[] stats) : this(stats[0], stats[1], stats[2], stats[3], stats[4], stats[5]) { }

        public static PokeStatDict FromStrings(params string[] stats) {
            int[] _stats = new int[6];
            for (int i = 0; i < 6; i++) {
                if (!int.TryParse(stats[i], out _stats[i])) {
                    _stats[i] = 0;
                }
            }
            return new PokeStatDict(_stats);
        }

        public PokeStatDict(PokeStatDict baseStats)
            : this(baseStats.HP.Value, baseStats.Atk.Value, baseStats.Def.Value, baseStats.SpA.Value, baseStats.SpD.Value, baseStats.Spe.Value) { }

        public static PokeStatDict Randomize(int max) {
            PokeStatDict ret = new PokeStatDict();
            ret.HP.BaseValue = Random.Range(0, max);
            ret.Atk.BaseValue = Random.Range(0, max);
            ret.Def.BaseValue = Random.Range(0, max);
            ret.SpA.BaseValue = Random.Range(0, max);
            ret.SpD.BaseValue = Random.Range(0, max);
            ret.Spe.BaseValue = Random.Range(0, max);
            return ret;
        }

        public override string ToString() {
            return (int)HP.Value + " HP, " + (int)HP.Value + " Atk, " + (int)HP.Value + " Def, " + (int)HP.Value + " SpA, " + (int)HP.Value + " SpD, " + (int)HP.Value + " Spe";
        }

    }

}
