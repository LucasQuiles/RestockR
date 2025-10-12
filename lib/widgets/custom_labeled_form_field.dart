import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../widgets/custom_text_form_field.dart';

/** 
 * CustomLabeledFormField - A reusable form field component that combines a label with a text input field.
 * Features responsive design, support for required field indicators, password fields with visibility toggle,
 * and consistent styling across different form inputs.
 * 
 * @param labelText - The label text to display above the input field
 * @param hintText - Placeholder text for the input field
 * @param isRequired - Whether to show asterisk (*) for required fields
 * @param isPassword - Whether this is a password field with visibility toggle
 * @param controller - TextEditingController for managing input value
 * @param validator - Validation function for form validation
 * @param onChanged - Callback when input value changes
 * @param keyboardType - Type of keyboard to show
 * @param margin - External margin for the entire component
 */
class CustomLabeledFormField extends StatelessWidget {
  const CustomLabeledFormField({
    Key? key,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.margin,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null) ...[
            Text(
              isRequired ? '$labelText*' : labelText!,
              style: TextStyleHelper.instance.body12SemiBoldInter
                  .copyWith(height: 15 / 12),
            ),
            SizedBox(height: 6.h),
          ],
          CustomTextFormField(
            controller: controller,
            hintText: hintText,
            isPassword: isPassword,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType ?? TextInputType.text,
            onTap: onTap,
            enabled: enabled,
            textStyle: TextStyleHelper.instance.body14MediumInter
                .copyWith(color: appTheme.gray_900, height: 17 / 14),
            hintStyle: TextStyleHelper.instance.body14MediumInter
                .copyWith(color: appTheme.colorFF9CA3, height: 17 / 14),
            fillColor: appTheme.whiteCustom,
            borderColor: appTheme.gray_300,
            focusedBorderColor: appTheme.gray_900,
            borderRadius: 12.h,
            contentPadding: isPassword
                ? EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.h)
                : EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.h),
          ),
        ],
      ),
    );
  }
}
