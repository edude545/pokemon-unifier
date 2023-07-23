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

        public new string ToString() {
            return $"{HP.Value} HP, {Atk.Value} Atk, {Def.Value} Def, {SpA.Value} SpA, {SpD.Value} SpD, {Spe.Value} Spe";
        }

        public static PokeStatDict Zero {
            get {
                return All(0f);
            }
        }

        public static PokeStatDict All(float value) {
            PokeStatDict ret = new PokeStatDict();
            ret.HP.BaseValue = value;
            ret.Atk.BaseValue = value;
            ret.Def.BaseValue = value;
            ret.SpA.BaseValue = value;
            ret.SpD.BaseValue = value;
            ret.Spe.BaseValue = value;
            return ret;
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

        public static PokeStatDict Randomize(int maxExclusive) {
            PokeStatDict ret = new PokeStatDict();
            ret.HP.BaseValue = Random.Range(0, maxExclusive);
            ret.Atk.BaseValue = Random.Range(0, maxExclusive);
            ret.Def.BaseValue = Random.Range(0, maxExclusive);
            ret.SpA.BaseValue = Random.Range(0, maxExclusive);
            ret.SpD.BaseValue = Random.Range(0, maxExclusive);
            ret.Spe.BaseValue = Random.Range(0, maxExclusive);
            return ret;
        }

    }

}
