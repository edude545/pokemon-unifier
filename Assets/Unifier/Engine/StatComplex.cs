using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assets.Unifier.Engine {

    // Class for representing a wide array of stats and stat modifiers in a sane manner.
    // Stats can be created and requested dynamically.
    public class StatComplex {

        private List<DynamicStat> stats = new List<DynamicStat>();

        public StatComplex() {
        }

        // Use as a builder
        public StatComplex Add(string name, float defaultValue) {
            stats.Add(new DynamicStat(name, defaultValue));
            return this;
        }

        public float Get(string statName) {
            foreach (DynamicStat stat in stats) {
                if (stat.Name == statName) return stat.Value;
            }
            throw new ArgumentOutOfRangeException("Stat \""+statName+"\" not found in StatComplex - try initializing it with Add");
        }

    }

    public class DynamicStat {

        public readonly string Name;

        private float baseValue;
        public float BaseValue {
            get { return baseValue; }
            set { baseValue = value; recalculate(); }
        }

        public float Value { get; private set; }

        private List<StatMod> mods = new List<StatMod>();

        public DynamicStat(string name, float defaultValue) {
            Name = name;
            baseValue = defaultValue;
            Value = defaultValue;
        }

        public void AddOffset(string name, float offset, int priority) { addMod(new StatMod(name, offset, false, priority)); }
        public void AddOffset(string name, float offset) { AddMult(name, offset, 0); }

        public void AddMult(string name, float mult, int priority) { addMod(new StatMod(name, mult, true, priority)); }
        public void AddMult(string name, float mult) { AddMult(name,mult,0); }

        public void Remove(string name) {
            mods.RemoveAll(mod => mod.Name == name);
        }

        private void addMod(StatMod mod) { mods.Add(mod); mods.Sort(); recalculate(); }

        private void recalculate() {
            Value = baseValue;
            foreach (StatMod mod in mods) {
                if (mod.IsMult) { Value *= mod.Value; }
                else { Value += mod.Value; }
            }
        }

    }

    internal class StatMod : IComparable {
        public readonly string Name;
        public readonly float Value;
        public readonly bool IsMult;
        public readonly int Priority;

        public StatMod(string name, float value, bool isMult, int priority) {
            Name = name;
            Value = value;
            IsMult = isMult;
            Priority = priority;
        }

        public int CompareTo(object obj) { return Priority.CompareTo(((StatMod)obj).Priority); }
    }

}
