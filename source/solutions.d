module solutions;
import std.stdio;
import std.algorithm;
import std.traits;
import std.conv;
import std.range;

Solution genBestSolution(long[] input) {
	auto bestResult = genSolutions(input).filter!(x => x.isValid).array.sort!((x,y) => x.score() > y.score());
	if (bestResult.empty)
		throw new Exception("No Solution");
	return bestResult.front;
}
unittest {
	auto solution = genBestSolution([6, 1, 3, 5]);
	assert(solution.score > 46);
	assert(solution.isValid);
}
Solution[] genSolutions(long[] valsOriginal) {
	Solution[] output;
	foreach (i, val1; valsOriginal) {
		auto vals2 = valsOriginal.dup.remove!(SwapStrategy.unstable)(i);
		foreach (j, val2; vals2) {
			auto vals = vals2.dup.remove!(SwapStrategy.unstable)(j);
			MathOp[] initialVals;
			foreach (op; EnumMembers!(MathOp.Operation))
				initialVals ~= MathOp(val1, val2, op);
			if (vals.length > 0) {
				foreach (done; initialVals) {
					try {
						auto newVal = done.calc();
						foreach (nums; vals.chain(only(newVal)).permutations)
							foreach (solution; genSolutions(nums.array)) {
								solution.ops = done~solution.ops;
								output ~= solution;
							}
					} catch(Exception) {}
				}
			} else
				output ~= initialVals.map!(x => Solution([x])).array;
		}
	}
	return output;
}
struct Solution {
	MathOp[] ops;
	long score() {
		long output;
		foreach (op; ops)
			output += op.calc();
		return output;
	}
	bool isValid() {
		try {
			return ops[$-1].calc() == 10;
		} catch (Exception) {
			return false;
		}
	}
	string toString() {
		return ops.map!(x => x.toString).join(" => ");
	}
}
struct MathOp {
	enum Operation { Add, Multiply, Divide, Subtract }
	long numOne;
	long numTwo;
	Operation op;
	long calc() {
		with(Operation) final switch (op) {
			case Add:
				return numOne + numTwo;
			case Subtract:
				return numOne - numTwo;
			case Divide:
				if (numTwo == 0)
					throw new Exception("Cannot perform this calculation");
				if (numOne%numTwo != 0)
					throw new Exception("Cannot perform this calculation");
				return numOne / numTwo;
			case Multiply:
				return numOne * numTwo;
		}
	}
	string toString() {
		with(Operation) final switch (op) {
			case Add:
				return numOne.text ~ "+" ~ numTwo.text;
			case Subtract:
				return numOne.text ~ "-" ~ numTwo.text;
			case Divide:
				return numOne.text ~ "/" ~ numTwo.text;
			case Multiply:
				return numOne.text ~ "*" ~ numTwo.text;
		}
	}
}