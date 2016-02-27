import std.stdio;
import std.algorithm;
import std.array;
import std.conv;

import solutions;

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
