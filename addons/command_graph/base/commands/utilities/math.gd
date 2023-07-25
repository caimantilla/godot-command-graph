@tool
extends RefCounted


enum ArithmeticOperator {
	ADD = 0,
	SUBTRACT = 1,
	MULTIPLY = 2,
	DIVIDE = 3,
}


const ARITHMETIC_OPERATOR_STRING: Dictionary = {
	ArithmeticOperator.ADD: "+",
	ArithmeticOperator.SUBTRACT: "−",
	ArithmeticOperator.MULTIPLY: "×",
	ArithmeticOperator.DIVIDE: "÷",
}



static func calculate( variable: float, operator: ArithmeticOperator, modifier: float ) -> float:
	
	var result: float = variable
	
	match operator:
		ArithmeticOperator.ADD:
			result += modifier
		ArithmeticOperator.SUBTRACT:
			result -= modifier
		ArithmeticOperator.MULTIPLY:
			result *= modifier
		ArithmeticOperator.DIVIDE:
			if is_zero_approx( modifier ):
				printerr( "Cannot divide by zero." )
			else:
				result /= modifier
	
	return result
