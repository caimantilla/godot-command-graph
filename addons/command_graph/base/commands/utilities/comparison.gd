@tool
extends RefCounted



enum ComparisonOperator {
	IS_EQUAL = 0,
	IS_NOT_EQUAL = 1,
	IS_LESSER = 2,
	IS_GREATER = 3,
	IS_LESSER_OR_EQUAL = 4,
	IS_GREATER_OR_EQUAL = 5,
}


const COMPARISON_OPERATOR_STRING = {
	ComparisonOperator.IS_EQUAL: "=",
	ComparisonOperator.IS_NOT_EQUAL: "~=",
	ComparisonOperator.IS_LESSER: "<",
	ComparisonOperator.IS_GREATER: ">",
	ComparisonOperator.IS_LESSER_OR_EQUAL: "<=",
	ComparisonOperator.IS_GREATER_OR_EQUAL: ">=",
}



static func evaluate( left_value: Variant, comparison_operator: ComparisonOperator, right_value: Variant ) -> bool:
	
	match comparison_operator:
		
		ComparisonOperator.IS_EQUAL:
			return left_value == right_value
		ComparisonOperator.IS_NOT_EQUAL:
			return left_value != right_value
		ComparisonOperator.IS_LESSER:
			return left_value < right_value
		ComparisonOperator.IS_GREATER:
			return left_value > right_value
		ComparisonOperator.IS_LESSER_OR_EQUAL:
			return left_value <= right_value
		ComparisonOperator.IS_GREATER_OR_EQUAL:
			return left_value >= right_value
		
		_:
			return false
