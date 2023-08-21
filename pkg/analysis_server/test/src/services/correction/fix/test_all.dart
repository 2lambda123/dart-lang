// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'add_async_test.dart' as add_async;
import 'add_await_test.dart' as add_await;
import 'add_call_super_test.dart' as add_call_super;
import 'add_const_test.dart' as add_const;
import 'add_curly_braces_test.dart' as add_curly_braces;
import 'add_diagnostic_property_reference_test.dart'
    as add_diagnostic_property_reference;
import 'add_enum_constant_test.dart' as add_enum_constant_test;
import 'add_eol_at_end_of_file_test.dart' as add_eol_at_end_of_file;
import 'add_explicit_call_test.dart' as add_explicit_call;
import 'add_explicit_cast_test.dart' as add_explicit_cast;
import 'add_extension_override_test.dart' as add_extension_override;
import 'add_field_formal_parameters_test.dart' as add_field_formal_parameters;
import 'add_key_to_constructors_test.dart' as add_key_to_constructors;
import 'add_late_test.dart' as add_late;
import 'add_leading_newline_to_string_test.dart'
    as add_leading_newline_to_string;
import 'add_missing_enum_case_clauses_test.dart'
    as add_missing_enum_case_clauses;
import 'add_missing_enum_like_case_clauses_test.dart'
    as add_missing_enum_like_case_clauses;
import 'add_missing_parameter_named_test.dart' as add_missing_parameter_named;
import 'add_missing_parameter_positional_test.dart'
    as add_missing_parameter_positional;
import 'add_missing_parameter_required_test.dart'
    as add_missing_parameter_required;
import 'add_missing_required_argument_test.dart'
    as add_missing_required_argument;
import 'add_missing_switch_cases_test.dart' as add_missing_switch_cases;
import 'add_ne_null_test.dart' as add_ne_null;
import 'add_null_check_test.dart' as add_null_check;
import 'add_override_test.dart' as add_override;
import 'add_reopen_test.dart' as add_reopen;
import 'add_required_test.dart' as add_required;
import 'add_return_null_test.dart' as add_return_null;
import 'add_return_type_test.dart' as add_return_type;
import 'add_static_test.dart' as add_static;
import 'add_super_constructor_invocation_test.dart'
    as add_super_constructor_invocation;
import 'add_super_parameter_test.dart' as add_super_parameter;
import 'add_switch_case_break_test.dart' as add_switch_case_break;
import 'add_trailing_comma_test.dart' as add_trailing_comma;
import 'add_type_annotation_test.dart' as add_type_annotation;
import 'analysis_options/test_all.dart' as analysis_options;
import 'bulk_fix_processor_test.dart' as bulk_fix_processor;
import 'change_argument_name_test.dart' as change_argument_name;
import 'change_to_nearest_precise_value_test.dart'
    as change_to_nearest_precise_value;
import 'change_to_static_access_test.dart' as change_to_static_access;
import 'change_to_test.dart' as change_to;
import 'change_type_annotation_test.dart' as change_type_annotation;
import 'convert_class_to_enum_test.dart' as convert_class_to_enum;
import 'convert_documentation_into_line_test.dart'
    as convert_documentation_into_line;
import 'convert_flutter_child_test.dart' as convert_flutter_child;
import 'convert_flutter_children_test.dart' as convert_flutter_children;
import 'convert_for_each_to_for_loop_test.dart' as convert_for_each_to_for_loop;
import 'convert_into_block_body_test.dart' as convert_into_block_body;
import 'convert_into_expression_body_test.dart' as convert_into_expression_body;
import 'convert_into_is_not_test.dart' as convert_into_is_not;
import 'convert_quotes_test.dart' as convert_quotes;
import 'convert_to_boolean_expression_test.dart'
    as convert_to_boolean_expression;
import 'convert_to_cascade_test.dart' as convert_to_cascade;
import 'convert_to_constant_pattern_test.dart' as convert_to_constant_pattern;
import 'convert_to_contains_test.dart' as convert_to_contains;
import 'convert_to_double_quoted_string_test.dart'
    as convert_to_double_quoted_string;
import 'convert_to_for_element_test.dart' as convert_to_for_element;
import 'convert_to_function_declaration_test.dart'
    as convert_to_function_declaration;
import 'convert_to_generic_function_syntax_test.dart'
    as convert_to_generic_function_syntax;
import 'convert_to_if_element_test.dart' as convert_to_if_element;
import 'convert_to_if_null_test.dart' as convert_to_if_null;
import 'convert_to_initializing_formal_test.dart'
    as convert_to_initializing_formal;
import 'convert_to_int_literal_test.dart' as convert_to_int_literal;
import 'convert_to_map_literal_test.dart' as convert_to_map_literal;
import 'convert_to_named_arguments_test.dart' as convert_to_named_arguments;
import 'convert_to_null_aware_spread_test.dart' as convert_to_null_aware_spread;
import 'convert_to_null_aware_test.dart' as convert_to_null_aware;
import 'convert_to_on_type_test.dart' as convert_to_on_type;
import 'convert_to_package_import_test.dart' as convert_to_package_import;
import 'convert_to_raw_string_test.dart' as convert_to_raw_string;
import 'convert_to_relative_import_test.dart' as convert_to_relative_import;
import 'convert_to_set_literal_test.dart' as convert_to_set_literal;
import 'convert_to_single_quoted_string_test.dart'
    as convert_to_single_quoted_string;
import 'convert_to_spread_test.dart' as convert_to_spread;
import 'convert_to_super_parameters_test.dart' as convert_to_super_parameters;
import 'convert_to_where_type_test.dart' as convert_to_where_type;
import 'convert_to_wildcard_pattern_test.dart' as convert_to_wildcard_pattern;
import 'create_class_test.dart' as create_class;
import 'create_constructor_for_final_fields_test.dart'
    as create_constructor_for_final_field;
import 'create_constructor_super_test.dart' as create_constructor_super;
import 'create_constructor_test.dart' as create_constructor;
import 'create_field_test.dart' as create_field;
import 'create_file_test.dart' as create_file;
import 'create_function_test.dart' as create_function;
import 'create_getter_test.dart' as create_getter;
import 'create_local_variable_test.dart' as create_local_variable;
import 'create_method_test.dart' as create_method;
import 'create_missing_overrides_test.dart' as create_missing_overrides;
import 'create_mixin_test.dart' as create_mixin;
import 'create_no_such_method_test.dart' as create_no_such_method;
import 'create_setter_test.dart' as create_setter;
import 'data_driven/test_all.dart' as data_driven;
import 'directives_ordering_test.dart' as directives_ordering;
import 'extend_class_for_mixin_test.dart' as extend_class_for_mixin;
import 'extract_local_variable_test.dart' as extract_local_variable;
import 'fix_in_file_test.dart' as fix_in_file;
import 'fix_processor_map_test.dart' as fix_processor_map;
import 'fix_test.dart' as fix;
import 'format_file_test.dart' as format_file;
import 'ignore_diagnostic_test.dart' as ignore_error;
import 'import_library_prefix_test.dart' as import_library_prefix;
import 'import_library_project_test.dart' as import_library_project;
import 'import_library_sdk_test.dart' as import_library_sdk;
import 'import_library_show_test.dart' as import_library_show;
import 'inline_invocation_test.dart' as inline_invocation;
import 'inline_typedef_test.dart' as inline_typedef;
import 'insert_semicolon_test.dart' as insert_semicolon;
import 'make_class_abstract_test.dart' as make_class_abstract;
import 'make_conditional_on_debug_mode_test.dart'
    as make_conditional_on_debug_mode;
import 'make_field_not_final_test.dart' as make_field_not_final;
import 'make_field_public_test.dart' as make_field_public;
import 'make_final_test.dart' as make_final;
import 'make_required_named_parameters_first_test.dart'
    as make_required_named_parameters_first;
import 'make_return_type_nullable_test.dart' as make_return_type_nullable;
import 'make_super_invocation_last_test.dart' as make_super_invocation_last;
import 'make_variable_not_final_test.dart' as make_variable_not_final;
import 'make_variable_nullable_test.dart' as make_variable_nullable;
import 'move_annotation_to_library_directive_test.dart'
    as move_annotation_to_library_directive;
import 'move_doc_comment_to_library_directive_test.dart'
    as move_doc_comment_to_library_directive;
import 'move_type_arguments_to_class_test.dart' as move_type_arguments_to_class;
import 'organize_imports_test.dart' as organize_imports;
import 'pubspec/test_all.dart' as pubspec;
import 'qualify_reference_test.dart' as qualify_reference;
import 'remove_abstract_test.dart' as remove_abstract;
import 'remove_annotation_test.dart' as remove_annotation;
import 'remove_argument_test.dart' as remove_argument;
import 'remove_assertion_test.dart' as remove_assertion;
import 'remove_assignment_test.dart' as remove_assignment;
import 'remove_await_test.dart' as remove_await;
import 'remove_break_test.dart' as remove_break;
import 'remove_character_test.dart' as remove_character;
import 'remove_comparison_test.dart' as remove_comparison;
import 'remove_const_test.dart' as remove_const;
import 'remove_constructor_name_test.dart' as remove_constructor_name;
import 'remove_constructor_test.dart' as remove_constructor;
import 'remove_dead_code_test.dart' as remove_dead_code;
import 'remove_default_value_test.dart' as remove_default_value;
import 'remove_deprecated_new_in_comment_reference_test.dart'
    as remove_deprecated_new_in_comment_reference;
import 'remove_duplicate_case_test.dart' as remove_duplicate_case;
import 'remove_empty_catch_test.dart' as remove_empty_catch;
import 'remove_empty_constructor_body_test.dart'
    as remove_empty_constructor_body;
import 'remove_empty_else_test.dart' as remove_empty_else;
import 'remove_empty_statement_test.dart' as remove_empty_statement;
import 'remove_if_null_operator_test.dart' as remove_if_null_operator;
import 'remove_initializer_test.dart' as remove_initializer;
import 'remove_interpolation_braces_test.dart' as remove_interpolation_braces;
import 'remove_invocation_test.dart' as remove_invocation;
import 'remove_late_test.dart' as remove_late;
import 'remove_leading_underscore_test.dart' as remove_leading_underscore;
import 'remove_method_declaration_test.dart' as remove_method_declaration;
import 'remove_name_from_combinator_test.dart' as remove_name_from_combinator;
import 'remove_name_from_declaration_clause_test.dart'
    as remove_name_from_declaration_clause;
import 'remove_non_null_assertion_test.dart' as remove_non_null_assertion_test;
import 'remove_operator_test.dart' as remove_operator;
import 'remove_parameters_in_getter_declaration_test.dart'
    as remove_parameters_in_getter_declaration;
import 'remove_parentheses_in_getter_invocation_test.dart'
    as remove_parentheses_in_getter_invocation;
import 'remove_print_test.dart' as remove_print;
import 'remove_question_mark_test.dart' as remove_question_mark;
import 'remove_required_test.dart' as remove_required;
import 'remove_returned_value_test.dart' as remove_returned_value;
import 'remove_set_literal_test.dart' as remove_set_literal;
import 'remove_this_expression_test.dart' as remove_this_expression;
import 'remove_type_annotation_test.dart' as remove_type_annotation;
import 'remove_type_arguments_test.dart' as remove_type_arguments;
import 'remove_unnecessary_cast_test.dart' as remove_unnecessary_cast;
import 'remove_unnecessary_const_test.dart' as remove_unnecessary_const;
import 'remove_unnecessary_final_test.dart' as remove_unnecessary_final;
import 'remove_unnecessary_late_test.dart' as remove_unnecessary_late;
import 'remove_unnecessary_library_directive_test.dart'
    as remove_unnecessary_library_directive;
import 'remove_unnecessary_new_test.dart' as remove_unnecessary_new;
import 'remove_unnecessary_parentheses_test.dart'
    as remove_unnecessary_parentheses;
import 'remove_unnecessary_raw_string_test.dart'
    as remove_unnecessary_raw_string;
import 'remove_unnecessary_string_escapes_test.dart'
    as remove_unnecessary_string_escapes;
import 'remove_unnecessary_string_interpolation_test.dart'
    as remove_unnecessary_string_interpolation;
import 'remove_unnecessary_to_list_test.dart' as remove_unnecessary_to_list;
import 'remove_unnecessary_wildcard_pattern_test.dart'
    as remove_unnecessary_wildcard_pattern;
import 'remove_unused_catch_clause_test.dart' as remove_unused_catch_clause;
import 'remove_unused_catch_stack_test.dart' as remove_unused_catch_stack;
import 'remove_unused_element_test.dart' as remove_unused_element;
import 'remove_unused_field_test.dart' as remove_unused_field;
import 'remove_unused_import_test.dart' as remove_unused_import;
import 'remove_unused_label_test.dart' as remove_unused_label;
import 'remove_unused_local_variable_test.dart' as remove_unused_local_variable;
import 'remove_unused_parameter_test.dart' as remove_unused_parameter;
import 'remove_var_test.dart' as remove_var;
import 'rename_method_parameter_test.dart' as rename_method_parameter;
import 'rename_to_camel_case_test.dart' as rename_to_camel_case;
import 'replace_Null_with_void_test.dart' as replace_null_with_void;
import 'replace_boolean_with_bool_test.dart' as replace_boolean_with_bool;
import 'replace_cascade_with_dot_test.dart' as replace_cascade_with_dot;
import 'replace_colon_with_equals_test.dart' as replace_colon_with_equals;
import 'replace_container_with_sized_box_test.dart'
    as replace_container_with_sized_box;
import 'replace_empty_amp_pattern_test.dart' as replace_empty_amp_pattern;
import 'replace_final_with_const_test.dart' as replace_final_with_const;
import 'replace_final_with_var_test.dart' as replace_final_with_var;
import 'replace_new_with_const_test.dart' as replace_new_with_const;
import 'replace_null_check_with_cast_test.dart' as replace_null_check_with_cast;
import 'replace_null_with_closure_test.dart' as replace_null_with_closure;
import 'replace_return_type_future_test.dart' as replace_return_type_future;
import 'replace_return_type_iterable_test.dart' as replace_return_type_iterable;
import 'replace_return_type_stream_test.dart' as replace_return_type_stream;
import 'replace_return_type_test.dart' as replace_return_type;
import 'replace_var_with_dynamic_test.dart' as replace_var_with_dynamic;
import 'replace_with_arrow_test.dart' as replace_with_arrow;
import 'replace_with_brackets_test.dart' as replace_with_brackets;
import 'replace_with_conditional_assignment_test.dart'
    as replace_with_conditional_assignment;
import 'replace_with_decorated_box_test.dart' as replace_with_decorated_box;
import 'replace_with_eight_digit_hex_test.dart' as replace_with_eight_digit_hex;
import 'replace_with_extension_name_test.dart' as replace_with_extension_name;
import 'replace_with_identifier_test.dart' as replace_with_identifier;
import 'replace_with_interpolation_test.dart' as replace_with_interpolation;
import 'replace_with_is_empty_test.dart' as replace_with_is_empty;
import 'replace_with_is_nan_test.dart' as replace_with_is_nan;
import 'replace_with_is_not_empty_test.dart' as replace_with_is_not_empty;
import 'replace_with_not_null_aware_test.dart' as replace_with_not_null_aware;
import 'replace_with_null_aware_test.dart' as replace_with_null_aware;
import 'replace_with_part_of_uri_test.dart' as replace_with_part_of_uri;
import 'replace_with_tear_off_test.dart' as replace_with_tear_off;
import 'replace_with_unicode_escape_test.dart' as replace_with_unicode_escape_;
import 'replace_with_var_test.dart' as replace_with_var;
import 'replace_with_wildcard_test.dart' as replace_with_wildcard;
import 'sort_child_property_last_test.dart' as sort_properties_last;
import 'sort_combinators_test.dart' as sort_combinators_test;
import 'sort_constructor_first_test.dart' as sort_constructor_first_test;
import 'sort_unnamed_constructor_first_test.dart'
    as sort_unnamed_constructor_first_test;
import 'split_multiple_declarations_test.dart'
    as split_multiple_declarations_test;
import 'surround_with_parentheses_test.dart' as surround_with_parentheses;
import 'update_sdk_constraints_test.dart' as update_sdk_constraints;
import 'use_curly_braces_test.dart' as use_curly_braces;
import 'use_effective_integer_division_test.dart'
    as use_effective_integer_division;
import 'use_eq_eq_null_test.dart' as use_eq_eq_null;
import 'use_is_not_empty_test.dart' as use_is_not_empty;
import 'use_not_eq_null_test.dart' as use_not_eq_null;
import 'use_rethrow_test.dart' as use_rethrow;
import 'wrap_in_future_test.dart' as wrap_in_future;
import 'wrap_in_text_test.dart' as wrap_in_text;
import 'wrap_in_unawaited_test.dart' as wrap_in_unawaited;

void main() {
  defineReflectiveSuite(() {
    add_async.main();
    add_await.main();
    add_call_super.main();
    add_const.main();
    add_curly_braces.main();
    add_diagnostic_property_reference.main();
    add_enum_constant_test.main();
    add_eol_at_end_of_file.main();
    add_explicit_call.main();
    add_explicit_cast.main();
    add_extension_override.main();
    add_field_formal_parameters.main();
    add_key_to_constructors.main();
    add_late.main();
    add_leading_newline_to_string.main();
    add_missing_enum_case_clauses.main();
    add_missing_enum_like_case_clauses.main();
    add_missing_parameter_named.main();
    add_missing_parameter_positional.main();
    add_missing_parameter_required.main();
    add_missing_required_argument.main();
    add_missing_switch_cases.main();
    add_ne_null.main();
    add_null_check.main();
    add_override.main();
    add_reopen.main();
    add_required.main();
    add_return_null.main();
    add_return_type.main();
    add_static.main();
    add_super_constructor_invocation.main();
    add_super_parameter.main();
    add_switch_case_break.main();
    add_trailing_comma.main();
    add_type_annotation.main();
    analysis_options.main();
    bulk_fix_processor.main();
    change_argument_name.main();
    change_to.main();
    change_to_nearest_precise_value.main();
    change_to_static_access.main();
    change_type_annotation.main();
    convert_class_to_enum.main();
    convert_documentation_into_line.main();
    convert_flutter_child.main();
    convert_flutter_children.main();
    convert_for_each_to_for_loop.main();
    convert_into_block_body.main();
    convert_into_expression_body.main();
    convert_into_is_not.main();
    convert_quotes.main();
    convert_to_boolean_expression.main();
    convert_to_cascade.main();
    convert_to_constant_pattern.main();
    convert_to_contains.main();
    convert_to_double_quoted_string.main();
    convert_to_for_element.main();
    convert_to_function_declaration.main();
    convert_to_generic_function_syntax.main();
    convert_to_if_element.main();
    convert_to_if_null.main();
    convert_to_initializing_formal.main();
    convert_to_int_literal.main();
    convert_to_map_literal.main();
    convert_to_named_arguments.main();
    convert_to_null_aware.main();
    convert_to_null_aware_spread.main();
    convert_to_on_type.main();
    convert_to_package_import.main();
    convert_to_raw_string.main();
    convert_to_relative_import.main();
    convert_to_set_literal.main();
    convert_to_single_quoted_string.main();
    convert_to_spread.main();
    convert_to_super_parameters.main();
    convert_to_where_type.main();
    convert_to_wildcard_pattern.main();
    create_class.main();
    create_constructor_for_final_field.main();
    create_constructor_super.main();
    create_constructor.main();
    create_field.main();
    create_file.main();
    create_function.main();
    create_getter.main();
    create_local_variable.main();
    create_method.main();
    create_missing_overrides.main();
    create_mixin.main();
    create_no_such_method.main();
    create_setter.main();
    data_driven.main();
    directives_ordering.main();
    extend_class_for_mixin.main();
    extract_local_variable.main();
    fix.main();
    fix_in_file.main();
    fix_processor_map.main();
    format_file.main();
    ignore_error.main();
    import_library_prefix.main();
    import_library_project.main();
    import_library_sdk.main();
    import_library_show.main();
    inline_invocation.main();
    inline_typedef.main();
    insert_semicolon.main();
    make_class_abstract.main();
    make_conditional_on_debug_mode.main();
    make_field_not_final.main();
    make_field_public.main();
    make_final.main();
    make_required_named_parameters_first.main();
    make_return_type_nullable.main();
    make_super_invocation_last.main();
    make_variable_not_final.main();
    make_variable_nullable.main();
    move_annotation_to_library_directive.main();
    move_doc_comment_to_library_directive.main();
    move_type_arguments_to_class.main();
    organize_imports.main();
    pubspec.main();
    qualify_reference.main();
    remove_abstract.main();
    remove_annotation.main();
    remove_argument.main();
    remove_assertion.main();
    remove_assignment.main();
    remove_await.main();
    remove_break.main();
    remove_character.main();
    remove_comparison.main();
    remove_const.main();
    remove_constructor.main();
    remove_constructor_name.main();
    remove_dead_code.main();
    remove_default_value.main();
    remove_deprecated_new_in_comment_reference.main();
    remove_duplicate_case.main();
    remove_empty_catch.main();
    remove_empty_constructor_body.main();
    remove_empty_else.main();
    remove_empty_statement.main();
    remove_if_null_operator.main();
    remove_initializer.main();
    remove_interpolation_braces.main();
    remove_invocation.main();
    remove_late.main();
    remove_leading_underscore.main();
    remove_method_declaration.main();
    remove_name_from_combinator.main();
    remove_name_from_declaration_clause.main();
    remove_non_null_assertion_test.main();
    remove_operator.main();
    remove_parameters_in_getter_declaration.main();
    remove_parentheses_in_getter_invocation.main();
    remove_print.main();
    remove_question_mark.main();
    remove_required.main();
    remove_returned_value.main();
    remove_set_literal.main();
    remove_this_expression.main();
    remove_type_annotation.main();
    remove_type_arguments.main();
    remove_unnecessary_cast.main();
    remove_unnecessary_const.main();
    remove_unnecessary_final.main();
    remove_unnecessary_late.main();
    remove_unnecessary_library_directive.main();
    remove_unnecessary_new.main();
    remove_unnecessary_parentheses.main();
    remove_unnecessary_raw_string.main();
    remove_unnecessary_string_escapes.main();
    remove_unnecessary_string_interpolation.main();
    remove_unnecessary_to_list.main();
    remove_unnecessary_wildcard_pattern.main();
    remove_unused_catch_clause.main();
    remove_unused_catch_stack.main();
    remove_unused_element.main();
    remove_unused_field.main();
    remove_unused_import.main();
    remove_unused_label.main();
    remove_unused_local_variable.main();
    remove_unused_parameter.main();
    remove_var.main();
    rename_method_parameter.main();
    rename_to_camel_case.main();
    replace_boolean_with_bool.main();
    replace_cascade_with_dot.main();
    replace_colon_with_equals.main();
    replace_container_with_sized_box.main();
    replace_empty_amp_pattern.main();
    replace_final_with_const.main();
    replace_final_with_var.main();
    replace_new_with_const.main();
    replace_null_check_with_cast.main();
    replace_null_with_closure.main();
    replace_null_with_void.main();
    replace_return_type.main();
    replace_return_type_future.main();
    replace_return_type_iterable.main();
    replace_return_type_stream.main();
    replace_var_with_dynamic.main();
    replace_with_arrow.main();
    replace_with_brackets.main();
    replace_with_conditional_assignment.main();
    replace_with_decorated_box.main();
    replace_with_eight_digit_hex.main();
    replace_with_extension_name.main();
    replace_with_identifier.main();
    replace_with_interpolation.main();
    replace_with_is_empty.main();
    replace_with_is_nan.main();
    replace_with_is_not_empty.main();
    replace_with_not_null_aware.main();
    replace_with_null_aware.main();
    replace_with_part_of_uri.main();
    replace_with_tear_off.main();
    replace_with_unicode_escape_.main();
    replace_with_var.main();
    replace_with_wildcard.main();
    sort_properties_last.main();
    sort_constructor_first_test.main();
    sort_combinators_test.main();
    sort_unnamed_constructor_first_test.main();
    split_multiple_declarations_test.main();
    surround_with_parentheses.main();
    update_sdk_constraints.main();
    use_curly_braces.main();
    use_effective_integer_division.main();
    use_eq_eq_null.main();
    use_is_not_empty.main();
    use_not_eq_null.main();
    use_rethrow.main();
    wrap_in_future.main();
    wrap_in_text.main();
    wrap_in_unawaited.main();
  }, name: 'fix');
}
