import std.stdio;
import std.algorithm;
import std.array;
import std.traits;
import std.conv;

void main(string[] args) {
	if (args.length == 1) {
		writeln("No solution");
		return;
	}
	try {
		auto solution = genBestSolution(args[1..$].map!(x => x.to!long).array);
		writefln("%s: %s", solution, solution.score);
	} catch (Exception) {
		writeln("No solution");
	}
}
Solution genBestSolution(long[] input) {
	auto bestResult = genSolutions(input).filter!(x => x.isValid).array.sort!((x,y) => x.score() > y.score());
	if (bestResult.empty)
		throw new Exception("No Solution");
	return bestResult.front;
}
unittest {
	assert(genBestSolution([6, 1, 3, 5]).score > 46);
}
Solution[] genSolutions(long[] vals) {
	MathOp[] initialVals;
	Solution[] output;
	foreach (op; EnumMembers!(MathOp.Operation))
		initialVals ~= MathOp(vals[0], vals[1], op);
	if (vals.length > 2) {
		foreach (done; initialVals) {
			try {
				auto newVal = done.calc();
				foreach (nums; (vals[2..$]~newVal).permutations)
					foreach (solution; genSolutions(nums.array)) {
						solution.ops = done~solution.ops;
						output ~= solution;
					}
			} catch(Exception) {}
		}
	} else
		output = initialVals.map!(x => Solution([x])).array;
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